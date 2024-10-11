import Foundation
import CoreData
import Combine
import AVFoundation

final class DataManager: ObservableObject {
    static let shared = DataManager()
    
    let container: NSPersistentContainer
    
    @Published var savedFiles: [MusicFileEntity] = []
    @Published var savedPlaylists: [PlaylistEntity] = []
    
    private init() {
        container = NSPersistentContainer(name: "BassBoosterData")
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Ошибка загрузки Core Data: \(error)")
            }
            // Хранилища данных успешно загружены, теперь можно выполнять запросы
            self.fetchMusicFiles()
            self.fetchPlaylists {
                DispatchQueue.main.async {
                    if !self.savedPlaylists.contains(where: { $0.name == "My Player" }) {
                        self.savePlaylist(name: "My Player")
                    }
                }
            }
        }
    }
    
    // MARK: - Работа с музыкальными файлами
    
    func fetchMusicFiles() {
        let request: NSFetchRequest<MusicFileEntity> = MusicFileEntity.fetchRequest()
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
            }
        } else {
            fetchMusicFiles()
        }
    }
    
    func handlePickedFiles(urls: [URL], completion: @escaping () -> Void) {
        let backgroundContext = container.newBackgroundContext()
        backgroundContext.perform {
            for url in urls {
                let fileName = url.lastPathComponent
                let destinationURL = self.getDocumentsDirectory().appendingPathComponent(fileName)
                do {
                    if !FileManager.default.fileExists(atPath: destinationURL.path) {
                        try FileManager.default.copyItem(at: url, to: destinationURL)
                    }
                    let asset = AVAsset(url: destinationURL)
                    let metadata = self.extractMetadata(from: asset)
                    
                    self.saveMusicFile(name: metadata.songTitle, artist: metadata.artist, albumArt: metadata.albumArt, url: destinationURL)
                } catch {
                    print("Ошибка копирования файла: \(error)")
                }
            }
            do {
                try backgroundContext.save()
            } catch {
                print("Ошибка сохранения данных в фоне: \(error)")
            }
            DispatchQueue.main.async {
                self.fetchMusicFiles()
                completion()  // Вызываем обработчик завершения
            }
        }
    }


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
    
    func saveMusicFile(name: String, artist: String, albumArt: Data?, url: URL) {
        if !isMusicFileExists(withName: name) {
            let newFile = MusicFileEntity(context: container.viewContext)
            newFile.id = UUID()
            newFile.name = name
            newFile.artist = artist
            newFile.albumArt = albumArt
            newFile.url = url.absoluteString
            
            if let generalPlaylist = savedPlaylists.first(where: { $0.name == "My Player" }) {
                newFile.addToPlaylist(generalPlaylist)
            }
            
            saveData(shouldFetchPlaylists: false)
        }
    }
    
    func renameSong(_ song: MusicFileEntity, newArtist: String, newName: String) {
        let validArtist = newArtist.isEmpty ? song.artist : newArtist
        let validName = newName.isEmpty ? song.name : newName
        
        if song.artist != validArtist || song.name != validName {
            song.artist = validArtist
            song.name = validName
            saveData(shouldFetchPlaylists: false)
        }
    }
    
    func deleteMusicFile(_ musicFile: MusicFileEntity) {
        container.viewContext.delete(musicFile)
        saveData(shouldFetchPlaylists: false)
    }
    
    func removeSongFromPlaylist(_ song: MusicFileEntity, from playlist: PlaylistEntity) {
        guard let songs = playlist.songs as? Set<MusicFileEntity>, songs.contains(song) else {
            print("Песня не найдена в плейлисте \(playlist.name ?? "Unknown")")
            return
        }
        
        playlist.removeFromSongs(song)
        
        saveData(shouldFetchPlaylists: false)
    }
    
    // MARK: - Работа с плейлистами
    
    func fetchPlaylists(completion: (() -> Void)? = nil) {
        let request: NSFetchRequest<PlaylistEntity> = PlaylistEntity.fetchRequest()
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
    
    func savePlaylist(name: String) {
        let newPlaylist = PlaylistEntity(context: container.viewContext)
        newPlaylist.id = UUID()
        newPlaylist.name = name
        
        saveData(shouldFetchPlaylists: true)  // Здесь происходит сохранение с уникальным именем
    }
    
    func addSong(_ song: MusicFileEntity, to playlist: PlaylistEntity) {
        if let songs = playlist.songs as? Set<MusicFileEntity>, !songs.contains(song) {
            playlist.addToSongs(song)
            saveData(shouldFetchPlaylists: false)
        } else {
            print("Песня уже находится в плейлисте \(playlist.name ?? "Unknown")")
        }
    }
    
    // MARK: - Сохранение данных
    
    func saveData(shouldFetchPlaylists: Bool = false) {
        if container.viewContext.hasChanges {
            do {
                try container.viewContext.save()
                if shouldFetchPlaylists {
                    fetchPlaylists()
                }
            } catch {
                print("Ошибка сохранения данных: \(error)")
            }
        }
    }
    
    // MARK: - Вспомогательные функции
    
    private func isMusicFileExists(withName name: String) -> Bool {
        savedFiles.contains { $0.name == name }
    }
    
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
}
