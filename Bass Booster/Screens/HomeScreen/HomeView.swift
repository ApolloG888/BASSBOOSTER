//
//  HomeView.swift
//  Bass Booster
//
//  Created by Mac Book Air M1 on 04.09.2024.
//



import SwiftUI
import CoreData
import BottomSheet

struct HomeView: View {
    @StateObject var viewModel = HomeViewModel()
    @State private var showAddPlaylistSheet = false
    @State private var bottomSheetPosition: BottomSheetPosition = .hidden
    @State private var selectedMusicFile: MusicFileEntity?

    var body: some View {
        VStack {
            HStack {
                Text("My Player")
                    .font(.system(size: 32, weight: .medium))
                    .foregroundColor(.white)
                Spacer()
            }
            .padding(.bottom, 8)
            
            // Горизонтальный список плейлистов
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    // Кнопка для добавления нового плейлиста
                    Button(action: {
                        showAddPlaylistSheet = true
                    }) {
                        VStack {
                            Image(systemName: "plus")
                                .font(.largeTitle)
                                .foregroundColor(.white)
                            Text("Add Playlist")
                                .foregroundColor(.white)
                                .font(.caption)
                        }
                        .frame(width: 100, height: 100)
                        .background(Color.blue)
                        .cornerRadius(10)
                    }
                    
                    // Плейлист "General" всегда отображается вторым
                    if let generalPlaylist = viewModel.playlists.first(where: { $0.name == "General" }) {
                        PlaylistCell(playlist: generalPlaylist) {
                            viewModel.selectedPlaylist = generalPlaylist
                            viewModel.fetchMusicFiles(for: generalPlaylist)
                        }
                    }
                    
                    // Остальные плейлисты
                    ForEach(viewModel.playlists.filter { $0.name != "General" }) { playlist in
                        PlaylistCell(playlist: playlist) {
                            viewModel.selectedPlaylist = playlist
                            viewModel.fetchMusicFiles(for: playlist)
                        }
                    }
                }
                .padding(.vertical)
            }
            
            // Здесь должен быть ваш SearchBarView, если он есть
            // Если его нет, можете закомментировать или удалить следующую строку
            // SearchBarView {
            //     // Реализация поиска, если необходимо
            // }
            
            List {
                ForEach(viewModel.musicFiles) { musicFile in
                    MusicFileRow(
                        musicFile: musicFile,
                        playlists: viewModel.playlists.filter { $0.name != "General" },
                        onAddToPlaylist: { song, playlist in
                            viewModel.addSong(song, to: playlist)
                        },
                        onRename: { song, newName in
                            viewModel.renameSong(song, to: newName)
                        },
                        onDelete: { song in
                            viewModel.deleteMusicFileEntity(song)
                        },
                        isInGeneralPlaylist: viewModel.isInGeneralPlaylist,
                        onOptionSelect: { selectedMusicFile = $0; bottomSheetPosition = .absolute(325) } // Handle options
                    )
                }
                .onDelete(perform: viewModel.deleteMusicFile)
            }
            .listStyle(PlainListStyle())
            .background(Color.clear)
            .onAppear {
                viewModel.fetchSavedMusicFiles()
                viewModel.fetchPlaylists()
            }
            
            Spacer()
        }
        .hideNavigationBar()
        .padding()
        .appGradientBackground()
        .bottomSheet(bottomSheetPosition: self.$bottomSheetPosition, switchablePositions: [
                        .dynamicBottom,
                        .absolute(325)
                    ], headerContent: {
                        VStack(alignment: .leading) {
                            Text("Options for \(selectedMusicFile?.name ?? "Music")")
                                .font(.title).bold()
                            Text("Manage your music")
                                .font(.subheadline).foregroundColor(.secondary)
                            Divider()
                        }
                        .padding([.top, .leading])
                    }) {
                        bottomSheetContent()
                    }
                    .showDragIndicator(false)
                    .enableContentDrag()
                    .showCloseButton()
                    .enableSwipeToDismiss()
                    .enableTapToDismiss()
    }
    
    @ViewBuilder
    private func bottomSheetContent() -> some View {
        VStack(spacing: 0) {
            Button("Rename") {
                // Rename logic (trigger a rename action or state)
                if let selected = selectedMusicFile {
                    viewModel.renameSong(selected, to: "New Name") // Example
                }
                bottomSheetPosition = .hidden
            }
            .padding(.horizontal)

            if viewModel.isInGeneralPlaylist {
                Button("Add to Playlist") {
                    // Add to playlist logic
                    if let selected = selectedMusicFile {
                        // Call a function to handle adding to a playlist
                    }
                    bottomSheetPosition = .hidden
                }
                .padding(.horizontal)
            } else {
                Button("Remove from Playlist") {
                    // Remove from playlist logic
                    bottomSheetPosition = .hidden
                }
                .padding(.horizontal)
            }

            Button("Delete", role: .destructive) {
                if let selected = selectedMusicFile {
                    viewModel.deleteMusicFileEntity(selected)
                }
                bottomSheetPosition = .hidden
            }
            .padding(.horizontal)

            Button("Cancel", role: .cancel) {
                bottomSheetPosition = .hidden
            }
            .padding(.horizontal)
            
            Spacer(minLength: 0)
        }
        .padding([.horizontal, .top])
    }
}

// Превью для SwiftUI
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = HomeViewModel()
        HomeView(viewModel: viewModel)
    }
}

// MARK: - Дополнительные компоненты

struct MusicFileRow: View {
    var musicFile: MusicFileEntity
    var playlists: [PlaylistEntity]
    var onAddToPlaylist: (MusicFileEntity, PlaylistEntity) -> Void
    var onRename: (MusicFileEntity, String) -> Void
    var onDelete: (MusicFileEntity) -> Void
    var isInGeneralPlaylist: Bool

    var onOptionSelect: (MusicFileEntity) -> Void // New closure to handle options

    var body: some View {
        HStack {
            Image(systemName: "music.note")
                .foregroundColor(.white)
                .font(.largeTitle)
            VStack(alignment: .leading) {
                Text(musicFile.name ?? "Unknown")
                    .foregroundColor(.white)
                    .font(.headline)
                Text("Additional Info")
                    .foregroundColor(.gray)
                    .font(.subheadline)
            }
            Spacer()
            // Button with three dots to trigger the bottom sheet globally
            Button(action: {
                onOptionSelect(musicFile)
            }) {
                Image(systemName: "ellipsis")
                    .foregroundColor(.white)
                    .font(.title)
            }
        }
        .padding()
    }
}


// Компонент RenameSongView
struct RenameSongView: View {
    @Binding var isPresented: Bool
    @State private var newSongName: String
    var onSave: (String) -> Void

    init(isPresented: Binding<Bool>, songName: String, onSave: @escaping (String) -> Void) {
        self._isPresented = isPresented
        self._newSongName = State(initialValue: songName)
        self.onSave = onSave
    }

    var body: some View {
        NavigationView {
            VStack {
                TextField("Song Name", text: $newSongName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                Spacer()
            }
            .navigationBarTitle("Rename Song", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    isPresented = false
                },
                trailing: Button("Save") {
                    onSave(newSongName)
                    isPresented = false
                }
                .disabled(newSongName.isEmpty)
            )
        }
    }
}

// Компонент AddToPlaylistView
struct AddToPlaylistView: View {
    @Binding var isPresented: Bool
    var playlists: [PlaylistEntity]
    var onAddToPlaylist: (PlaylistEntity) -> Void

    var body: some View {
        NavigationView {
            List {
                ForEach(playlists) { playlist in
                    Button(action: {
                        onAddToPlaylist(playlist)
                        isPresented = false
                    }) {
                        Text(playlist.name ?? "Unknown")
                    }
                }
            }
            .navigationBarTitle("Select Playlist", displayMode: .inline)
            .navigationBarItems(trailing: Button("Cancel") {
                isPresented = false
            })
        }
    }
}

// Компонент PlaylistCell
struct PlaylistCell: View {
    var playlist: PlaylistEntity
    var onTap: () -> Void
    
    var body: some View {
        VStack {
            Image(systemName: "music.note.list")
                .font(.largeTitle)
                .foregroundColor(.white)
            Text(playlist.name ?? "Unknown")
                .foregroundColor(.white)
                .font(.caption)
                .lineLimit(1)
        }
        .frame(width: 100, height: 100)
        .background(Color.green)
        .cornerRadius(10)
        .onTapGesture {
            onTap()
        }
    }
}

// Компонент AddPlaylistView
struct AddPlaylistView: View {
    @Binding var isPresented: Bool
    @State private var playlistName: String = ""
    var onAdd: (String) -> Void

    var body: some View {
        NavigationView {
            VStack {
                TextField("Playlist Name", text: $playlistName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                Spacer()
            }
            .navigationBarTitle("New Playlist", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    isPresented = false
                },
                trailing: Button("Add") {
                    if !playlistName.isEmpty {
                        onAdd(playlistName)
                        isPresented = false
                    }
                }
                .disabled(playlistName.isEmpty)
            )
        }
    }
}
