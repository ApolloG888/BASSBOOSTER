//
//  DeleteSongView.swift
//  Bass Booster
//
//  Created by Protsak Dmytro on 11.10.2024.
//

import SwiftUI

struct DeleteSongView: View {
    @Binding var isPresented: Bool
    var songName: String
    var onConfirm: () -> Void
    var onCancel: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 12) {
                Text("Delete a song")
                    .font(.quicksand(type: .bold700, size: 20))
                    .foregroundStyle(.white)
                
                Text("Delete \(songName) ?")
                    .font(.sfProDisplay(type: .regular400, size: 15))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .foregroundStyle(.gray)
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
                        onConfirm()
                    }) {
                        Text("Delete")
                            .font(.sfProDisplay(type: .medium500, size: 16))
                            .fontWeight(.medium)
                            .foregroundColor(.black)
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .padding()
                            .background(Color.tabBarSelected)
                            .cornerRadius(25)
                    }
                }
                .padding(.horizontal)
            }
            .padding()
            .background(Color(.black))
            .cornerRadius(20)
            .shadow(radius: 10)
            .padding(.horizontal, 25)
        }
    }
}

struct DeleteSongView_Previews: PreviewProvider {
    static var previews: some View {
        DeleteSongView(
            isPresented: .constant(true),
            songName: "Sample Song",
            onConfirm: {},
            onCancel: {}
        )
    }
}
