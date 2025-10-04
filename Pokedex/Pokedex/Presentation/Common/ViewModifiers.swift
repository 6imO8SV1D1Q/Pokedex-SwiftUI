//
//  ViewModifiers.swift
//  Pokedex
//
//  Created on 2025-10-04.
//

import SwiftUI

// MARK: - Card Style
struct CardStyle: ViewModifier {
    var cornerRadius: CGFloat = 12
    var shadowRadius: CGFloat = 4
    var shadowOpacity: Double = 0.1

    func body(content: Content) -> some View {
        content
            .background(Color(.systemBackground))
            .cornerRadius(cornerRadius)
            .shadow(color: .black.opacity(shadowOpacity), radius: shadowRadius, x: 0, y: 2)
    }
}

extension View {
    func cardStyle(
        cornerRadius: CGFloat = 12,
        shadowRadius: CGFloat = 4,
        shadowOpacity: Double = 0.1
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
            .background(Color.gray.opacity(0.05))
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
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(type.color)
            .foregroundColor(.white)
            .cornerRadius(4)
    }
}

extension View {
    func typeBadgeStyle(_ type: PokemonType, fontSize: CGFloat = 12) -> some View {
        modifier(TypeBadgeStyle(type: type, fontSize: fontSize))
    }
}
