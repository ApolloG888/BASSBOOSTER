// HomeViewModel.swift
import Foundation
import SwiftUI
import Combine
import BottomSheet

final class HomeViewModel: ObservableObject {
    @Published var musicFiles: [MusicFileEntity] = []
    @Published var playlists: [PlaylistEntity] = []
    @Published var selectedPlaylist: PlaylistEntity?
    
    // Свойства для управления NewPlaylistView
    @Published var isShowViewNewPlaylist: Bool = false
    
    // Свойства для управления DeleteSongView
    @Published var isShowDeleteSongView: Bool = false
    @Published var songToDelete: MusicFileEntity?
    
    // Свойства для BottomSheet
    @Published var bottomSheetPosition: BottomSheetPosition = .hidden
    @Published var selectedMusicFile: MusicFileEntity?
    
    private var dataManager = DataManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    var isInGeneralPlaylist: Bool {
        return selectedPlaylist?.name == "General" || selectedPlaylist == nil
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
    
    // MARK: - Fetch Methods
    
    func fetchSavedMusicFiles() {
        dataManager.fetchMusicFiles()
    }
    
    func fetchPlaylists() {
        dataManager.fetchPlaylists()
    }
    
    func fetchMusicFiles(for playlist: PlaylistEntity?) {
        dataManager.fetchMusicFiles(for: playlist)
    }
    
    // MARK: - Playlist Management
    
    func addPlaylist(name: String) {
        dataManager.savePlaylist(name: name)
    }
    
    func createNewPlaylist(name: String) {
        addPlaylist(name: name)
        isShowViewNewPlaylist = false
    }
    
    func cancelNewPlaylist() {
        isShowViewNewPlaylist = false
    }
    
    // MARK: - Song Management
    
    func addSong(_ song: MusicFileEntity, to playlist: PlaylistEntity) {
        dataManager.addSong(song, to: playlist)
    }
    
    func renameSong(_ song: MusicFileEntity, to newName: String) {
        dataManager.renameSong(song, to: newName)
    }
    
    func deleteMusicFileEntity(_ musicFile: MusicFileEntity) {
        dataManager.deleteMusicFile(musicFile)
    }
    
    func deleteMusicFile(at offsets: IndexSet) {
        for index in offsets {
            let musicFile = musicFiles[index]
            dataManager.deleteMusicFile(musicFile)
        }
    }
    
    // MARK: - BottomSheet Management
    
    func showBottomSheet(for musicFile: MusicFileEntity) {
        self.selectedMusicFile = musicFile
        self.bottomSheetPosition = .absolute(270)
    }
    
    func hideBottomSheet() {
        self.bottomSheetPosition = .hidden
        self.selectedMusicFile = nil
    }
    
    // MARK: - Delete Song Confirmation
    
    func requestDeleteSong(_ song: MusicFileEntity) {
        self.songToDelete = song
        self.isShowDeleteSongView = true
        self.bottomSheetPosition = .hidden
    }
    
    func confirmDeleteSong() {
        if let song = songToDelete {
            deleteMusicFileEntity(song)
        }
        self.isShowDeleteSongView = false
        self.songToDelete = nil
        self.bottomSheetPosition = .hidden
    }
    
    func cancelDeleteSong() {
        self.isShowDeleteSongView = false
        self.songToDelete = nil
    }
}
