//
//  EvolutionNodeCard.swift
//  Pokedex
//
//  Created on 2025-10-08.
//

import SwiftUI

/// 進化ツリーのノードカード
struct EvolutionNodeCard: View {
    let node: EvolutionNode
    let onTap: (() -> Void)?

    init(node: EvolutionNode, onTap: (() -> Void)? = nil) {
        self.node = node
        self.onTap = onTap
    }

    var body: some View {
        VStack(spacing: 8) {
            // ポケモン画像
            AsyncImage(url: URL(string: node.imageUrl ?? "")) { image in
                image
                    .resizable()
                    .scaledToFit()
            } placeholder: {
                Color.gray.opacity(0.2)
            }
            .frame(width: 80, height: 80)

            // 図鑑番号
            Text(String(format: "#%03d", node.speciesId))
                .font(.caption2)
                .foregroundColor(.secondary)

            // ポケモン名
            Text(node.name)
                .font(.caption)
                .fontWeight(.medium)
                .lineLimit(1)

            // タイプバッジ
            HStack(spacing: 2) {
                ForEach(node.types, id: \.self) { typeName in
                    TypeBadge(typeName: typeName)
                        .font(.system(size: 8))
                }
            }
        }
        .padding(8)
        .background(Color(.systemGray6))
        .cornerRadius(8)
        .conditionalTapGesture(onTap: onTap)
    }
}

// onTapがある場合のみonTapGestureを追加するヘルパー
extension View {
    @ViewBuilder
    func conditionalTapGesture(onTap: (() -> Void)?) -> some View {
        if let onTap = onTap {
            self.onTapGesture(perform: onTap)
        } else {
            self
        }
    }
}

#Preview {
    EvolutionNodeCard(
        node: EvolutionNode(
            id: 1,
            speciesId: 1,
            name: "フシギダネ",
            imageUrl: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/home/1.png",
            types: ["grass", "poison"],
            evolvesTo: [],
            evolvesFrom: nil
        )
    )
}
