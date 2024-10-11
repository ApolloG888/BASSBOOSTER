//
//  RenameSongView.swift
//  Bass Booster
//
//  Created by Protsak Dmytro on 11.10.2024.
//

import SwiftUI

struct RenameSongView: View {
    @Binding var isPresented: Bool
    @State var authorName: String
    @State var songName: String
    var onSave: (String, String) -> Void
    var onCancel: () -> Void

    var body: some View {
        ZStack {
            // Полупрозрачный фон
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)

            // Центрированное модальное окно
            VStack(spacing: 20) {
                Text("Rename a song")
                    .font(.headline)
                    .foregroundColor(.primary)

                TextField("Author name", text: $authorName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)

                TextField("Song name", text: $songName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)

                HStack {
                    Button("Cancel") {
                        onCancel()
                    }
                    .foregroundColor(.red)

                    Spacer()

                    Button("Save") {
                        if !songName.isEmpty && !authorName.isEmpty {
                            onSave(authorName, songName)
                        }
                    }
                    .disabled(songName.isEmpty || authorName.isEmpty)
                }
                .padding(.horizontal)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(20)
            .shadow(radius: 10)
            .padding(.horizontal, 40) // Для отступа от краёв экрана
        }
    }
}

struct RenameSongView_Previews: PreviewProvider {
    static var previews: some View {
        RenameSongView(
            isPresented: .constant(true),
            authorName: "Current Author",
            songName: "Current Song",
            onSave: { _, _ in },
            onCancel: {}
        )
    }
}
