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
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Text("Name a playlist")
                    .font(.quicksand(type: .bold700, size: 20))
                    .foregroundColor(.white)
                
                CustomTextField(input: $playlistName, text: "Playlist name")
                
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
                    
                    // Save Button
                    Button(action: {
                        if !playlistName.isEmpty {
                            onSave(playlistName)
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
                    .disabled(playlistName.isEmpty)
                }
                .padding(.horizontal)
            }
            .padding()
            .background(Color.customBlack)
            .cornerRadius(20)
            .shadow(radius: 10)
            .padding(.horizontal, 35)
        }
    }
}

struct NewPlaylistView_Previews: PreviewProvider {
    static var previews: some View {
        NewPlaylistView(isPresented: .constant(true), onSave: { _ in }, onCancel: {})
    }
}


struct CustomTextField: View {
    @Binding var input: String
    var text: String? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(text ?? "")
                .font(.sfProDisplay(type: .regular400, size: 12))
                .padding(.vertical, 6)
                .padding(.horizontal, 16)
                .foregroundColor(Color.gray)
            
            TextField("", text: $input)
                .font(.sfProDisplay(type: .regular400, size: 14))
                .foregroundColor(.white)
                .padding(.horizontal)
                .padding(.bottom)
                .tint(Color.tabBarSelected)
        }
        .background(Color.playlistTF.opacity(0.07))
        .cornerRadius(12)
        .frame(height: 48)
    }
}
