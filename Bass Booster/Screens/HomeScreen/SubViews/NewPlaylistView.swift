//
//  NewPlaylistView.swift
//  Bass Booster
//
//  Created by Protsak Dmytro on 10.10.2024.
//

import SwiftUI

struct NewPlaylistView: View {
    @Binding var isPresented: Bool
    @State private var playlistName: String = ""
    var onSave: (String) -> Void
    var onCancel: () -> Void

    var body: some View {
        ZStack {
            // Полупрозрачный фон
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)

            // Центрированное модальное окно
            VStack(spacing: 20) {
                Text("New Playlist")
                    .font(.headline)
                    .foregroundColor(.primary)

                TextField("Enter playlist name", text: $playlistName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)

                HStack {
                    Button("Cancel") {
                        onCancel()
                    }
                    .foregroundColor(.red)

                    Spacer()

                    Button("Save") {
                        if !playlistName.isEmpty {
                            onSave(playlistName)
                        }
                    }
                    .disabled(playlistName.isEmpty)
                }
                .padding(.horizontal)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(20)
            .shadow(radius: 10)
            .padding(.horizontal, 40) // Для отступа от краёв экрана
        }
        .animation(.easeInOut, value: isPresented)
    }
}

struct NewPlaylistView_Previews: PreviewProvider {
    static var previews: some View {
        NewPlaylistView(isPresented: .constant(true), onSave: { _ in }, onCancel: {})
    }
}
