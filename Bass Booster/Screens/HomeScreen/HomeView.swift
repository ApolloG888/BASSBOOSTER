//
//  HomeView.swift
//  Bass Booster
//
//  Created by Mac Book Air M1 on 04.09.2024.
//

import SwiftUI
import CoreData

struct HomeView: View {
    @StateObject var viewModel: HomeViewModel

    var body: some View {
        VStack {
            HStack {
                Text("My Player")
                    .font(.system(size: 32, weight: .medium))
                    .foregroundColor(.white)
                Spacer()
                // Кнопка добавления музыки находится в MainTabView
            }
            .padding(.bottom, 8)

            SearchBarView {
                // Реализация поиска, если необходимо
            }

            List {
                ForEach(viewModel.musicFiles) { musicFile in
                    MusicFileRow(musicFile: musicFile)
                }
                .onDelete(perform: viewModel.deleteMusicFile)
            }
            .listStyle(PlainListStyle())
            .background(Color.clear)
            .onAppear {
                viewModel.fetchSavedMusicFiles()
            }

            Spacer()
        }
        .hideNavigationBar()
        .padding()
        .appGradientBackground()
    }
}

struct MusicFileRow: View {
    var musicFile: MusicFileEntity

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
    }
}

// Превью для SwiftUI
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = HomeViewModel()
        HomeView(viewModel: viewModel)
    }
}
