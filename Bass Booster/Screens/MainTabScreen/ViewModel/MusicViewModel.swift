import SwiftUI
import Combine
import BottomSheet
import AVFoundation
import MediaPlayer
import AudioKit
final class MusicViewModel: NSObject, ObservableObject, AVAudioPlayerDelegate {

    // MARK: - AppStorage Properties
    @AppStorage("userPurchaseIsActive") var userPurchaseIsActive: Bool = false
    @AppStorage("shouldShowPromotion") var shouldShowPromotion = true
    @AppStorage("isQuietSoundSelected") var isQuietSoundSelected: Bool = false
    @AppStorage("isSuppressionSelected") var isSuppressionSelected: Bool = false
    @AppStorage("selectedMode") var selectedMode: Modes = .normal
    @AppStorage("bassBoostValue") var bassBoostValue: Double = 0.0 {
        didSet { updateBassBoost() }
    }
    @AppStorage("crystallizerValue") var crystallizerValue: Double = 0.0 {
        didSet { updateCrystallizer() }
    }
    @AppStorage("panValue") var panValue: Double = 0.0 {
        didSet { mixer.pan = smoothPanValue(panValue) }
    }

    // MARK: - Private Properties
    private let urlManager: URLManagerProtocol = URLManager()
    private var audioSession = AVAudioSession.sharedInstance()
    private var progressTimer: Timer?
    private var cancellables = Set<AnyCancellable>()
    
    // AudioKit properties
    var engine = AudioEngine()
    var playerNode = AudioPlayer()
    var bassBoost: ParametricEQ!
    var crystallizer: Delay!
    var mixer = Mixer()

    // MARK: - Published Properties for UI Updates
    @Published var musicFiles: [MusicFileEntity] = []
    @Published var playlists: [PlaylistEntity] = []
    @Published var selectedPlaylist: PlaylistEntity?
    @Published var isShowViewNewPlaylist: Bool = false
    @Published var isShowDeleteSongView: Bool = false
    @Published var songToDelete: MusicFileEntity?
    @Published var isShowRenameSongView: Bool = false
    @Published var isPlaylistList: Bool = false
    @Published var isVolumeSheet: Bool = false
    @Published var isBoosterSheet: Bool = false
    @Published var isQualizerSheet: Bool = false
    @Published var sheetState: SliderType = .bass
    @Published var bottomSheetPosition: BottomSheetPosition = .hidden
    @Published var selectedMusicFile: MusicFileEntity?
    @Published var isExpandedSheet: Bool = false
    @Published var currentSong: MusicFileEntity?
    @Published var isPlaying: Bool = false
    @Published var searchText: String = ""
    @Published var isLoading: Bool = false
    @Published var playbackProgress: Double = 0.0
    @Published var shuffleMode: Bool = false
    @Published var isRepeatOn: Bool = false
    @Published var isShowSubscriptionOverlay: Bool = false
    @Published var currentVolume: Float = 0.5
    @Published var isShowingCreatePresetView: Bool = false
    @Published var frequencyValues: [Double] = Array(repeating: 0.0, count: 10)
    @Published var selectedCustomPreset: PresetEntity?
    @Published var selectedRegularPreset: MusicPreset?
    @Published var customPresets: [PresetEntity] = []

    var dataManager = DataManager.shared

    // MARK: - Computed Properties
    var isInGeneralPlaylist: Bool {
        return selectedPlaylist?.name == "My Player" || selectedPlaylist == nil
    }

    var filteredMusicFiles: [MusicFileEntity] {
        if searchText.isEmpty {
            return musicFiles
        } else {
            return musicFiles.filter { musicFile in
                let nameMatches = musicFile.name?.localizedCaseInsensitiveContains(searchText) ?? false
                let artistMatches = musicFile.artist?.localizedCaseInsensitiveContains(searchText) ?? false
                return nameMatches || artistMatches
            }
        }
    }

    var equalizers: [ParametricEQ] = []

    // MARK: - Initialization
    override init() {
        super.init()
        setupVolumeMonitoring()
        setupAudioChain()
        currentVolume = audioSession.outputVolume
        
        // Subscriptions for data updates
        dataManager.$savedFiles
            .receive(on: DispatchQueue.main)
            .assign(to: \.musicFiles, on: self)
            .store(in: &cancellables)
        
        dataManager.$savedPlaylists
            .receive(on: DispatchQueue.main)
            .assign(to: \.playlists, on: self)
            .store(in: &cancellables)
        
        dataManager.$savedPresets
            .receive(on: DispatchQueue.main)
            .assign(to: \.customPresets, on: self)
            .store(in: &cancellables)
    }

    // MARK: - URL Management
    func openMockURL() {
        urlManager.open(urlString: "https://www.google.com")
    }
    
    // MARK: - Deinitialization
    deinit {
        stopProgressTimer()
        audioSession.removeObserver(self, forKeyPath: "outputVolume")
    }
}

// MARK: - Music Playback

extension MusicViewModel {

    func playMusic() {
        guard let song = currentSong, let fileName = song.url else {
            print("Неверная песня или URL файла")
            return
        }
        resetPreset()
        
        DispatchQueue.main.async {
            self.bassBoostValue = 0.0
            self.crystallizerValue = 0.0
        }

        let documentsDirectory = dataManager.getDocumentsDirectory()
        let fileURL = documentsDirectory.appendingPathComponent(fileName)

        print("Попытка воспроизведения файла по URL: \(fileURL)")

        if FileManager.default.fileExists(atPath: fileURL.path) {
            print("Файл существует по пути: \(fileURL.path)")
        } else {
            print("Файл не найден по пути: \(fileURL.path)")
            return
        }

        do {
            let audioFile = try AVAudioFile(forReading: fileURL)
            
            playerNode.stop()
            try playerNode.load(file: audioFile)
            
            // Устанавливаем зацикливание в зависимости от isRepeatOn
            playerNode.isLooping = isRepeatOn
            
            playerNode.completionHandler = { [weak self] in
                guard let self = self else { return }
                print("Трек завершил воспроизведение")
                if self.isRepeatOn {
                    print("Повторяем трек")
                    self.playerNode.play(from: 0)
                } else {
                    DispatchQueue.main.async {
                        self.nextSong()
                    }
                }
            }

            // Начинаем воспроизведение с начала
            playerNode.play(from: 0)
            isPlaying = true
            playbackProgress = 0.0 // Сброс прогресса воспроизведения
            startProgressTimer()
            print("Воспроизведение началось с начала")
        } catch {
            print("Ошибка при воспроизведении музыки: \(error)")
        }
    }

    func repeatToggle() {
        isRepeatOn.toggle()
        playerNode.isLooping = isRepeatOn
        print("Режим повторения установлен: \(isRepeatOn)")
    }

    private func updatePlaybackProgress() {
        let duration = playerNode.duration
        let currentTime = playerNode.currentTime
        if duration > 0 {
            playbackProgress = currentTime / duration
            // Ограничение значения до 1.0
            playbackProgress = min(playbackProgress, 1.0)
            print("playbackProgress обновлён: \(playbackProgress)")
        } else {
            playbackProgress = 0.0
        }
    }

    func pauseMusic() {
        playerNode.pause()
        isPlaying = false
        stopProgressTimer()
    }
    
    func playPauseMusic() {
        if isPlaying {
            pauseMusic()
        } else {
            playerNode.play()
            isPlaying = true
            startProgressTimer()
        }
    }
    
    func nextSong() {
        guard !musicFiles.isEmpty else {
            print("Список песен пуст")
            return
        }

        if shuffleMode {
            DispatchQueue.main.async {
                self.currentSong = self.musicFiles.randomElement()
                if let songName = self.currentSong?.name {
                    print("Shuffle включен. Выбрана случайная песня: \(songName)")
                }
                self.playMusic()
            }
        } else {
            guard let currentIndex = musicFiles.firstIndex(of: currentSong!) else {
                print("Текущая песня не найдена в списке")
                return
            }
            let nextIndex = (currentIndex + 1) % musicFiles.count
            print("Переход от индекса \(currentIndex) к следующему индексу \(nextIndex)")
            DispatchQueue.main.async {
                self.currentSong = self.musicFiles[nextIndex]
                if let songName = self.currentSong?.name {
                    print("Воспроизведение следующей песни: \(songName)")
                }
                self.playMusic()
            }
        }
    }
    
    func previousSong() {
        guard let currentSong = currentSong else { return }
        guard let currentIndex = musicFiles.firstIndex(of: currentSong) else { return }
        let previousIndex = (currentIndex - 1 + musicFiles.count) % musicFiles.count
        
        DispatchQueue.main.async {
            self.currentSong = self.musicFiles[previousIndex]
            self.playMusic()
        }
    }
    
    private func startProgressTimer() {
        stopProgressTimer()
        progressTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.updatePlaybackProgress()
        }
    }
    
    private func stopProgressTimer() {
        progressTimer?.invalidate()
        progressTimer = nil
    }
    
    func seek(to progress: Double) {
        let duration = playerNode.duration
        guard duration > 0 else {
            print("Продолжительность трека равна нулю")
            return
        }
        
        // Ограничиваем progress между 0.0 и 1.0
        let clampedProgress = min(max(progress, 0.0), 1.0)
        let newTime = clampedProgress * duration
        
        // Печатаем значения для отладки
        print("Перемещение воспроизведения на \(newTime) секунд (прогресс: \(clampedProgress))")
        
        // Перемещаемся на новую позицию
        playerNode.seek(time: newTime)
        
        // Обновляем прогресс вручную, так как таймер может задерживать обновление
        playbackProgress = clampedProgress
    }
    
    func shuffleToggle() {
        shuffleMode.toggle()
    }
    
    func smoothPanValue(_ value: Double) -> Float {
        return Float(tanh(value / 25.0))
    }
}

// MARK: - Volume Control

extension MusicViewModel {
    private func setupVolumeMonitoring() {
        let volumeView = MPVolumeView(frame: .zero)
        volumeView.isHidden = true
        UIApplication.shared.windows.first?.addSubview(volumeView)
        
        // Observe output volume
        currentVolume = audioSession.outputVolume
        audioSession.addObserver(self, forKeyPath: "outputVolume", options: [.new, .initial], context: nil)
    }
    
    override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey : Any]?,
        context: UnsafeMutableRawPointer?
    ) {
        if keyPath == "outputVolume" {
            if let newVolume = change?[.newKey] as? Float {
                DispatchQueue.main.async {
                    self.currentVolume = newVolume
                }
            }
        }
    }
    
    func updateDeviceVolume(to value: Float) {
        let volumeView = MPVolumeView(frame: .zero)
        if let volumeSlider = volumeView.subviews.first(where: { $0 is UISlider }) as? UISlider {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
                volumeSlider.value = value
                volumeSlider.sendActions(for: .valueChanged)
            }
        }
    }
}

// MARK: - Equalizer and Audio Effects

extension MusicViewModel {
    private func setupAudioChain() {
        // Настройка эквалайзера для баса
        bassBoost = ParametricEQ(playerNode)
        bassBoost.centerFreq = AUValue(100.0) // Частота для бас-бустера
        bassBoost.q = AUValue(1.0) // Качество фильтра
        bassBoost.gain = AUValue(bassBoostValue) // Начальное значение усиления

        crystallizer = Delay(bassBoost)
        crystallizer.time = AUValue(0.1) // Время задержки
        crystallizer.feedback = AUValue(crystallizerValue) // Обратная связь
        crystallizer.dryWetMix = AUValue(crystallizerValue) // Микс сухого и обработанного сигнала

        let frequencies: [Double] = [32, 64, 125, 250, 500, 1000, 2000, 4000, 8000, 16000]
        var previousNode: Node = crystallizer

        // Создание эквалайзеров для каждой частоты
        equalizers = frequencies.map { frequency in
            let eq = ParametricEQ(previousNode)
            eq.centerFreq = AUValue(frequency)
            eq.q = AUValue(1.0)
            eq.gain = AUValue(0.0)
            previousNode = eq
            return eq
        }

        // Настройка микшера для всех аудиоузлов (эквалайзеры, эффекты и плеер)
        mixer = Mixer(equalizers)

        // Установка начального значения панорамы
        mixer.pan = Float(panValue)

        // Устанавливаем выход микшера в аудиодвижок
        engine.output = mixer

        // Запуск аудиодвижка AudioKit
        do {
            try engine.start()
            print("AudioKit Engine успешно запущен")
        } catch {
            print("Не удалось запустить AudioKit Engine: \(error)")
        }
    }
    
    func updateBassBoost() {
        guard let bassBoost = bassBoost else { return }
        bassBoost.gain = AUValue(bassBoostValue)
    }
    
    func updateCrystallizer() {
        guard let crystallizer = crystallizer else { return }
        crystallizer.feedback = AUValue(crystallizerValue)
        crystallizer.dryWetMix = AUValue(crystallizerValue)
    }
    
    func updateEqualizer(for index: Int, value: Double) {
        guard index < equalizers.count else { return }
        equalizers[index].gain = AUValue(value)
        
        if let preset = selectedCustomPreset {
            frequencyValues[index] = value
            
            dataManager.saveCustomPreset(preset: preset, frequencyValues: frequencyValues)
        }
    }
    
    func applyCustomPreset(_ preset: PresetEntity) {
        selectedRegularPreset = nil
        selectedCustomPreset = preset

        if let values = preset.frequencyValues as? [Double] {
            frequencyValues = values
            for index in 0..<frequencyValues.count {
                updateEqualizer(for: index, value: frequencyValues[index])
            }
        }
    }

    func applyRegularPreset(_ preset: MusicPreset) {
        selectedCustomPreset = nil
        selectedRegularPreset = preset

        let scalingFactor = 8.33
        switch preset {
        case .rock:
            frequencyValues = [4.0, 2.0, 0.0, -2.0, -4.0, 2.0, 4.0, -1.0, -2.0, 0.0].map { $0 * scalingFactor }
        case .rnb:
            frequencyValues = [2.0, 1.0, 0.0, -1.0, -2.0, 2.0, 3.0, -1.5, 0.5, 0.0].map { $0 * scalingFactor }
        case .pop:
            frequencyValues = [5.0, 3.0, 0.0, -1.0, -3.0, 1.0, 3.0, -2.0, -3.0, 0.0].map { $0 * scalingFactor }
        case .classic:
            frequencyValues = [3.0, 2.0, 1.0, 0.0, -2.0, 1.5, 2.0, -1.0, -1.5, 0.0].map { $0 * scalingFactor }
        case .rap:
            frequencyValues = [6.0, 4.0, 1.0, -2.0, -3.0, 2.0, 5.0, -1.0, -2.0, 1.0].map { $0 * scalingFactor }
        }

        for index in 0..<frequencyValues.count {
            updateEqualizer(for: index, value: frequencyValues[index])
        }
    }
    
    func resetPreset() {
        DispatchQueue.main.async {
            self.frequencyValues = Array(repeating: 0.0, count: 10)
            
            self.selectedCustomPreset = nil
            self.selectedRegularPreset = nil
            
            for index in 0..<self.frequencyValues.count {
                self.updateEqualizer(for: index, value: self.frequencyValues[index])
            }
        }
    }
}

// MARK: - File Handling and Playlist Management
extension MusicViewModel {
    func canAddSong() -> Bool {
//        if !userPurchaseIsActive && musicFiles.count >= 1 {
//            isShowSubscriptionOverlay = true
//            return false
//        }
        return true
    }
    
    // MARK: - Обработка Выбранных Файлов
    
    func handlePickedFiles(urls: [URL]) {
//        if !userPurchaseIsActive && urls.count > 1 {
//            let limitedURLs = Array(urls.prefix(1))
//            processFiles(urls: limitedURLs)
//            isShowSubscriptionOverlay = true
//        } else {
            processFiles(urls: urls)
//        }
    }

    private func processFiles(urls: [URL]) {
        isLoading = true
        dataManager.handlePickedFiles(urls: urls) {
            DispatchQueue.main.async {
                self.isLoading = false
                self.updatePlaylistAndPlayFirstSong()
            }
        }
    }
    
    private func updatePlaylistAndPlayFirstSong() {
        if let myPlayerPlaylist = playlists.first(where: { $0.name == "My Player" }) {
            selectedPlaylist = myPlayerPlaylist
            fetchMusicFiles(for: myPlayerPlaylist)
            if let firstSong = musicFiles.first {
                currentSong = firstSong
                playMusic()
            }
        } else {
            selectedPlaylist = nil
            fetchSavedMusicFiles()
            if let firstSong = musicFiles.first {
                currentSong = firstSong
                playMusic()
            }
        }
    }
    
    func fetchSavedMusicFiles() {
        dataManager.fetchMusicFiles()
    }
    
    func fetchPlaylists() {
        dataManager.fetchPlaylists()
    }
    
    func fetchMusicFiles(for playlist: PlaylistEntity?) {
        dataManager.fetchMusicFiles(for: playlist)
    }
    
    func addPlaylist(name: String) {
        let uniqueName = generateUniquePlaylistName(desiredName: name)
        dataManager.savePlaylist(name: uniqueName)
    }
    
    private func generateUniquePlaylistName(desiredName: String) -> String {
        var uniqueName = desiredName
        var suffix = 1
        while dataManager.savedPlaylists.contains(where: { $0.name?.lowercased() == uniqueName.lowercased() }) {
            uniqueName = "\(desiredName)\(suffix)"
            suffix += 1
        }
        return uniqueName
    }
    
    func createNewPlaylist(name: String) {
        addPlaylist(name: name)
        isShowViewNewPlaylist = false
    }
    
    func cancelNewPlaylist() {
        isShowViewNewPlaylist = false
    }
    
    func addSong(_ song: MusicFileEntity, to playlist: PlaylistEntity) {
        dataManager.addSong(song, to: playlist)
    }
    
    func removeSongFromPlaylist(_ song: MusicFileEntity, from playlist: PlaylistEntity) {
        dataManager.removeSongFromPlaylist(song, from: playlist)
        fetchMusicFiles(for: playlist)
    }
}

// MARK: - Preset Management
extension MusicViewModel {
    func addCustomPreset(name: String) {
        print("Saving preset with name: \(name)")
        
        let newPreset = PresetEntity(context: dataManager.container.viewContext)
        newPreset.id = UUID()
        newPreset.name = name
        newPreset.frequencyValues = frequencyValues as NSArray

        dataManager.saveData(shouldFetchPresets: true)

        dataManager.fetchPresets()
        selectedCustomPreset = newPreset
        isShowingCreatePresetView = false
    }
    
    func fetchPresets() {
        dataManager.fetchPresets()
    }
}

// MARK: - BottomSheet and UI Control
extension MusicViewModel {
    func showBottomSheet(for musicFile: MusicFileEntity) {
        selectedMusicFile = musicFile
        isPlaylistList = false
        bottomSheetPosition = .absolute(270)
    }
    
    func showVolumeBottomSheet() {
        isVolumeSheet = true
        bottomSheetPosition = .relative(0.7)
    }
    
    func showBoosterBottomSheet(for musicFile: MusicFileEntity) {
        selectedMusicFile = musicFile
        isBoosterSheet = true
        bottomSheetPosition = .relative(0.7)
    }
    
    func showQualizerBottomSheet(for musicFile: MusicFileEntity) {
        selectedMusicFile = musicFile
        isQualizerSheet = true
        bottomSheetPosition = .relative(0.7)
    }
    
    func hideBottomSheet() {
        bottomSheetPosition = .hidden
        selectedMusicFile = nil
        isPlaylistList = false
    }
    
    func requestDeleteSong(_ song: MusicFileEntity) {
        songToDelete = song
        isShowDeleteSongView = true
        bottomSheetPosition = .hidden
    }
    
    func confirmDeleteSong() {
        if let song = songToDelete {
            deleteMusicFileEntity(song)
            
            if song.id == currentSong?.id {
                currentSong = nil
                pauseMusic()
            }
        }
        isShowDeleteSongView = false
        songToDelete = nil
    }
    
    func cancelDeleteSong() {
        isShowDeleteSongView = false
        songToDelete = nil
    }
    
    func requestAddToPlaylist(_ song: MusicFileEntity) {
        selectedMusicFile = song
        isPlaylistList = true
        bottomSheetPosition = .relative(0.85)
    }
    
    func addSongToSelectedPlaylist(_ playlist: PlaylistEntity) {
        if let song = selectedMusicFile {
            addSong(song, to: playlist)
        }
        hideBottomSheet()
    }
}

// MARK: - Song Renaming and Deleting
extension MusicViewModel {
    
    func requestRenameSong(_ song: MusicFileEntity) {
        selectedMusicFile = song
        isShowRenameSongView = true
        bottomSheetPosition = .hidden
    }
    
    func confirmRenameSong(newArtist: String, newSongName: String) {
        if let song = selectedMusicFile {
            dataManager.renameSong(song, newArtist: newArtist, newName: newSongName)
            
            if song.id == currentSong?.id {
                currentSong = nil
                pauseMusic()  // Stop the player
            }
        }
        isShowRenameSongView = false
        selectedMusicFile = nil
    }
    
    func cancelRenameSong() {
        isShowRenameSongView = false
        selectedMusicFile = nil
    }
    
    func deleteMusicFileEntity(_ musicFile: MusicFileEntity) {
        if let index = musicFiles.firstIndex(of: musicFile) {
            musicFiles.remove(at: index)
        }
        dataManager.deleteMusicFile(musicFile)
    }
}
