//
//  MainTabViewModel.swift
//  Bass Booster
//
//  Created by Protsak Dmytro on 29.09.2024.
//

import Foundation
import Combine
import SwiftUI

final class MainTabViewModel: ObservableObject {
    @Published var selectedIndex: Int = 0
    @Published var expandSheet: Bool = false

    private var dataManager = DataManager.shared
    private var cancellables = Set<AnyCancellable>()
    @State private var documentPickerManager: DocumentPickerManager?


    func presentDocumentPicker() {
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = scene.windows.first?.rootViewController {
            let manager = DocumentPickerManager { urls in
                self.dataManager.handlePickedFiles(urls: urls)
            }
            manager.showDocumentPicker()
            // Удерживаем сильную ссылку на менеджер
            self.documentPickerManager = manager
        }
    }
}
