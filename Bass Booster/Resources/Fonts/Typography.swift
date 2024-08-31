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

enum SFProDisplayFont: String {
    case regular400 = "SFProDisplay-Regular"
    case medium500 = "SFProDisplay-Medium"
    case semiBold600 = "SFProDisplay-Semibold"
}

extension Font {
    static func sfProText(type: SFProTextFont = .regular400, size: CGFloat) -> Font {
        return Font.custom(type.rawValue, size: size)
    }
    
    static func sfProDisplay(type: SFProDisplayFont = .regular400, size: CGFloat) -> Font {
        return Font.custom(type.rawValue, size: size)
    }
}
