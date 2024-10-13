//
//  MusicFileRow.swift
//  Bass Booster
//
//  Created by Protsak Dmytro on 11.10.2024.
//

import SwiftUI
import CoreData

struct MusicFileRow: View {
    var musicFile: MusicFileEntity
    var playlists: [PlaylistEntity]
    var onOptionSelect: (MusicFileEntity) -> Void
    var onPlay: (MusicFileEntity) -> Void

    var body: some View {
        HStack {
            if let albumArt = musicFile.albumArt, let image = UIImage(data: albumArt) {
                Image(uiImage: image)
                    .resizable()
                    .frame(width: 44, height: 44)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
            } else {
                Image(.musicNote)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .foregroundColor(.playlistGrey)
                    .frame(width: 44, height: 44)
                    .background(
                        RoundedRectangle(cornerRadius: 5)
                            .fill(Color.customBlack)
                    )
            }
            VStack(alignment: .leading) {
                Text(musicFile.name ?? "Unknown")
                    .foregroundColor(.white)
                    .font(.helvetica(type: .regular400, size: 14))
                Text(musicFile.artist ?? "Unknown Artist")
                    .foregroundColor(.gray)
                    .font(.helvetica(type: .medium500, size: 10))
            }
            Spacer()
            Button(action: {
                onOptionSelect(musicFile)
            }) {
                Image(systemName: "ellipsis")
                    .foregroundColor(.white)
                    .font(.title)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onPlay(musicFile)
        }
    }
}
