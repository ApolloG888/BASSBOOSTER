//
//  HomeView.swift
//  Bass Booster
//
//  Created by Mac Book Air M1 on 04.09.2024.
//

import SwiftUI
import CoreData

struct HomeView: View {
    @StateObject var viewModel = HomeViewModel()
    @State private var showAddPlaylistSheet = false

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
                        isInGeneralPlaylist: viewModel.isInGeneralPlaylist
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
        .background(Color.black) // Или используйте ваш собственный модификатор appGradientBackground()
        .sheet(isPresented: $showAddPlaylistSheet) {
            AddPlaylistView(isPresented: $showAddPlaylistSheet, onAdd: { name in
                viewModel.addPlaylist(name: name)
            })
        }
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

// Компонент MusicFileRow
struct MusicFileRow: View {
    var musicFile: MusicFileEntity
    var playlists: [PlaylistEntity]
    var onAddToPlaylist: (MusicFileEntity, PlaylistEntity) -> Void
    var onRename: (MusicFileEntity, String) -> Void
    var onDelete: (MusicFileEntity) -> Void
    var isInGeneralPlaylist: Bool

    @State private var showActionSheet = false
    @State private var showRenameSheet = false
    @State private var showAddToPlaylistSheet = false

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
            // Кнопка с тремя точками
            Button(action: {
                showActionSheet = true
            }) {
                Image(systemName: "ellipsis")
                    .foregroundColor(.white)
                    .font(.title)
            }
            .actionSheet(isPresented: $showActionSheet) {
                actionSheet()
            }
            .sheet(isPresented: $showRenameSheet) {
                RenameSongView(
                    isPresented: $showRenameSheet,
                    songName: musicFile.name ?? "",
                    onSave: { newName in
                        onRename(musicFile, newName)
                    }
                )
            }
            .sheet(isPresented: $showAddToPlaylistSheet) {
                AddToPlaylistView(
                    isPresented: $showAddToPlaylistSheet,
                    playlists: playlists,
                    onAddToPlaylist: { playlist in
                        onAddToPlaylist(musicFile, playlist)
                    }
                )
            }
        }
        .padding()
    }

    private func actionSheet() -> ActionSheet {
        if isInGeneralPlaylist {
            // Действия для главного плейлиста
            return ActionSheet(
                title: Text("Options"),
                buttons: [
                    .default(Text("Rename")) {
                        showRenameSheet = true
                    },
                    .default(Text("Add to Playlist")) {
                        showAddToPlaylistSheet = true
                    },
                    .destructive(Text("Delete")) {
                        onDelete(musicFile)
                    },
                    .cancel()
                ]
            )
        } else {
            // Действия для других плейлистов (например, только Add to Playlist)
            return ActionSheet(
                title: Text("Options"),
                buttons: [
                    .default(Text("Add to Playlist")) {
                        showAddToPlaylistSheet = true
                    },
                    .cancel()
                ]
            )
        }
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
