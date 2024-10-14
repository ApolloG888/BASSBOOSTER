import SwiftUI

struct PlaylistCell: View {
    var playlist: PlaylistEntity
    var onTap: () -> Void
    
    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.07), lineWidth: 2)
                    .frame(width: 48, height: 48)
                Image(.musicNote)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .foregroundColor(.playlistGrey)
            }
            .padding(.bottom, 8)
            
            Text(playlist.name ?? "Unknown")
                .font(.sfProDisplay(type: .regular400, size: 14))
                .foregroundColor(.gray)
        }
        .frame(width: 133, height: 133)
        .background(.customBlack)
        .cornerRadius(16)
        .onTapGesture {
            onTap()
        }
    }
}
