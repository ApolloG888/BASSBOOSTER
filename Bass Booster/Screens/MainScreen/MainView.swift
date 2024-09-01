//
//  MainView.swift
//  Bass Booster
//
//  Created by Дмитрий Процак on 01.09.2024.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        CustomTabView()
            .background(Color.customBlack.ignoresSafeArea())
    }
}

struct CustomTabView: View {
    @State private var selectedIndex = 0

    var body: some View {
        VStack {
            // Отображение выбранного экрана
            ZStack {
                switch selectedIndex {
                case 0:
                    OnboardingAssembly().build()
                case 1:
                    SecondView()
                case 2:
                    ThirdView()
                case 3:
                    FourthView()
                default:
                    FirstView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            Spacer()
            
            ZStack {
                HStack {
                    Spacer()
                    
                    // Первый экран
                    TabBarButton(icon: "house.fill", isSelected: selectedIndex == 0) {
                        selectedIndex = 0
                    }
                    
                    Spacer()
                    
                    // Второй экран
                    TabBarButton(icon: "magnifyingglass", isSelected: selectedIndex == 1) {
                        selectedIndex = 1
                    }
                    
                    Spacer()
                    
                    // Пустое пространство для кнопки "плюс"
                    Spacer().frame(width: 80)
                    
                    // Третий экран
                    TabBarButton(icon: "heart.fill", isSelected: selectedIndex == 2) {
                        selectedIndex = 2
                    }
                    
                    Spacer()
                    
                    // Четвертый экран
                    TabBarButton(icon: "person.fill", isSelected: selectedIndex == 3) {
                        selectedIndex = 3
                    }
                    
                    Spacer()
                }
                
                // Кнопка "плюс" по центру
                Button(action: {
                    // Действие по нажатию на кнопку "плюс"
                }) {
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .frame(width: 70, height: 70)
                        .foregroundColor(.white)
                        .background(Circle().fill(Color.blue).shadow(radius: 10))
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
            Image(systemName: icon)
                .resizable()
                .frame(width: 25, height: 25)
                .foregroundColor(isSelected ? .white : .gray)
        }
    }
}

#Preview {
    MainView()
}
