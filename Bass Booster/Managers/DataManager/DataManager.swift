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

    private init() {
        container = NSPersistentContainer(name: "BassBoosterData")
        container.loadPersistentStores { (_, error) in
            if let error = error {
                print("Ошибка загрузки Core Data: \(error)")
            }
        }
        fetchMusicFiles()
    }

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

    func handlePickedFiles(urls: [URL]) {
        DispatchQueue.main.async {
            for url in urls {
                let fileName = url.lastPathComponent
                let destinationURL = self.getDocumentsDirectory().appendingPathComponent(fileName)
                do {
                    if !FileManager.default.fileExists(atPath: destinationURL.path) {
                        try FileManager.default.copyItem(at: url, to: destinationURL)
                    }
                    self.saveMusicFile(name: fileName, url: destinationURL)
                } catch {
                    print("Ошибка копирования файла: \(error)")
                }
            }
            self.fetchMusicFiles()
        }
    }

    func saveMusicFile(name: String, url: URL) {
        let newFile = MusicFileEntity(context: container.viewContext)
        newFile.id = UUID()
        newFile.name = name
        newFile.url = url.absoluteString

        saveData()
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

    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
}
