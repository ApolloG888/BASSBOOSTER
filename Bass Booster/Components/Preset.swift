//
//  PresetView.swift
//  Bass Booster
//
//  Created by Mac Book Air M1 on 14.10.2024.
//

import SwiftUI

enum MusicPreset: String, CaseIterable {
    case rock = "Rock"
    case rnb = "R&B"
    case pop = "Pop"
    case classic = "Classic"
    case rap = "Rap"
}

struct Preset: Identifiable {
    var id: ObjectIdentifier
    var name: String
}

struct PresetButton: View {
    let preset: Preset
    let isSelected: Bool
    
    var body: some View {
        Text(preset.name)
            .font(.quicksand(size: 14))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? Color.placeholderYellow.opacity(0.15) : Color.playlistTF.opacity(0.2))
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? Color.yellow : Color.clear, lineWidth: 1)
            )
            .foregroundColor(.white)
    }
}


struct AddButton: View {
    @State var isSelected: Bool
    var action: () -> Void
    
    var body: some View {
        HStack(spacing: 8) {
            Text("Add")
                .font(.quicksand(size: 14))
                .foregroundColor(isSelected ? .black : .gray)
            
            Image(systemName: "plus")
                .foregroundColor(isSelected ? .black : .gray)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(isSelected ? Color.placeholderYellow : Color.gray.opacity(0.5))
        .cornerRadius(20)
        .onTapGesture {
            action()
        }
    }
}
