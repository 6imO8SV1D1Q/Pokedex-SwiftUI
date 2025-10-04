//
//  DesignConstants.swift
//  Pokedex
//
//  Created on 2025-10-04.
//

import SwiftUI

// MARK: - デザイン定数
enum DesignConstants {
    // MARK: - Spacing
    enum Spacing {
        static let xxSmall: CGFloat = 4
        static let xSmall: CGFloat = 8
        static let small: CGFloat = 12
        static let medium: CGFloat = 16
        static let large: CGFloat = 20
        static let xLarge: CGFloat = 24
        static let xxLarge: CGFloat = 32
    }

    // MARK: - Corner Radius
    enum CornerRadius {
        static let small: CGFloat = 4
        static let medium: CGFloat = 8
        static let large: CGFloat = 12
        static let xLarge: CGFloat = 16
    }

    // MARK: - Shadow
    enum Shadow {
        static let small: CGFloat = 2
        static let medium: CGFloat = 4
        static let large: CGFloat = 8
        static let opacity: Double = 0.1
    }

    // MARK: - Image Size
    enum ImageSize {
        static let small: CGFloat = 60
        static let medium: CGFloat = 80
        static let large: CGFloat = 100
        static let xLarge: CGFloat = 120
    }

    // MARK: - Grid
    enum Grid {
        static let columns: Int = 3
        static let spacing: CGFloat = Spacing.medium
    }
}
