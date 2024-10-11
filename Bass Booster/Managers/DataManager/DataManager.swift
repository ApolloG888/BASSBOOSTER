// DataManager.swift
import Foundation
import CoreData
import Combine
import AVFoundation
import UIKit

final class DataManager: ObservableObject {
    static let shared = DataManager()
    
    let container: NSPersistentContainer
    
    @Published var savedFiles: [MusicFileEntity] = []
    @Published var savedPlaylists: [PlaylistEntity] = []
    
    private init() {
        container = NSPersistentContainer(name: "BassBoosterData")
        
        // Настройка опций миграции
        let description = container.persistentStoreDescriptions.first
        description?.shouldMigrateStoreAutomatically = true
        description?.shouldInferMappingModelAutomatically = true
        
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Ошибка загрузки Core Data: \(error)")
            }
            // После загрузки хранилища, загрузим плейлисты
            self.fetchPlaylists {
                // Проверяем, существует ли плейлист "General" и был ли он уже создан
                let hasCreatedGeneral = UserDefaults.standard.bool(forKey: "hasCreatedGeneralPlaylist")
                if !self.savedPlaylists.contains(where: { $0.name == "General" }) && !hasCreatedGeneral {
                    self.savePlaylist(name: "General")
                    UserDefaults.standard.set(true, forKey: "hasCreatedGeneralPlaylist")
                }
            }
        }
        fetchMusicFiles()
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
                // Асинхронно сохраняем файл с метаданными
                Task {
                    await saveMusicFile(name: fileName, url: destinationURL)
                }
            } catch {
                print("Ошибка копирования файла: \(error)")
            }
        }
        // Не вызываем fetchMusicFiles() здесь, так как это будет сделано после сохранения каждого файла
    }
    
    func extractMetadata(from url: URL) async -> (authorName: String?, songName: String?, image: Data?) {
        let asset = AVAsset(url: url)
        do {
            // Асинхронно загружаем доступные форматы метаданных
            let availableFormats = try await asset.load(.availableMetadataFormats)
            
            var authorName: String?
            var songName: String?
            var imageData: Data?
            
            for format in availableFormats {
                // Асинхронно загружаем метаданные для каждого формата
                let metadata = try await asset.loadMetadata(for: format)
                for item in metadata {
                    if let commonKey = item.commonKey {
                        switch commonKey {
                        case .commonKeyArtist:
                            authorName = try await item.load(.stringValue)
                        case .commonKeyTitle:
                            songName = try await item.load(.stringValue)
                        case .commonKeyArtwork:
                            imageData = try await item.load(.dataValue)
                        default:
                            break
                        }
                    }
                }
            }
            
            return (authorName, songName, imageData)
        } catch {
            print("Error extracting metadata: \(error)")
            return (nil, nil, nil)
        }
    }
    
    func saveMusicFile(name: String, url: URL) async {
        if !isMusicFileExists(withName: name) {
            let newFile = MusicFileEntity(context: container.viewContext)
            newFile.id = UUID()
            newFile.name = name
            newFile.url = url.absoluteString
            
            // Извлекаем метаданные асинхронно
            let metadata = await extractMetadata(from: url)
            newFile.authorName = metadata.authorName
            newFile.songName = metadata.songName
            newFile.image = metadata.image
            
            // Добавляем в плейлист "General"
            if let generalPlaylist = savedPlaylists.first(where: { $0.name == "General" }) {
                newFile.addToPlaylist(generalPlaylist)
            }
            
            saveData()
            
            // Обновляем данные отдельно, чтобы избежать рекурсии
            fetchMusicFiles()
            fetchPlaylists()
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
        
        // Обновляем плейлисты после сохранения
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
    
    // MARK: - Сохранение данных
    
    func saveData() {
        container.viewContext.perform {
            if self.container.viewContext.hasChanges {
                do {
                    try self.container.viewContext.save()
                } catch let error as NSError {
                    if error.code == NSValidationMultipleErrorsError {
                        for validationError in error.userInfo[NSDetailedErrorsKey] as? [NSError] ?? [] {
                            print("Validation Error: \(validationError.localizedDescription)")
                        }
                    } else {
                        print("Ошибка сохранения данных: \(error), \(error.userInfo)")
                    }
                }
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
