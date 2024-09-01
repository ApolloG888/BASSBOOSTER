import SwiftUI

enum TabState: Int, CaseIterable {
    case home = 0
    case modes
    case features
    case settings
    
    var icon: String {
        switch self {
        case .home:
            return "home"
        case .modes:
            return "modes"
        case .features:
            return "features"
        case .settings:
            return "settings"
        }
    }
}

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
            // Отображение выбранного экрана
            ZStack {
                switch selectedIndex {
                case TabState.home.rawValue:
                    OnboardingAssembly().build()
                case TabState.modes.rawValue:
                    SecondView()
                case TabState.features.rawValue:
                    ThirdView()
                case TabState.settings.rawValue:
                    FourthView()
                default:
                    FirstView()
                }
            }
            Spacer()
            
            ZStack {
                HStack {
                    Spacer()
                    
                    ForEach(TabState.allCases, id: \.self) { tab in
                        TabBarButton(icon: tab.icon, isSelected: selectedIndex == tab.rawValue) {
                            selectedIndex = tab.rawValue
                        }
                        Spacer()
                        
                        // Если это второй элемент, добавляем больший отступ
                        if tab == .modes {
                            Spacer().frame(width: 80) // Увеличенный отступ
                        }
                    }
                }
                
                // Кнопка "плюс" по центру
                Button(action: {
                    // Действие по нажатию на кнопку "плюс"
                }) {
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .frame(width: 56, height: 56)
                        .foregroundColor(.black)
                        .background(Circle().fill(Color.white).shadow(radius: 10))
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
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(icon)
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundColor(isSelected ? .white : .gray)
        }
    }
}

#Preview {
    MainView()
}
