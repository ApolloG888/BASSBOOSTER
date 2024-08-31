//
//  Typography.swift
//  Bass Booster
//
//  Created by Дмитрий Процак on 31.08.2024.
//

import SwiftUI

enum SFProTextFont: String {
    case regular400 = "SFProText-Regular"
    case medium500 = "SFProText-Medium"
    case semiBold600 = "SFProText-Semibold"
}

extension Font {
    static func sfProText(_ type: SFProTextFont = .regular400, size: CGFloat) -> Font {
        return Font.custom(type.rawValue, size: size)
    }
}
