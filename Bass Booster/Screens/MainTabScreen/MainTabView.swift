import SwiftUI

struct MainTabView: View {
    @StateObject var viewModel: MainTabViewModel
    @Namespace private var animation
    
    var body: some View {
        VStack {
            screens
            musciBottomSheet()
            tabBarPanel
        }
        .overlay {
            if viewModel.expandSheet {
                MusicView(
                    expandSheet: $viewModel.expandSheet,
                    animation: animation
                )
            }
        }
        .hideNavigationBar()
        .background(Color.customBlack)
    }
    
    // MARK: - Screen
    
    @MainActor
    var screens: some View {
        guard let screenState = MainTabScreenState(rawValue: viewModel.selectedIndex) else {
            return AnyView(EmptyView())
        }
        return AnyView(screenState.viewBuilder)
    }
}

// MARK: - TabBarPanel

extension MainTabView {
    
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
                viewModel.presentDocumentPicker()
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
}


// MARK: - Music BottomSheet

extension MainTabView {
    
    @ViewBuilder
    func musciBottomSheet() -> some View {
        ZStack {
            if viewModel.expandSheet {
                Rectangle()
                    .fill(Color.clear)
            } else {
                Rectangle()
                    .fill(.musicInfoColor)
                    .overlay {
                        MusicInfo(
                            expandSheet: $viewModel.expandSheet,
                            state: .pause,
                            animation: animation
                        )
                    }
                    .matchedGeometryEffect(id: "BACKGROUNDVIEW", in: animation)
            }
        }
        .frame(height: 70)
    }
}

private extension MainTabView {
    
    func tabBarButtonGroup(
        from tabs: ArraySlice<MainTabScreenState>,
        spacing: CGFloat,
        padding: EdgeInsets
    ) -> some View {
        HStack(spacing: spacing) {
            ForEach(tabs, id: \.self) { tab in
                TabBarButton(
                    icon: tab.icon,
                    isSelected: viewModel.selectedIndex == tab.rawValue,
                    label: tab.name
                ) {
                    viewModel.selectedIndex = tab.rawValue
                }
            }
        }
        .padding(padding)
    }
}

#Preview {
    MainTabView(viewModel: MainTabViewModel())
}
