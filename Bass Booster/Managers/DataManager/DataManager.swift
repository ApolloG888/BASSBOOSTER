import Foundation
import CoreData
import Combine
import AVFoundation

final class DataManager: ObservableObject {
    static let shared = DataManager()
    
    let container: NSPersistentContainer
    
    @Published var savedFiles: [MusicFileEntity] = []
    @Published var savedPlaylists: [PlaylistEntity] = []
    @Published var savedPresets: [PresetEntity] = []
    
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        container = NSPersistentContainer(name: "BassBoosterData")
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Ошибка загрузки Core Data: \(error)")
            }
            self.container.viewContext.automaticallyMergesChangesFromParent = true
            self.container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            self.fetchMusicFiles()
            self.fetchPlaylists {
                DispatchQueue.main.async {
                    if !self.savedPlaylists.contains(where: { $0.name == "My Player" }) {
                        self.savePlaylist(name: "My Player")
                    }
                }
            }
            self.fetchPresets()
        }
    }
    
    // MARK: - Получение Музыкальных Файлов
    
    func fetchMusicFiles() {
        let request: NSFetchRequest<MusicFileEntity> = MusicFileEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \MusicFileEntity.name, ascending: true)]
        do {
            let files = try container.viewContext.fetch(request)
            DispatchQueue.main.async {
                self.savedFiles = files
            }
        } catch {
            print("Ошибка получения данных: \(error)")
        }
    }
    
    func fetchMusicFiles(for playlist: PlaylistEntity?) {
        if let playlist = playlist {
            if let songs = playlist.songs?.allObjects as? [MusicFileEntity] {
                DispatchQueue.main.async {
                    self.savedFiles = songs
                }
            } else {
                DispatchQueue.main.async {
                    self.savedFiles = []
                }
            }
        } else {
            fetchMusicFiles()
        }
    }
    
    func fetchPresets() {
        let request: NSFetchRequest<PresetEntity> = PresetEntity.fetchRequest()
        
        do {
            let presets = try container.viewContext.fetch(request)
            DispatchQueue.main.async {
                self.savedPresets = presets
            }
        } catch {
            print("Ошибка загрузки пресетов: \(error)")
        }
    }
    
    // MARK: - Обработка Выбранных Файлов
    
    func handlePickedFiles(urls: [URL], completion: @escaping () -> Void) {
        let backgroundContext = container.newBackgroundContext()
        backgroundContext.automaticallyMergesChangesFromParent = true
        backgroundContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        backgroundContext.perform {
            for url in urls {
                let fileName = url.lastPathComponent
                let destinationURL = self.getDocumentsDirectory().appendingPathComponent(fileName)
                do {
                    if !FileManager.default.fileExists(atPath: destinationURL.path) {
                        try FileManager.default.copyItem(at: url, to: destinationURL)
                        print("Скопирован файл в: \(destinationURL.path)")
                    } else {
                        print("Файл уже существует по пути: \(destinationURL.path)")
                    }
                    let asset = AVAsset(url: destinationURL)
                    let metadata = self.extractMetadata(from: asset)
                    self.saveMusicFile(name: metadata.songTitle, artist: metadata.artist, albumArt: metadata.albumArt, url: destinationURL, context: backgroundContext)
                } catch {
                    print("Ошибка копирования файла: \(error)")
                }
            }
            do {
                try backgroundContext.save()
                print("Фоновый контекст успешно сохранён.")
            } catch {
                print("Ошибка сохранения данных в фоне: \(error)")
            }
            DispatchQueue.main.async {
                self.fetchMusicFiles()
                completion()
            }
        }
    }

    // MARK: - Извлечение Метаданных
    
    func extractMetadata(from asset: AVAsset) -> (songTitle: String, artist: String, albumArt: Data?) {
        var songTitle = "Unknown"
        var artist = "Unknown"
        var albumArt: Data?
        
        for format in asset.commonMetadata {
            if format.commonKey?.rawValue == "title" {
                songTitle = format.stringValue ?? "Unknown"
            } else if format.commonKey?.rawValue == "artist" {
                artist = format.stringValue ?? "Unknown"
            } else if format.commonKey?.rawValue == "artwork", let data = format.dataValue {
                albumArt = data
            }
        }
        
        return (songTitle, artist, albumArt)
    }
    
    // MARK: - Сохранение Музыкального Файла
    
    func saveMusicFile(name: String, artist: String, albumArt: Data?, url: URL, context: NSManagedObjectContext) {
        // Проверка на существование файла по пути
        let fetchRequest: NSFetchRequest<MusicFileEntity> = MusicFileEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "url == %@", url.lastPathComponent)
        
        do {
            let existingSongs = try context.fetch(fetchRequest)
            if existingSongs.isEmpty {
                let newFile = MusicFileEntity(context: context)
                newFile.id = UUID()
                newFile.name = name
                newFile.artist = artist
                newFile.albumArt = albumArt
                newFile.url = url.lastPathComponent  // Сохраняем только имя файла
                
                // Получение плейлиста "My Player" в фоновом контексте
                let playlistFetch: NSFetchRequest<PlaylistEntity> = PlaylistEntity.fetchRequest()
                playlistFetch.predicate = NSPredicate(format: "name == %@", "My Player")
                playlistFetch.fetchLimit = 1
                let playlists = try context.fetch(playlistFetch)
                if let generalPlaylist = playlists.first {
                    newFile.addToPlaylist(generalPlaylist)
                    print("Добавлено в плейлист 'My Player'.")
                } else {
                    print("Плейлист 'My Player' не найден в фоновом контексте.")
                }
                
                print("Сохранён музыкальный файл: \(name)")
            } else {
                print("Музыкальный файл уже существует: \(name)")
            }
        } catch {
            print("Ошибка при проверке существующих музыкальных файлов: \(error)")
        }
    }
    
    func saveCustomPreset(name: String, frequencyValues: [Double]) {
        let newPreset = PresetEntity(context: container.viewContext)
        newPreset.id = UUID()
        newPreset.name = name
        newPreset.frequencyValues = frequencyValues as NSArray // Преобразуем массив частот в сериализуемый объект

        saveData(shouldFetchPresets: true)
        print("Custom Preset Saved: \(name)") // Логирование для проверки
    }
    
    // MARK: - Переименование Песни
    
    func renameSong(_ song: MusicFileEntity, newArtist: String, newName: String) {
        let validArtist = newArtist.isEmpty ? (song.artist ?? "Unknown") : newArtist
        let validName = newName.isEmpty ? (song.name ?? "Unknown") : newName
        
        if song.artist != validArtist || song.name != validName {
            song.artist = validArtist
            song.name = validName
            saveData(shouldFetchPlaylists: false)
            print("Песня переименована на: \(validName) от \(validArtist)")
        } else {
            print("Изменений в песне не обнаружено.")
        }
    }
    
    // MARK: - Удаление Музыкального Файла
    
    func deleteMusicFile(_ musicFile: MusicFileEntity) {
        container.viewContext.delete(musicFile)
        saveData(shouldFetchPlaylists: false)
        print("Удалена песня: \(musicFile.name ?? "Unknown")")
    }
    
    // MARK: - Удаление Песни из Плейлиста
    
    func removeSongFromPlaylist(_ song: MusicFileEntity, from playlist: PlaylistEntity) {
        guard let songs = playlist.songs as? Set<MusicFileEntity>, songs.contains(song) else {
            print("Песня не найдена в плейлисте \(playlist.name ?? "Unknown")")
            return
        }
        
        playlist.removeFromSongs(song)
        saveData(shouldFetchPlaylists: false)
        print("Песня удалена из плейлиста: \(playlist.name ?? "Unknown")")
    }
    
    // MARK: - Получение Плейлистов
    
    func fetchPlaylists(completion: (() -> Void)? = nil) {
        let request: NSFetchRequest<PlaylistEntity> = PlaylistEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \PlaylistEntity.name, ascending: true)]
        do {
            let playlists = try container.viewContext.fetch(request)
            DispatchQueue.main.async {
                self.savedPlaylists = playlists
                completion?()
            }
        } catch {
            print("Ошибка получения плейлистов: \(error)")
            completion?()
        }
    }
    
    // MARK: - Сохранение Плейлиста
    
    func savePlaylist(name: String) {
        let newPlaylist = PlaylistEntity(context: container.viewContext)
        newPlaylist.id = UUID()
        newPlaylist.name = name
        
        saveData(shouldFetchPlaylists: true)
        print("Создан плейлист: \(name)")
    }
    
    // MARK: - Добавление Песни в Плейлист
    
    func addSong(_ song: MusicFileEntity, to playlist: PlaylistEntity) {
        if let songs = playlist.songs as? Set<MusicFileEntity>, !songs.contains(song) {
            playlist.addToSongs(song)
            saveData(shouldFetchPlaylists: false)
            print("Добавлена песня в плейлист: \(playlist.name ?? "Unknown")")
        } else {
            print("Песня уже находится в плейлисте \(playlist.name ?? "Unknown")")
        }
    }
    
    // MARK: - Сохранение Данных
    
    func saveData(shouldFetchPlaylists: Bool = false) {
        if container.viewContext.hasChanges {
            do {
                try container.viewContext.save()
                print("Данные успешно сохранены.")
                if shouldFetchPlaylists {
                    fetchPlaylists()
                }
            } catch {
                print("Ошибка сохранения данных: \(error)")
            }
        }
    }
    
    func saveData(shouldFetchPresets: Bool = false) {
        if container.viewContext.hasChanges {
            do {
                try container.viewContext.save()
                print("Данные успешно сохранены.")
                if shouldFetchPresets {
                    fetchPresets()
                }
            } catch {
                print("Ошибка сохранения данных: \(error)")
            }
        }
    }
    
    // MARK: - Вспомогательные Функции
    
    private func isMusicFileExists(withName name: String) -> Bool {
        savedFiles.contains { $0.name == name }
    }
    
    func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
}
