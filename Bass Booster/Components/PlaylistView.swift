//
//  PlaylistView.swift
//  Bass Booster
//
//  Created by Mac Book Air M1 on 04.09.2024.
//

import SwiftUI

enum PlaylistState {
    case createNew
    case existing(name: String)
}

struct PlaylistView: View {
    var state: PlaylistState
    
    var body: some View {
        VStack {
            switch state {
            case .createNew:
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.07), lineWidth: 2)
                        .frame(width: 48, height: 48)
                    Image(systemName: "plus")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .foregroundColor(.playlistGrey)
                }
                .padding(.bottom, 8)
                
                Text("Add playlist")
                    .font(.sfProDisplay(type: .regular400, size: 14))
                    .foregroundColor(.gray)
            case .existing(let name):
                Image(systemName: "music.note")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .foregroundColor(.white)
                
                Text(name)
                    .font(.system(size: 18, weight: .regular))
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .frame(width: 133, height: 133)
        .background(.customBlack)
        .cornerRadius(16)
    }
}

struct ContentеView: View {
    var body: some View {
        HStack {
            PlaylistView(state: .createNew)
            PlaylistView(state: .existing(name: "PlayList"))
        }
        .padding()
        .appGradientBackground()
    }
}

struct ContentеView_Previews: PreviewProvider {
    static var previews: some View {
        ContentеView()
    }
}
