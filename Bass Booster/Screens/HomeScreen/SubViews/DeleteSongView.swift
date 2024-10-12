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

            VStack(spacing: 20) {
                Text("Delete Song")
                    .font(.headline)
                
                Text("Are you sure you want to delete \"\(songName)\"?")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                HStack {
                    Button(action: {
                        onCancel()
                    }) {
                        Text("Cancel")
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)

                    Button(action: {
                        onConfirm()
                    }) {
                        Text("Delete")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                    }
                    .padding()
                    .background(Color.red)
                    .cornerRadius(10)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(20)
            .shadow(radius: 10)
            .padding(.horizontal, 40)
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
