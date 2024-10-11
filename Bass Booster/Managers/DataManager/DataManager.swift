// DataManager.swift
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
        }
        fetchMusicFiles()
        fetchPlaylists {
            DispatchQueue.main.async {
                if !self.savedPlaylists.contains(where: { $0.name == "General" }) {
                    self.savePlaylist(name: "General")
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
    
    func handlePickedFiles(urls: [URL]) {
        for url in urls {
            let fileName = url.lastPathComponent
            let destinationURL = getDocumentsDirectory().appendingPathComponent(fileName)
            do {
                if !FileManager.default.fileExists(atPath: destinationURL.path) {
                    try FileManager.default.copyItem(at: url, to: destinationURL)
                }
                // Извлекаем метаданные
                let asset = AVAsset(url: destinationURL)
                let metadata = extractMetadata(from: asset)
                
                // Сохраняем файл с метаданными
                saveMusicFile(name: metadata.songTitle, artist: metadata.artist, albumArt: metadata.albumArt, url: destinationURL)
            } catch {
                print("Ошибка копирования файла: \(error)")
            }
        }
        fetchMusicFiles()
    }

    // Функция для извлечения метаданных
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
            newFile.albumArt = albumArt  // Сохраняем обложку как бинарные данные
            newFile.url = url.absoluteString
            
            // Добавляем в плейлист "General"
            if let generalPlaylist = savedPlaylists.first(where: { $0.name == "General" }) {
                newFile.addToPlaylist(generalPlaylist)
            }
            
            saveData()
        }
    }
    
    func renameSong(_ song: MusicFileEntity, newArtist: String, newName: String) {
        let validArtist = newArtist.isEmpty ? song.artist : newArtist
        let validName = newName.isEmpty ? song.name : newName
        
        // Проверяем, изменилось ли что-то
        if song.artist != validArtist || song.name != validName {
            song.artist = validArtist
            song.name = validName
            saveData()
        }
    }
    
    func deleteMusicFile(_ musicFile: MusicFileEntity) {
        container.viewContext.delete(musicFile)
        saveData()
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
        
        saveData()
        fetchPlaylists() // Обновляем список плейлистов после сохранения
    }
    
    func addSong(_ song: MusicFileEntity, to playlist: PlaylistEntity) {
        // Проверяем, есть ли песня уже в плейлисте
        if let songs = playlist.songs as? Set<MusicFileEntity>, !songs.contains(song) {
            playlist.addToSongs(song)
            saveData()
        } else {
            // Песня уже в плейлисте, можно показать уведомление или игнорировать
            print("Песня уже находится в плейлисте \(playlist.name ?? "Unknown")")
        }
    }
    
    // MARK: - Сохранение данных
    
    func saveData() {
        if container.viewContext.hasChanges {
            do {
                try container.viewContext.save()
                fetchMusicFiles()
                fetchPlaylists()
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
