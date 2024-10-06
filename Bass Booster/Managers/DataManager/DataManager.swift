//
//  DataManager.swift
//  Bass Booster
//
//  Created by Protsak Dmytro on 28.09.2024.
//

import Foundation
import CoreData
import Combine

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
        fetchPlaylists()
        
        // Создаем плейлист "General", если его нет
        if !savedPlaylists.contains(where: { $0.name == "General" }) {
            savePlaylist(name: "General")
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
                saveMusicFile(name: fileName, url: destinationURL)
            } catch {
                print("Ошибка копирования файла: \(error)")
            }
        }
        fetchMusicFiles()
    }
    
    func saveMusicFile(name: String, url: URL) {
        if !isMusicFileExists(withName: name) {
            let newFile = MusicFileEntity(context: container.viewContext)
            newFile.id = UUID()
            newFile.name = name
            newFile.url = url.absoluteString
            
            // Добавляем в плейлист "General"
            if let generalPlaylist = savedPlaylists.first(where: { $0.name == "General" }) {
                newFile.addToPlaylist(generalPlaylist)
            }
            
            saveData()
        }
    }
    
    func renameSong(_ song: MusicFileEntity, to newName: String) {
        song.name = newName
        saveData()
    }
    
    func deleteMusicFile(_ musicFile: MusicFileEntity) {
        container.viewContext.delete(musicFile)
        saveData()
    }
    
    // MARK: - Работа с плейлистами
    
    func fetchPlaylists() {
        let request: NSFetchRequest<PlaylistEntity> = PlaylistEntity.fetchRequest()
        do {
            let playlists = try container.viewContext.fetch(request)
            DispatchQueue.main.async {
                self.savedPlaylists = playlists
            }
        } catch {
            print("Ошибка получения плейлистов: \(error)")
        }
    }
    
    func savePlaylist(name: String) {
        let newPlaylist = PlaylistEntity(context: container.viewContext)
        newPlaylist.id = UUID()
        newPlaylist.name = name
        
        saveData()
        fetchPlaylists()
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
    
    func removeSong(_ song: MusicFileEntity, from playlist: PlaylistEntity) {
        playlist.removeFromSongs(song)
        saveData()
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
