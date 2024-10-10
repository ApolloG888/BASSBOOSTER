// HomeViewModel.swift
import Foundation
import SwiftUI
import Combine
import BottomSheet

final class HomeViewModel: ObservableObject {
    @Published var musicFiles: [MusicFileEntity] = []
    @Published var playlists: [PlaylistEntity] = []
    @Published var selectedPlaylist: PlaylistEntity?
    @Published var isShowViewNewPlaylist: Bool = false
    
    // Новые свойства для BottomSheet
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
    
    // Методы для управления BottomSheet через position
    func showBottomSheet(for musicFile: MusicFileEntity) {
        self.selectedMusicFile = musicFile
        self.bottomSheetPosition = .absolute(270)
    }
    
    func hideBottomSheet() {
        self.bottomSheetPosition = .hidden
        self.selectedMusicFile = nil
    }
    
    func createNewPlaylist(name: String) {
        addPlaylist(name: name)
        isShowViewNewPlaylist = false
    }
    
    func cancelNewPlaylist() {
        isShowViewNewPlaylist = false
    }
}
