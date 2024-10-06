import Foundation
import SwiftUI
import Combine

final class HomeViewModel: ObservableObject {
    @Published var musicFiles: [MusicFileEntity] = []
    @Published var playlists: [PlaylistEntity] = []
    @Published var selectedPlaylist: PlaylistEntity?
    
    private var dataManager = DataManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        dataManager.$savedFiles
            .receive(on: DispatchQueue.main)
            .assign(to: \.musicFiles, on: self)
            .store(in: &cancellables)
        
        dataManager.$savedPlaylists
            .receive(on: DispatchQueue.main)
            .assign(to: \.playlists, on: self)
            .store(in: &cancellables)
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
        dataManager.savePlaylist(name: name)
    }
    
    func addSong(_ song: MusicFileEntity, to playlist: PlaylistEntity) {
        dataManager.addSong(song, to: playlist)
    }
    
    func deleteMusicFile(at offsets: IndexSet) {
        for index in offsets {
            let musicFile = musicFiles[index]
            dataManager.deleteMusicFile(musicFile)
        }
    }
}
