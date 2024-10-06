import Foundation
import SwiftUI
import Combine

final class HomeViewModel: ObservableObject {
    @Published var musicFiles: [MusicFileEntity] = []
    @Published var playlists: [PlaylistEntity] = []
    @Published var selectedPlaylist: PlaylistEntity?
    @Published var searchText: String = ""
    
    private var dataManager = DataManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    var isInGeneralPlaylist: Bool {
        return selectedPlaylist?.name == "General" || selectedPlaylist == nil
    }
    
    var filteredMusicFiles: [MusicFileEntity] {
        if searchText.isEmpty || !isInGeneralPlaylist {
            return musicFiles
        } else {
            return musicFiles.filter { file in
                file.name?.lowercased().contains(searchText.lowercased()) ?? false
            }
        }
    }
    
    init() {
        dataManager.$savedFiles
            .receive(on: DispatchQueue.main)
            .assign(to: \.musicFiles, on: self)
            .store(in: &cancellables)
        
        dataManager.$savedPlaylists
            .receive(on: DispatchQueue.main)
            .assign(to: \.playlists, on: self)
            .store(in: &cancellables)
        
        // Обновление фильтрованных файлов при изменении searchText
        $searchText
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { _ in
                // Можно добавить дополнительную логику, если необходимо
            }
            .store(in: &cancellables)
    }
    
    func fetchSavedMusicFiles() {
        dataManager.fetchMusicFiles()
    }
    
    func fetchPlaylists() {
        dataManager.fetchPlaylists()
    }
    
    func fetchMusicFiles(for playlist: PlaylistEntity?) {
        selectedPlaylist = playlist
        dataManager.fetchMusicFiles(for: playlist)
    }
    
    func goToGeneralPlaylist() {
        if let generalPlaylist = playlists.first(where: { $0.name == "General" }) {
            selectedPlaylist = generalPlaylist
            fetchMusicFiles(for: generalPlaylist)
        }
    }
    
    func addPlaylist(name: String) {
        dataManager.savePlaylist(name: name)
    }
    
    func addSong(_ song: MusicFileEntity, to playlist: PlaylistEntity) {
        dataManager.addSong(song, to: playlist)
    }
    
    func renameSong(_ song: MusicFileEntity, to newName: String) {
        dataManager.renameSong(song, to: newName)
    }
    
    func deleteMusicFileEntity(_ musicFile: MusicFileEntity) {
        if isInGeneralPlaylist {
            // Удаление из общего плейлиста удаляет песню полностью
            dataManager.deleteMusicFile(musicFile)
        } else {
            // Удаление из текущего плейлиста
            if let currentPlaylist = selectedPlaylist {
                dataManager.removeSong(musicFile, from: currentPlaylist)
            }
        }
    }
    
    func deleteMusicFile(at offsets: IndexSet) {
        for index in offsets {
            let musicFile = musicFiles[index]
            dataManager.deleteMusicFile(musicFile)
        }
    }
}
