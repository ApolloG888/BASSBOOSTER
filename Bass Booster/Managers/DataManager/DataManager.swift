import Foundation
import CoreData
import Combine
import AVFoundation

final class DataManager: ObservableObject {
    
    // MARK: - Singleton
    static let shared = DataManager()

    // MARK: - Core Data Properties
    let container: NSPersistentContainer

    // MARK: - Published Properties
    @Published var savedFiles: [MusicFileEntity] = []
    @Published var savedPlaylists: [PlaylistEntity] = []
    @Published var savedPresets: [PresetEntity] = []

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization
    private init() {
        container = NSPersistentContainer(name: "BassBoosterData")
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Error loading Core Data: \(error)")
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
}

// MARK: - Music File Handling
extension DataManager {
    
    func fetchMusicFiles() {
        let request: NSFetchRequest<MusicFileEntity> = MusicFileEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \MusicFileEntity.name, ascending: true)]
        do {
            let files = try container.viewContext.fetch(request)
            DispatchQueue.main.async {
                self.savedFiles = files
            }
        } catch {
            print("Error fetching music files: \(error)")
        }
    }
    
    func fetchMusicFiles(for playlist: PlaylistEntity?) {
        if let playlist = playlist, let songs = playlist.songs?.allObjects as? [MusicFileEntity] {
            DispatchQueue.main.async {
                self.savedFiles = songs
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
                        print("File copied to: \(destinationURL.path)")
                    } else {
                        print("File already exists at: \(destinationURL.path)")
                    }
                    let asset = AVAsset(url: destinationURL)
                    let metadata = self.extractMetadata(from: asset)
                    self.saveMusicFile(name: metadata.songTitle, artist: metadata.artist, albumArt: metadata.albumArt, url: destinationURL, context: backgroundContext)
                } catch {
                    print("Error copying file: \(error)")
                }
            }
            do {
                try backgroundContext.save()
                print("Background context successfully saved.")
            } catch {
                print("Error saving background context: \(error)")
            }
            DispatchQueue.main.async {
                self.fetchMusicFiles()
                completion()
            }
        }
    }
    
    func saveMusicFile(name: String, artist: String, albumArt: Data?, url: URL, context: NSManagedObjectContext) {
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
                newFile.url = url.lastPathComponent
                
                let playlistFetch: NSFetchRequest<PlaylistEntity> = PlaylistEntity.fetchRequest()
                playlistFetch.predicate = NSPredicate(format: "name == %@", "My Player")
                if let generalPlaylist = try context.fetch(playlistFetch).first {
                    newFile.addToPlaylist(generalPlaylist)
                    print("Added to playlist 'My Player'.")
                }
                
                print("Saved music file: \(name)")
            }
        } catch {
            print("Error checking existing music files: \(error)")
        }
    }

    func deleteMusicFile(_ musicFile: MusicFileEntity) {
        container.viewContext.delete(musicFile)
        saveData(shouldFetchPlaylists: false)
        print("Deleted song: \(musicFile.name ?? "Unknown")")
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
}

// MARK: - Playlist Management
extension DataManager {
    
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
            print("Error fetching playlists: \(error)")
            completion?()
        }
    }
    
    func savePlaylist(name: String) {
        let newPlaylist = PlaylistEntity(context: container.viewContext)
        newPlaylist.id = UUID()
        newPlaylist.name = name
        saveData(shouldFetchPlaylists: true)
        print("Created playlist: \(name)")
    }
    
    func addSong(_ song: MusicFileEntity, to playlist: PlaylistEntity) {
        if let songs = playlist.songs as? Set<MusicFileEntity>, !songs.contains(song) {
            playlist.addToSongs(song)
            saveData(shouldFetchPlaylists: false)
            print("Added song to playlist: \(playlist.name ?? "Unknown")")
        }
    }
    
    func removeSongFromPlaylist(_ song: MusicFileEntity, from playlist: PlaylistEntity) {
        guard let songs = playlist.songs as? Set<MusicFileEntity>, songs.contains(song) else {
            print("Song not found in playlist \(playlist.name ?? "Unknown")")
            return
        }
        playlist.removeFromSongs(song)
        saveData(shouldFetchPlaylists: false)
        print("Removed song from playlist: \(playlist.name ?? "Unknown")")
    }
}

// MARK: - Preset Management
extension DataManager {
    
    func fetchPresets() {
        let request: NSFetchRequest<PresetEntity> = PresetEntity.fetchRequest()
        do {
            let presets = try container.viewContext.fetch(request)
            DispatchQueue.main.async {
                self.savedPresets = presets
            }
        } catch {
            print("Error fetching presets: \(error)")
        }
    }
    
    func saveCustomPreset(preset: PresetEntity, frequencyValues: [Double]) {
        preset.frequencyValues = frequencyValues as NSArray
        saveData(shouldFetchPresets: true)
        print("Custom Preset Updated: \(preset.name ?? "Unknown")")
    }
}

// MARK: - Data Saving
extension DataManager {
    
    func saveData(shouldFetchPlaylists: Bool = false) {
        if container.viewContext.hasChanges {
            do {
                try container.viewContext.save()
                print("Data successfully saved.")
                if shouldFetchPlaylists {
                    fetchPlaylists()
                }
            } catch {
                print("Error saving data: \(error)")
            }
        }
    }
    
    func saveData(shouldFetchPresets: Bool = false) {
        if container.viewContext.hasChanges {
            do {
                try container.viewContext.save()
                print("Data successfully saved.")
                if shouldFetchPresets {
                    fetchPresets()
                }
            } catch {
                print("Error saving data: \(error)")
            }
        }
    }
}

// MARK: - Song Renaming
extension DataManager {
    
    func renameSong(_ song: MusicFileEntity, newArtist: String, newName: String) {
        let validArtist = newArtist.isEmpty ? (song.artist ?? "Unknown") : newArtist
        let validName = newName.isEmpty ? (song.name ?? "Unknown") : newName
        
        if song.artist != validArtist || song.name != validName {
            song.artist = validArtist
            song.name = validName
            saveData(shouldFetchPlaylists: false)
            print("Song renamed to: \(validName) by \(validArtist)")
        } else {
            print("No changes detected for the song.")
        }
    }
}

// MARK: - Helpers
extension DataManager {
    
    private func isMusicFileExists(withName name: String) -> Bool {
        savedFiles.contains { $0.name == name }
    }
    
    func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
}
