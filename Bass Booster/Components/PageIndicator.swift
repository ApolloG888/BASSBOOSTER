import SwiftUI

struct PageIndicator: View {
    var currentPage: Int
    var totalPages: Int
    
    var body: some View {
        HStack(spacing: Space.xs) {
            ForEach(.zero..<totalPages, id: \.self) { index in
                if index == currentPage {
                    RoundedRectangle(cornerRadius: CornerRadius.xs)
                        .frame(width: Space.m, height: Space.xs)
                        .foregroundColor(.white)
                } else {
                    Circle()
                        .frame(size: Size.xs)
                        .foregroundColor(.gray)
                }
            }
        }
    }
}
