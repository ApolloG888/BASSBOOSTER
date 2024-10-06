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
            
            SearchBarView {
                // Реализация поиска, если необходимо
            }
            
            List {
                ForEach(viewModel.musicFiles) { musicFile in
                    MusicFileRow(
                        musicFile: musicFile,
                        playlists: viewModel.playlists.filter { $0.name != "General" },
                        onAddToPlaylist: { song, playlist in
                            viewModel.addSong(song, to: playlist)
                        }
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

import SwiftUI

struct MusicFileRow: View {
    var musicFile: MusicFileEntity
    var playlists: [PlaylistEntity]
    var onAddToPlaylist: (MusicFileEntity, PlaylistEntity) -> Void

    @State private var showActionSheet = false

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
                ActionSheet(
                    title: Text("Add to Playlist"),
                    message: Text("Choose a playlist to add the song"),
                    buttons: actionSheetButtons()
                )
            }
        }
        .padding()
    }

    private func actionSheetButtons() -> [ActionSheet.Button] {
        var buttons: [ActionSheet.Button] = playlists.map { playlist in
            .default(Text(playlist.name ?? "Playlist")) {
                onAddToPlaylist(musicFile, playlist)
            }
        }
        buttons.append(.cancel())
        return buttons
    }
}

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

import SwiftUI

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
