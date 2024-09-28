//
//  HomeViewModel.swift
//  Bass Booster
//
//  Created by Mac Book Air M1 on 04.09.2024.
//

import Foundation
import SwiftUI
import CoreData

final class HomeViewModel: ObservableObject {
    @ObservedObject var dataManager = DataManager.shared

    var musicFiles: [MusicFileEntity] {
        dataManager.savedFiles
    }

    func fetchSavedMusicFiles() {
        dataManager.fetchMusicFiles()
    }

    func deleteMusicFile(at offsets: IndexSet) {
        for index in offsets {
            let musicFile = musicFiles[index]
            dataManager.deleteMusicFile(musicFile)
        }
    }
}
