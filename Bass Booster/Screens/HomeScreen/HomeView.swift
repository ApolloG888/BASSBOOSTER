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
    @State private var showAddPlaylistAlert = false
    @State private var newPlaylistName = ""

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
                        showAddPlaylistAlert = true
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

                    // Список существующих плейлистов
                    ForEach(viewModel.playlists) { playlist in
                        VStack {
                            Image(systemName: "music.note.list")
                                .font(.largeTitle)
                                .foregroundColor(.white)
                            Text(playlist.name ?? "Unknown")
                                .foregroundColor(.white)
                                .font(.caption)
                        }
                        .frame(width: 100, height: 100)
                        .background(Color.green)
                        .cornerRadius(10)
                        .onTapGesture {
                            // Действие при выборе плейлиста
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
                        playlists: viewModel.playlists,
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
        .alert(isPresented: $showAddPlaylistAlert) {
            Alert(
                title: Text("New Playlist"),
                message: Text("Enter the name of the playlist"),
                primaryButton: .default(Text("Add"), action: {
                    viewModel.addPlaylist(name: newPlaylistName)
                    newPlaylistName = ""
                }),
                secondaryButton: .cancel({
                    newPlaylistName = ""
                })
            )
        }
    }
}

struct MusicFileRow: View {
    var musicFile: MusicFileEntity
    var playlists: [PlaylistEntity]
    var onAddToPlaylist: (MusicFileEntity, PlaylistEntity) -> Void

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
        }
        .padding()
        .contextMenu {
            ForEach(playlists) { playlist in
                Button(action: {
                    onAddToPlaylist(musicFile, playlist)
                }) {
                    Text("Add to \(playlist.name ?? "Playlist")")
                }
            }
        }
    }
}

//import SwiftUI

struct CustomAlert: View {
    @Binding var isPresented: Bool
    @Binding var text: String
    var title: String
    var onAdd: () -> Void

    var body: some View {
        VStack {
            Text(title)
                .font(.headline)
                .padding()
            TextField("Playlist Name", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            HStack {
                Button("Cancel") {
                    isPresented = false
                    text = ""
                }
                Spacer()
                Button("Add") {
                    isPresented = false
                    onAdd()
                    text = ""
                }
            }
            .padding()
        }
        .frame(width: 300, height: 200)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(20)
        .shadow(radius: 20)
    }
}

extension View {
    func customAlert(isPresented: Binding<Bool>, text: Binding<String>, title: String, onAdd: @escaping () -> Void) -> some View {
        ZStack {
            self
                .blur(radius: isPresented.wrappedValue ? 2 : 0)
            if isPresented.wrappedValue {
                CustomAlert(isPresented: isPresented, text: text, title: title, onAdd: onAdd)
            }
        }
    }
}
