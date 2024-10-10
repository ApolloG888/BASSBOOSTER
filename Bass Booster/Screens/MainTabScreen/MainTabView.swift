import SwiftUI

struct MainTabView: View {
    @State private var selectedIndex = 0
    @State private var expandSheet = false
    @Namespace private var animation
    @State private var documentPickerManager: DocumentPickerManager?

    var body: some View {
        ZStack {
            TabView(selection: $selectedIndex) {
                HomeAssembly().build()
                    .tabItem {
                        TabBarButton(
                            icon: "Home",
                            isSelected: selectedIndex == 1,
                            label: "Home"
                        ) {
                            selectedIndex = 1
                        }
                    }
                    .tag(0)
                
                ModesAssembly().build()
                    .tabItem {
                        TabBarButton(
                            icon: "modes",
                            isSelected: selectedIndex == 2,
                            label: "Modes"
                        ) {
                            selectedIndex = 2
                        }
                    }
                    .tag(1)
                
                Spacer()
                    .tabItem {
                        EmptyView()
                    }
                    .tag(2)
                
                FeaturesAssembly().build()
                    .tabItem {
                        TabBarButton(
                            icon: "features",
                            isSelected: selectedIndex == 3,
                            label: "Features"
                        ) {
                            selectedIndex = 3
                        }
                    }
                    .tag(3)
                
                SettingsAssembly().build()
                    .tabItem {
                        TabBarButton(
                            icon: "settings",
                            isSelected: selectedIndex == 4,
                            label: "Features"
                        ) {
                            selectedIndex = 4
                        }
                    }
                    .tag(4)
            }
            
            VStack {
                Spacer()
                CustomBottomSheet()
                Button {
                    presentDocumentPicker()
                } label: {
                    ZStack {
                        Circle()
                            .fill(plusButtonGradient())
                            .frame(
                                width: 56,
                                height: 56
                            )
                            .overlay(
                                Circle()
                                    .stroke(
                                        plusButtonBorderGradient(),
                                        lineWidth: 0.66
                                    )
                            )
                        Image(systemName: "plus")
                            .resizable()
                            .renderingMode(.template)
                            .foregroundColor(.white)
                            .frame(size: Size.l)
                    }
                    .frame(width: 55, height: 55)
                }
                .ignoresSafeArea(.keyboard)
            }
            .ignoresSafeArea(.keyboard)
            
        }
        .hideNavigationBar()
        .background(Color.customBlack)
        .overlay {
            if expandSheet {
                MusicView(expandSheet: $expandSheet, animation: animation)
            }
        }
    }

    // MARK: - CustomBottomSheet

    @ViewBuilder
    func CustomBottomSheet() -> some View {
        ZStack {
            if expandSheet {
                Rectangle()
                    .fill(Color.red)
            } else {
                Rectangle()
                    .fill(.musicInfoColor)
                    .overlay {
                        MusicInfo(expandSheet: $expandSheet, state: .pause, animation: animation)
                    }
                    .matchedGeometryEffect(id: "BACKGROUNDVIEW", in: animation)
            }
        }
        .appGradientBackground()
        .frame(height: 70)
        .ignoresSafeArea(.keyboard)
    }

    // MARK: - Private Methods

    private func presentDocumentPicker() {
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = scene.windows.first?.rootViewController {
            let manager = DocumentPickerManager { urls in
                DataManager.shared.handlePickedFiles(urls: urls)
            }
            manager.showDocumentPicker()
            // Удерживаем сильную ссылку на менеджер, чтобы он не был деинициализирован
            self.documentPickerManager = manager
        }
    }
}

#Preview {
    MainTabView()
}
