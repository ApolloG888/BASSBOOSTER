import Foundation
import SwiftUI
import Combine
import BottomSheet
import AVFoundation

final class MusicViewModel: NSObject, ObservableObject, AVAudioPlayerDelegate {
    
    var audioPlayer: AVAudioPlayer?
    private var progressTimer: Timer?
    
    @Published var musicFiles: [MusicFileEntity] = []
    @Published var playlists: [PlaylistEntity] = []
    @Published var selectedPlaylist: PlaylistEntity?
    
    @Published var isShowViewNewPlaylist: Bool = false
    @Published var isShowDeleteSongView: Bool = false
    @Published var songToDelete: MusicFileEntity?
    
    @Published var isShowRenameSongView: Bool = false
    @Published var isPlaylistList: Bool = false
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

    private var dataManager = DataManager.shared
    private var cancellables = Set<AnyCancellable>()
    
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
    
    override init() {
        super.init()
        dataManager.$savedFiles
            .receive(on: DispatchQueue.main)
            .assign(to: \.musicFiles, on: self)
            .store(in: &cancellables)
        
        dataManager.$savedPlaylists
            .receive(on: DispatchQueue.main)
            .assign(to: \.playlists, on: self)
            .store(in: &cancellables)
    }
    
    // MARK: - Обработка Выбранных Файлов
    
    func handlePickedFiles(urls: [URL]) {
        isLoading = true  // Устанавливаем состояние загрузки
        dataManager.handlePickedFiles(urls: urls) {
            // Этот блок выполнится после завершения обработки файлов
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let myPlayerPlaylist = self.playlists.first(where: { $0.name == "My Player" }) {
                    self.selectedPlaylist = myPlayerPlaylist
                    self.fetchMusicFiles(for: myPlayerPlaylist)
                    if let firstSong = self.musicFiles.first {
                        self.currentSong = firstSong
                        self.playMusic()
                    }
                } else {
                    self.selectedPlaylist = nil
                    self.fetchSavedMusicFiles()
                    if let firstSong = self.musicFiles.first {
                        self.currentSong = firstSong
                        self.playMusic()
                    }
                }
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
    
    // MARK: - Управление Плейлистами
    
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
    
    // MARK: - Управление Песнями
    
    func addSong(_ song: MusicFileEntity, to playlist: PlaylistEntity) {
        dataManager.addSong(song, to: playlist)
    }
    
    func requestRenameSong(_ song: MusicFileEntity) {
        selectedMusicFile = song
        isShowRenameSongView = true
        bottomSheetPosition = .hidden
    }
    
    func confirmRenameSong(newArtist: String, newSongName: String) {
        if let song = selectedMusicFile {
            dataManager.renameSong(song, newArtist: newArtist, newName: newSongName)
            
            // Check if the renamed song is the currently playing song
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
        // Сначала удаляем объект из массива musicFiles
        if let index = musicFiles.firstIndex(of: musicFile) {
            musicFiles.remove(at: index)
        }
        // Затем удаляем объект из Core Data
        dataManager.deleteMusicFile(musicFile)
    }
    
    func showBottomSheet(for musicFile: MusicFileEntity) {
        selectedMusicFile = musicFile
        isPlaylistList = false
        bottomSheetPosition = .absolute(270)
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
            
            // Check if the deleted song is the currently playing song
            if song.id == currentSong?.id {
                currentSong = nil
                pauseMusic()  // Stop the player
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
    
    func removeSongFromPlaylist(_ song: MusicFileEntity, from playlist: PlaylistEntity) {
        dataManager.removeSongFromPlaylist(song, from: playlist)
        fetchMusicFiles(for: playlist)
    }
    
    // MARK: - Воспроизведение Музыки
    
    func playMusic() {
        guard let song = currentSong, let fileName = song.url else {
            print("Неверная песня или URL файла")
            return
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
            audioPlayer?.stop()
            audioPlayer = try AVAudioPlayer(contentsOf: fileURL)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            isPlaying = true
            startProgressTimer()
            saveCurrentSong()
        } catch {
            print("Ошибка при воспроизведении музыки: \(error)")
        }
    }

    func pauseMusic() {
        audioPlayer?.pause()
        isPlaying = false
        stopProgressTimer()
    }

    func playPauseMusic() {
        if isPlaying {
            pauseMusic()
        } else {
            if audioPlayer != nil {
                audioPlayer?.play()
                isPlaying = true
                startProgressTimer()
            } else {
                playMusic()
            }
        }
    }

    func nextSong() {
        guard !musicFiles.isEmpty else { return }
        
        if shuffleMode {
            currentSong = musicFiles.randomElement()
        } else {
            guard let currentIndex = musicFiles.firstIndex(of: currentSong!) else { return }
            let nextIndex = (currentIndex + 1) % musicFiles.count
            currentSong = musicFiles[nextIndex]
        }
        playMusic()
    }

    func previousSong() {
        guard let currentSong = currentSong else { return }
        guard let currentIndex = musicFiles.firstIndex(of: currentSong) else { return }
        let previousIndex = (currentIndex - 1 + musicFiles.count) % musicFiles.count
        self.currentSong = musicFiles[previousIndex]
        playMusic()
    }

    // MARK: - Прогресс Воспроизведения
    
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

    private func updatePlaybackProgress() {
        guard let audioPlayer = audioPlayer else {
            playbackProgress = 0.0
            return
        }
        let duration = audioPlayer.duration
        if duration > 0 {
            playbackProgress = audioPlayer.currentTime / duration
        } else {
            playbackProgress = 0.0
        }
    }

    func seek(to progress: Double) {
        guard let audioPlayer = audioPlayer else { return }
        let newTime = progress * audioPlayer.duration
        audioPlayer.currentTime = newTime
        updatePlaybackProgress()
    }
    
    // MARK: - Сохранение и Загрузка Текущей Песни
    
    func saveCurrentSong() {
        if let songID = currentSong?.id {
            UserDefaults.standard.set(songID.uuidString, forKey: "LastPlayedSongID")
        }
    }

    func loadLastPlayedSong() {
        if let songIDString = UserDefaults.standard.string(forKey: "LastPlayedSongID"),
           let songID = UUID(uuidString: songIDString),
           let song = musicFiles.first(where: { $0.id == songID }) {
            currentSong = song
        } else if let firstSong = musicFiles.first {
            currentSong = firstSong
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        stopProgressTimer()

        if isRepeatOn {
            playMusic()
            isRepeatOn = false
        } else {
            nextSong()
        }
    }
    
    func shuffleToggle() {
        shuffleMode.toggle()
    }
    
    func repeatToggle() {
        isRepeatOn.toggle()
    }
    
    deinit {
        stopProgressTimer()
    }
}
