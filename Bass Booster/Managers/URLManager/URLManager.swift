//
//  URLManager.swift
//  Bass Booster
//
//  Created by Дмитрий Процак on 01.09.2024.
//

import UIKit
import SwiftUI
import Combine

protocol URLManagerProtocol {
    func open(urlString: String)
}

final class URLManager: ObservableObject, URLManagerProtocol {
    func open(urlString: String) {
        guard let url = URL(string: urlString) else {
            print("Invalid URL string: \(urlString)")
            return
        }
        UIApplication.shared.open(url)
    }
}
