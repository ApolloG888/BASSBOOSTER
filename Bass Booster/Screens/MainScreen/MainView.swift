import SwiftUI

struct MainView: View {
    var body: some View {
        CustomTabView()
            .background(Color.customBlack)
    }
}

struct CustomTabView: View {
    @State private var selectedIndex = 0
    
    var body: some View {
        VStack {
            ZStack {
                switch selectedIndex {
                case MainScreenTabState.home.rawValue:
                    OnboardingAssembly().build()
                case MainScreenTabState.modes.rawValue:
                    ModesAssembly().build()
                case MainScreenTabState.features.rawValue:
                    ThirdView()
                case MainScreenTabState.settings.rawValue:
                    FourthView()
                default:
                    FirstView()
                }
            }
            Spacer()
            
            ZStack {
                HStack {
                    HStack(spacing: 36) {
                        ForEach(MainScreenTabState.allCases.prefix(2), id: \.self) { tab in
                            TabBarButton(icon: tab.icon, isSelected: selectedIndex == tab.rawValue, label: tab.name) {
                                selectedIndex = tab.rawValue
                            }
                        }
                    }
                    .padding(.leading, 36)
                    
                    Spacer()
                    
                    HStack(spacing: 24) {
                        ForEach(MainScreenTabState.allCases.suffix(2), id: \.self) { tab in
                            TabBarButton(icon: tab.icon, isSelected: selectedIndex == tab.rawValue, label: tab.name) {
                                selectedIndex = tab.rawValue
                            }
                        }
                    }
                    .padding(.trailing, 24)
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
                                    .stroke(plusButtonBorderGradient(), lineWidth: 0.66))
                        Image(systemName: "plus")
                            .resizable()
                            .renderingMode(.template)
                            .foregroundColor(.white)
                            .frame(width: 21, height: 21)
                    }
                }
            }
        }
    }
}

// Экраны
struct FirstView: View {
    var body: some View {
        Text("Home Screen")
            .foregroundColor(.white)
            .font(.largeTitle)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.red)
    }
}

struct SecondView: View {
    var body: some View {
        VStack {
            Toggle(isOn: .constant(true), label: {
                Text("Music")
                    .foregroundStyle(.white)
                    .font(.sfProText(size: 30))
            })
            .toggleStyle(CustomToggleStyle())
        }
    }
}

struct ThirdView: View {
    var body: some View {
        Text("Favorites Screen")
            .foregroundColor(.white)
            .font(.largeTitle)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.orange)
    }
}

struct FourthView: View {
    var body: some View {
        Text("Profile Screen")
            .foregroundColor(.white)
            .font(.largeTitle)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.purple)
    }
}

struct TabBarButton: View {
    let icon: String
    let isSelected: Bool
    let label: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Circle()
                    .frame(width: 6, height: 6)
                    .foregroundColor(isSelected ? .tabBarSelected : .clear)
                Image(icon)
                    .resizable()
                    .renderingMode(.template)
                    .frame(width: 24, height: 24)
                    .foregroundColor(isSelected ? .tabBarSelected : .gray)
                Text(label)
                    .font(.caption)
                    .foregroundColor(isSelected ? .tabBarSelected : .gray)
            }
        }
    }
}


#Preview {
    MainView()
}
