//
//  ViewModifiers.swift
//  Pokedex
//
//  Created on 2025-10-04.
//

import SwiftUI

// MARK: - Card Style
struct CardStyle: ViewModifier {
    var cornerRadius: CGFloat = DesignConstants.CornerRadius.large
    var shadowRadius: CGFloat = DesignConstants.Shadow.medium
    var shadowOpacity: Double = DesignConstants.Shadow.opacity

    func body(content: Content) -> some View {
        content
            .background(Color(.systemBackground))
            .cornerRadius(cornerRadius)
            .shadow(color: .black.opacity(shadowOpacity), radius: shadowRadius, x: 0, y: 2)
    }
}

extension View {
    func cardStyle(
        cornerRadius: CGFloat = DesignConstants.CornerRadius.large,
        shadowRadius: CGFloat = DesignConstants.Shadow.medium,
        shadowOpacity: Double = DesignConstants.Shadow.opacity
    ) -> some View {
        modifier(CardStyle(
            cornerRadius: cornerRadius,
            shadowRadius: shadowRadius,
            shadowOpacity: shadowOpacity
        ))
    }
}

// MARK: - Pokemon Image Style
struct PokemonImageStyle: ViewModifier {
    var size: CGFloat
    var clipShape: Bool = true

    func body(content: Content) -> some View {
        content
            .frame(width: size, height: size)
            .background(Color(.quaternarySystemFill))
            .if(clipShape) { view in
                view.clipShape(Circle())
            }
    }
}

extension View {
    func pokemonImageStyle(size: CGFloat, clipShape: Bool = true) -> some View {
        modifier(PokemonImageStyle(size: size, clipShape: clipShape))
    }

    // 条件付きモディファイア用のヘルパー
    @ViewBuilder
    func `if`<Transform: View>(
        _ condition: Bool,
        transform: (Self) -> Transform
    ) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

// MARK: - Type Badge Style
struct TypeBadgeStyle: ViewModifier {
    let type: PokemonType
    var fontSize: CGFloat = 12

    func body(content: Content) -> some View {
        content
            .font(.system(size: fontSize))
            .fontWeight(.semibold)
            .frame(minWidth: minWidth)
            .padding(.horizontal, DesignConstants.Spacing.xSmall)
            .padding(.vertical, DesignConstants.Spacing.xxSmall)
            .background(type.color)
            .foregroundColor(type.textColor)
            .cornerRadius(DesignConstants.CornerRadius.small)
    }

    /// フォントサイズに応じた最小幅
    private var minWidth: CGFloat {
        fontSize * 4.5  // 12pt → 54pt, 9pt → 40.5pt
    }
}

extension View {
    func typeBadgeStyle(_ type: PokemonType, fontSize: CGFloat = 12) -> some View {
        modifier(TypeBadgeStyle(type: type, fontSize: fontSize))
    }
}

// MARK: - Grid Item Button Style
struct GridItemButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}
