//
//  Typography.swift
//  Bass Booster
//
//  Created by Дмитрий Процак on 31.08.2024.
//

import SwiftUI

enum SFProTextFont: String {
    case light300 = "SFProText-Light"
    case regular400 = "SFProText-Regular"
    case medium500 = "SFProText-Medium"
    case semiBold600 = "SFProText-Semibold"
    case bold700 = "SFProText-Bold"
}

enum SFProDisplayFont: String {
    case regular400 = "SF-Pro-Display-Regular"
    case medium500 = "SF-Pro-Display-Medium"
    case semiBold600 = "SF-Pro-Display-Semibold"
    case bold700 = "SF-Pro-Display-Bold"
}

enum HelveticaNeueFont: String {
    case regular400 = "Helvetica"
    case medium500 = "HelveticaNeueCyr-Medium"
}

enum QuickSandFont: String {
    case bold700 = "Quicksand-Bold"
}

extension Font {
    static func sfProText(type: SFProTextFont = .regular400, size: CGFloat) -> Font {
        return Font.custom(type.rawValue, size: size)
    }
    
    static func sfProDisplay(type: SFProDisplayFont = .regular400, size: CGFloat) -> Font {
        return Font.custom(type.rawValue, size: size)
    }
    
    static func helvetica(type: HelveticaNeueFont = .regular400, size: CGFloat) -> Font {
        return Font.custom(type.rawValue, size: size)
    }
    
    static func quicksand(type: QuickSandFont = .bold700, size: CGFloat) -> Font {
        return Font.custom(type.rawValue, size: size)
    }
}
