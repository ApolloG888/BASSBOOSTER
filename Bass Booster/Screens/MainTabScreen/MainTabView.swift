import SwiftUI

struct MainTabView: View {
    @State private var selectedIndex = 0
    @State private var expandSheet = false
    @Namespace private var animation
    @State private var documentPickerManager: DocumentPickerManager?

    var body: some View {
        VStack {
            screens
            Spacer()
            CustomBottomSheet()
            tabBarPanel
        }
        .overlay {
            if expandSheet {
                // Ваш код для расширенного представления музыкального плеера
                MusicView(expandSheet: $expandSheet, animation: animation)
            }
        }
        .hideNavigationBar()
        .background(Color.customBlack)
    }

    // MARK: - Screen

    @MainActor
    var screens: some View {
        guard let screenState = MainTabScreenState(rawValue: selectedIndex) else {
            return AnyView(EmptyView())
        }
        return AnyView(screenState.viewBuilder)
    }

    // MARK: - CustomBottomSheet

    @ViewBuilder
    func CustomBottomSheet() -> some View {
        ZStack {
            if expandSheet {
                Rectangle()
                    .fill(Color.clear)
            } else {
                Rectangle()
                    .fill(.ultraThickMaterial)
                    .overlay {
                        // Информация о музыке
                        MusicInfo(expandSheet: $expandSheet, animation: animation)
                    }
                    .clipShape(.rect(topLeadingRadius: 30, topTrailingRadius: 30))
                    .matchedGeometryEffect(id: "BACKGROUNDVIEW", in: animation)
            }
        }
        .frame(height: 80)
    }

    // MARK: - TabBarPanel

    var tabBarPanel: some View {
        ZStack {
            HStack {
                tabBarButtonGroup(
                    from: MainTabScreenState.allCases.prefix(2),
                    spacing: Space.xl3,
                    padding: .leading(Space.xl3)
                )
                Spacer()
                tabBarButtonGroup(
                    from: MainTabScreenState.allCases.suffix(2),
                    spacing: Space.xl,
                    padding: .trailing(Space.xl)
                )
            }
            Button(action: {
                presentDocumentPicker()
            }) {
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
            }
        }
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

    private func tabBarButtonGroup(
        from tabs: ArraySlice<MainTabScreenState>,
        spacing: CGFloat,
        padding: EdgeInsets
    ) -> some View {
        HStack(spacing: spacing) {
            ForEach(tabs, id: \.self) { tab in
                TabBarButton(
                    icon: tab.icon,
                    isSelected: selectedIndex == tab.rawValue,
                    label: tab.name
                ) {
                    selectedIndex = tab.rawValue
                }
            }
        }
        .padding(padding)
    }
}

#Preview {
    MainTabView()
}
