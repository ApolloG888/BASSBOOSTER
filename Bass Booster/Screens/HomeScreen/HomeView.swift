//
//  HomeView.swift
//  Bass Booster
//
//  Created by Mac Book Air M1 on 04.09.2024.
//

import SwiftUI
import CoreData

struct HomeView: View {
    @EnvironmentObject var viewModel: MusicViewModel

    var body: some View {
        VStack {
            header
            search
            if viewModel.searchText.isEmpty {
                playLists
            }
            musicList
        }
        .hideNavigationBar()
        .padding()
        .appGradientBackground()
        .onAppear {
            if let myPlayerPlaylist = viewModel.playlists.first(where: { $0.name == "My Player" }) {
                viewModel.selectedPlaylist = myPlayerPlaylist
                viewModel.fetchMusicFiles(for: myPlayerPlaylist)
            } else {
                viewModel.selectedPlaylist = nil
                viewModel.fetchSavedMusicFiles()
            }
        }
    }
}

// MARK: - Header

extension HomeView {
    var header: some View {
        HStack {
            Text("\(viewModel.selectedPlaylist?.name ?? "My Player")")
                .font(.sfProDisplay(type: .medium500, size: 32))
                .foregroundColor(.white)
            Spacer()
        }
        .padding(.bottom, Space.xs)
    }
}

// MARK: - Search

extension HomeView {
    var search: some View {
        HStack {
            TextField(
                "",
                text: $viewModel.searchText,
                prompt: Text("Start Type")
                    .foregroundColor(.white.opacity(0.5))
                    .font(.sfProText(type: .regular400, size: 14))
            )
            .foregroundColor(.white)
            .font(.sfProText(type: .medium500, size: 16))
            
            if viewModel.searchText.isEmpty {
                Image(.magnifer)
                    .foregroundColor(.gray)
            } else {
                Button(action: {
                    viewModel.searchText = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal)
        .padding(.vertical)
        .background(Color.white.opacity(0.07))
        .cornerRadius(8)
    }
}

// MARK: - PlayLists

extension HomeView {
    var playLists: some View {
        VStack(spacing: 16) {
            HStack {
                Text("PlayList")
                    .font(.sfProDisplay(type: .regular400, size: 16))
                    .foregroundStyle(.white)
                Spacer()
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    Button {
                        viewModel.isShowViewNewPlaylist = true
                    } label: {
                        PlaylistView(state: .createNew)
                    }
                    
                    if let generalPlaylist = viewModel.playlists.first(where: { $0.name == "My Player" }) {
                        PlaylistCell(playlist: generalPlaylist) {
                            viewModel.selectedPlaylist = generalPlaylist
                            viewModel.fetchMusicFiles(for: generalPlaylist)
                        }
                    }
                    
                    ForEach(viewModel.playlists.filter { $0.name != "My Player" }) { playlist in
                        PlaylistCell(playlist: playlist) {
                            viewModel.selectedPlaylist = playlist
                            viewModel.fetchMusicFiles(for: playlist)
                        }
                    }
                }
            }
        }
        .padding(.top)
    }
}

extension HomeView {
    var musicList: some View {
        VStack {
            HStack {
                Text("List")
                    .font(.sfProDisplay(type: .regular400, size: 16))
                    .foregroundStyle(.white)
                Spacer()
            }
            if viewModel.filteredMusicFiles.isEmpty {
                if viewModel.searchText.isEmpty {
                    VStack {
                        Spacer()
                        Text("No music yet")
                            .font(.sfProDisplay(type: .bold700, size: 30))
                            .foregroundStyle(.white)
                        Spacer()
                    }
                    .ignoresSafeArea(.keyboard)
                } else {
                    VStack {
                        Spacer()
                        Text("No results found")
                            .font(.sfProDisplay(type: .bold700, size: 30))
                            .foregroundStyle(.white)
                        Spacer()
                    }
                    .ignoresSafeArea(.keyboard)
                }
            } else {
                ScrollView(showsIndicators: false) {
                    ForEach(Array(viewModel.filteredMusicFiles.enumerated()), id: \.element.id) { index, musicFile in
                        HStack {
                            Text("\(index + 1)")
                                .font(.sfProDisplay(type: .regular400, size: 16))
                                .foregroundStyle(.white)
                                .frame(width: 30, alignment: .leading)
                            MusicFileRow(
                                musicFile: musicFile,
                                playlists: viewModel.playlists.filter { $0.name != "My Player" },
                                onOptionSelect: { viewModel.showBottomSheet(for: $0) },
                                onPlay: { selectedMusicFile in
                                    if viewModel.currentSong == selectedMusicFile {
                                        // Песня уже выбрана, просто раскрываем MusicView
                                        viewModel.isExpandedSheet = true
                                    } else {
                                        // Новая песня выбрана
                                        viewModel.currentSong = selectedMusicFile
                                        viewModel.isExpandedSheet = true
                                        viewModel.playMusic()
                                    }
                                }
                            )
                        }
                        .padding(.vertical, 10)
                    }
                    .padding(.bottom, 80)
                }
            }
        }
        .padding(.top)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = MusicViewModel()
        HomeView()
            .environmentObject(viewModel)
    }
}
