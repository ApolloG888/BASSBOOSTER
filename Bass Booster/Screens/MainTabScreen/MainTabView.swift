import SwiftUI

struct MainTabView: View {
    
    @State private var selectedIndex = 0
    
    var body: some View {
        VStack {
            screens
            Spacer()
            tabBarPanel
        }
        .hideNavigationBar()
        .background(Color.customBlack)
    }
}

// MARK: - Screen

extension MainTabView {
    @MainActor
    var screens: some View {
        guard let screenState = MainTabScreenState(rawValue: selectedIndex) else {
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
                // Action for the plus button
            }) {
                ZStack {
                    Circle()
                        .fill(plusButtonGradient())
                        .frame(width: 56, height: 56)
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

// MARK: - Private Methods

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
