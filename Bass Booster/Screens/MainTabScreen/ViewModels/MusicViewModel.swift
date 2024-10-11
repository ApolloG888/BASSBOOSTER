import Foundation
import SwiftUI
import Combine
import BottomSheet

final class MusicViewModel: ObservableObject {
    @Published var musicFiles: [MusicFileEntity] = []
    @Published var playlists: [PlaylistEntity] = []
    @Published var selectedPlaylist: PlaylistEntity?
    
    @Published var isShowViewNewPlaylist: Bool = false
    @Published var isShowDeleteSongView: Bool = false
    @Published var songToDelete: MusicFileEntity?
    
    @Published var isShowRenameSongView: Bool = false
    @Published var isPlaylistList: Bool = false
    @Published var bottomSheetPosition: BottomSheetPosition = .hidden
    @Published var selectedMusicFile: MusicFileEntity?
    
    @Published var searchText: String = ""
    @Published var isLoading: Bool = false
    
    private var dataManager = DataManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    var isInGeneralPlaylist: Bool {
        return selectedPlaylist?.name == "My Player" || selectedPlaylist == nil
    }
    
    var filteredMusicFiles: [MusicFileEntity] {
        if searchText.isEmpty {
            return musicFiles
        } else {
            return musicFiles.filter { musicFile in
                let nameMatches = musicFile.name?.localizedCaseInsensitiveContains(searchText) ?? false
                let artistMatches = musicFile.artist?.localizedCaseInsensitiveContains(searchText) ?? false
                return nameMatches || artistMatches
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
    }
    
    // Добавляем новый метод для обработки выбранных файлов
    func handlePickedFiles(urls: [URL]) {
        isLoading = true  // Устанавливаем состояние загрузки
        dataManager.handlePickedFiles(urls: urls) {
            // Этот блок выполнится после завершения обработки файлов
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let myPlayerPlaylist = self.playlists.first(where: { $0.name == "My Player" }) {
                    self.selectedPlaylist = myPlayerPlaylist
                    self.fetchMusicFiles(for: myPlayerPlaylist)
                } else {
                    self.selectedPlaylist = nil
                    self.fetchSavedMusicFiles()
                }
            }
        }
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
    
    // Playlist Management
    func addPlaylist(name: String) {
        let uniqueName = generateUniquePlaylistName(desiredName: name)
        dataManager.savePlaylist(name: uniqueName)
    }
    
    private func generateUniquePlaylistName(desiredName: String) -> String {
        var uniqueName = desiredName
        var suffix = 1
        while dataManager.savedPlaylists.contains(where: { $0.name?.lowercased() == uniqueName.lowercased() }) {
            uniqueName = "\(desiredName)\(suffix)"
            suffix += 1
        }
        return uniqueName
    }
    
    func createNewPlaylist(name: String) {
        addPlaylist(name: name)
        isShowViewNewPlaylist = false
    }
    
    func cancelNewPlaylist() {
        isShowViewNewPlaylist = false
    }
    
    // Song Management
    func addSong(_ song: MusicFileEntity, to playlist: PlaylistEntity) {
        dataManager.addSong(song, to: playlist)
    }
    
    func requestRenameSong(_ song: MusicFileEntity) {
        selectedMusicFile = song
        isShowRenameSongView = true
        bottomSheetPosition = .hidden
    }
    
    func confirmRenameSong(newArtist: String, newSongName: String) {
        if let song = selectedMusicFile {
            dataManager.renameSong(song, newArtist: newArtist, newName: newSongName)
        }
        isShowRenameSongView = false
        selectedMusicFile = nil
    }
    
    func cancelRenameSong() {
        isShowRenameSongView = false
        selectedMusicFile = nil
    }
    
    func deleteMusicFileEntity(_ musicFile: MusicFileEntity) {
        // Сначала удаляем объект из массива musicFiles
        if let index = musicFiles.firstIndex(of: musicFile) {
            musicFiles.remove(at: index)
        }
        // Затем удаляем объект из Core Data
        dataManager.deleteMusicFile(musicFile)
    }
    
    func showBottomSheet(for musicFile: MusicFileEntity) {
        selectedMusicFile = musicFile
        isPlaylistList = false
        bottomSheetPosition = .absolute(270)
    }
    
    func hideBottomSheet() {
        bottomSheetPosition = .hidden
        selectedMusicFile = nil
        isPlaylistList = false
    }
    
    func requestDeleteSong(_ song: MusicFileEntity) {
        songToDelete = song
        isShowDeleteSongView = true
        bottomSheetPosition = .hidden
    }
    
    func confirmDeleteSong() {
        if let song = songToDelete {
            deleteMusicFileEntity(song)
        }
        isShowDeleteSongView = false
        songToDelete = nil
    }
    
    func cancelDeleteSong() {
        isShowDeleteSongView = false
        songToDelete = nil
    }
    
    func requestAddToPlaylist(_ song: MusicFileEntity) {
        selectedMusicFile = song
        isPlaylistList = true
        bottomSheetPosition = .absolute(400)
    }
    
    func addSongToSelectedPlaylist(_ playlist: PlaylistEntity) {
        if let song = selectedMusicFile {
            addSong(song, to: playlist)
        }
        hideBottomSheet()
    }
    
    func removeSongFromPlaylist(_ song: MusicFileEntity, from playlist: PlaylistEntity) {
        dataManager.removeSongFromPlaylist(song, from: playlist)
        fetchMusicFiles(for: playlist)
    }
}
