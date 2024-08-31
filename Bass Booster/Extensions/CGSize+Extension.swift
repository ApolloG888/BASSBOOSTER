//
//  CGSize+Extension.swift
//  Bass Booster
//
//  Created by Дмитрий Процак on 31.08.2024.
//

import Foundation

extension CGSize {
    init(square side: CGFloat) {
        self.init(width: side, height: side)
    }
}
