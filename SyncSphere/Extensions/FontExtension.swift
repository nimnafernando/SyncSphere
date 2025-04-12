//
//  FontExtension.swift
//  SyncSphere
//
//  Created by Rashmi Liyanawadu on 2025-04-09.
//

import SwiftUI

extension Font {
    static func poppins(style: TextStyle = .body, weight: Weight = .regular) -> Font {
        let fontName = CustomFont(weight: weight).rawValue
        let size = style.size
        return .custom(fontName, size: size)
    }
}

extension Font.TextStyle {
    var size: CGFloat {
        switch self {
        case .largeTitle: return 34
        case .title: return 28
        case .title2: return 22
        case .title3: return 20
        case .headline: return 17
        case .body: return 16
        case .callout: return 15
        case .subheadline: return 14
        case .footnote: return 13
        case .caption: return 12
        case .caption2: return 11
        @unknown default: return 14
        }
    }
}

enum CustomFont: String {
    case regular = "Amulya-Regular"
    case medium = "Amulya-Medium"
    case light = "Amulya-Light"
    case bold = "Amulya-Bold"

    init(weight: Font.Weight) {
        switch weight {
        case .regular:
            self = .regular
        case .medium:
            self = .medium
        case .light:
            self = .light
        case .bold:
            self = .bold
        default:
            self = .regular
        }
    }
}
