//
//  HomeView.swift
//  Bass Booster
//
//  Created by Mac Book Air M1 on 04.09.2024.
//

import SwiftUI

struct HomeView: View {
    @StateObject var viewModel: HomeViewModel
    
    var body: some View {
        VStack {
            HStack {
                Text("My Player")
                    .font(.sfProDisplay(type: .medium500, size: 32))
                    .foregroundColor(.white)
                Spacer()
            }
            .padding(.bottom, 8)
            
            SearchBarView {
                
            }
            PlaylistView(state: .createNew)
            Spacer()
        }
        .padding()
        .appGradientBackground()
    }
}

#Preview {
    HomeView(viewModel: HomeViewModel())
}
