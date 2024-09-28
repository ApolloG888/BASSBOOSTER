//
//  DataManager.swift
//  Bass Booster
//
//  Created by Protsak Dmytro on 28.09.2024.
//

import Foundation
import CoreData

final class DataManager: ObservableObject {
    static let shared = DataManager()

    let container: NSPersistentContainer

    @Published var savedFiles: [MusicFileEntity] = []

    private init() {
        container = NSPersistentContainer(name: "BassBooster")
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Ошибка загрузки Core Data: \(error)")
            }
        }
        fetchMusicFiles()
    }

    func fetchMusicFiles() {
        let request: NSFetchRequest<MusicFileEntity> = MusicFileEntity.fetchRequest()
        do {
            savedFiles = try container.viewContext.fetch(request)
        } catch {
            print("Ошибка получения данных: \(error)")
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

            saveData()
            fetchMusicFiles()
        }
    }

    func deleteMusicFile(_ musicFile: MusicFileEntity) {
        container.viewContext.delete(musicFile)
        saveData()
        fetchMusicFiles()
    }

    func saveData() {
        if container.viewContext.hasChanges {
            do {
                try container.viewContext.save()
            } catch {
                print("Ошибка сохранения данных: \(error)")
            }
        }
    }

    private func isMusicFileExists(withName name: String) -> Bool {
        savedFiles.contains { $0.name == name }
    }

    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
}
