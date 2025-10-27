//
//  TypeListView.swift
//  Pokedex
//
//  Created on 2025-10-08.
//

import SwiftUI

/// タイプバッジを横並びに表示するビュー
struct TypeListView: View {
    let types: [String]

    var body: some View {
        if types.isEmpty {
            Text(L10n.PokemonDetail.none)
                .foregroundColor(.secondary)
        } else {
            FlowLayout(spacing: 4) {
                ForEach(types, id: \.self) { typeName in
                    TypeBadge(typeName: typeName)
                }
            }
        }
    }
}

/// FlowLayout - 横並びで自動折り返しするレイアウト
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x, y: bounds.minY + result.positions[index].y), proposal: .unspecified)
        }
    }

    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)

                if currentX + size.width > maxWidth && currentX > 0 {
                    // 次の行へ
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }

                positions.append(CGPoint(x: currentX, y: currentY))
                currentX += size.width + spacing
                lineHeight = max(lineHeight, size.height)
            }

            self.size = CGSize(width: maxWidth, height: currentY + lineHeight)
        }
    }
}

/// タイプバッジ
struct TypeBadge: View {
    let typeName: String
    @EnvironmentObject private var localizationManager: LocalizationManager

    var body: some View {
        Text(localizationManager.displayName(forTypeName: typeName))
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(typeColor(typeName))
            .cornerRadius(4)
    }

    private func typeColor(_ typeName: String) -> Color {
        let colorMap: [String: Color] = [
            "normal": Color(red: 0.66, green: 0.66, blue: 0.47),
            "fire": Color(red: 0.93, green: 0.51, blue: 0.19),
            "water": Color(red: 0.39, green: 0.56, blue: 0.93),
            "electric": Color(red: 0.98, green: 0.82, blue: 0.17),
            "grass": Color(red: 0.47, green: 0.78, blue: 0.30),
            "ice": Color(red: 0.60, green: 0.85, blue: 0.85),
            "fighting": Color(red: 0.75, green: 0.19, blue: 0.15),
            "poison": Color(red: 0.64, green: 0.25, blue: 0.64),
            "ground": Color(red: 0.89, green: 0.75, blue: 0.42),
            "flying": Color(red: 0.66, green: 0.56, blue: 0.95),
            "psychic": Color(red: 0.98, green: 0.33, blue: 0.45),
            "bug": Color(red: 0.66, green: 0.71, blue: 0.13),
            "rock": Color(red: 0.71, green: 0.63, blue: 0.41),
            "ghost": Color(red: 0.44, green: 0.35, blue: 0.60),
            "dragon": Color(red: 0.44, green: 0.21, blue: 0.98),
            "dark": Color(red: 0.44, green: 0.35, blue: 0.30),
            "steel": Color(red: 0.71, green: 0.71, blue: 0.82),
            "fairy": Color(red: 0.85, green: 0.51, blue: 0.68)
        ]
        return colorMap[typeName] ?? .gray
    }
}

#Preview {
    VStack(spacing: 20) {
        TypeListView(types: ["fire", "flying"])
        TypeListView(types: ["water", "ice", "psychic", "dragon", "fairy"])
        TypeListView(types: [])
    }
    .padding()
    .environmentObject(LocalizationManager.shared)
}
