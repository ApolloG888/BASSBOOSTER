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
    @State var authorTaped: Bool = false
    @State var nameTaped: Bool = false

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 12) {
                Text("Rename a song")
                    .font(.quicksand(type: .bold700, size: 20))
                    .foregroundColor(.white)
                
                Text("Enter a new name for the song")
                    .font(.sfProDisplay(type: .regular400, size: 17))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .foregroundStyle(.gray)
                    .padding(.bottom, 12)
                
                CustomTextField(input: $authorName, text: "Author")
                    .padding(.bottom)
                
                CustomTextField(input: $songName, text: "Song name")
                    .padding(.bottom)
                
                HStack(spacing: 20) {
                    Button(action: {
                        onCancel()
                    }) {
                        Text("Cancel")
                            .font(.sfProDisplay(type: .medium500, size: 16))
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 25)
                                    .stroke(Color.tabBarSelected, lineWidth: 1)
                            )
                    }
                    
                    Button(action: {
                        if !songName.isEmpty && !authorName.isEmpty {
                            onSave(authorName, songName)
                        }
                    }) {
                        Text("Save")
                            .font(.sfProDisplay(type: .medium500, size: 16))
                            .fontWeight(.medium)
                            .foregroundColor(.black)
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .padding()
                            .background(Color.tabBarSelected)
                            .cornerRadius(25)
                    }
                    .disabled(songName.isEmpty || authorName.isEmpty)
                }
                .padding(.horizontal)
            }
            .padding()
            .background(Color.customBlack)
            .cornerRadius(20)
            .shadow(radius: 10)
            .padding(.horizontal, 25)
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
