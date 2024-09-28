//
//  DocumentPickerManager.swift
//  Bass Booster
//
//  Created by Protsak Dmytro on 28.09.2024.
//

import UIKit
import UniformTypeIdentifiers

final class DocumentPickerManager: NSObject, UIDocumentPickerDelegate {
    
    private var completion: ([URL]) -> Void
    
    init(completion: @escaping ([URL]) -> Void) {
        self.completion = completion
    }
    
    func showDocumentPicker() {
        let supportedTypes: [UTType] = [.audio]
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: supportedTypes, asCopy: true)
        
        picker.delegate = self
        picker.allowsMultipleSelection = true
        picker.modalPresentationStyle = .overFullScreen
        
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = scene.windows.first?.rootViewController {
            DispatchQueue.main.async {
                rootViewController.present(picker, animated: true, completion: nil)
            }
        }
    }
    
    // MARK: - UIDocumentPickerDelegate methods
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        completion(urls)
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        // Обработка отмены, если необходимо
    }
}
