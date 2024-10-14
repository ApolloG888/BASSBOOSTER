import SwiftUI

struct FeaturesView: View {
    @EnvironmentObject var viewModel: MusicViewModel
    
    var body: some View {
        VStack {
            header
            toggles
            Spacer()
        }
        .hideNavigationBar()
        .padding()
        .appGradientBackground()
    }
}

// MARK: - Header

extension FeaturesView {
    var header: some View {
        VStack {
            HStack {
                Text("Features")
                    .font(.sfProDisplay(type: .medium500, size: 32))
                    .foregroundColor(.white)
                Spacer()
            }
            .padding(.bottom, Space.xs)
            
            HStack {
                Text("Customize the sound yourself")
                    .font(.sfProText(type: .regular400, size: 14))
                    .foregroundColor(.white.opacity(0.5))
                Spacer()
            }
            .padding(.bottom, Space.xl)
        }
    }
}

// MARK: - Toggles

extension FeaturesView {
    var toggles: some View {
        VStack {
            Toggle(isOn: $viewModel.isQuietSoundSelected, label: {
                Text(Features.quietSounds.rawValue)
                    .font(.sfProText(type: .medium500, size: 15))
            })
           
            Toggle(isOn: $viewModel.isSuppressionSelected, label: {
                Text(Features.noiseSuppression.rawValue)
                    .font(.sfProText(type: .medium500, size: 15))
            })
        }
        .toggleStyle(CustomToggleStyle(gradient: selectionButtonGradient()))
    }
}
