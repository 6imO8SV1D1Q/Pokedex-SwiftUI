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
    let regionalForm: PokemonForm?  // リージョンフォームがある場合
    let onTap: (() -> Void)?
    @EnvironmentObject private var localizationManager: LocalizationManager

    init(node: EvolutionNode, regionalForm: PokemonForm? = nil, onTap: (() -> Void)? = nil) {
        self.node = node
        self.regionalForm = regionalForm
        self.onTap = onTap
    }

    var body: some View {
        VStack(spacing: 4) {
            // ポケモン画像（リージョンフォームがあればそちらを優先）
            AsyncImage(url: URL(string: displayImageUrl)) { image in
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

            // ポケモン名（日本語）
            Text(displayName)
                .font(.caption)
                .fontWeight(.medium)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            // タイプバッジ（リージョンフォームがあればそちらのタイプ）
            HStack(spacing: 2) {
                ForEach(displayTypes, id: \.self) { typeName in
                    TypeBadge(typeName: typeName)
                        .font(.system(size: 8))
                }
            }
        }
        .frame(width: 100, height: 140)
        .padding(8)
        .background(Color(.systemGray6))
        .cornerRadius(8)
        .conditionalTapGesture(onTap: onTap)
    }

    /// 表示名（言語設定に応じた名前）
    private var displayName: String {
        switch localizationManager.currentLanguage {
        case .japanese:
            return node.nameJa ?? node.name.capitalized
        case .english:
            return node.name.capitalized
        }
    }

    /// 表示する画像URL（リージョンフォームがあればそちらを優先）
    private var displayImageUrl: String {
        if let regionalForm = regionalForm,
           let url = regionalForm.sprites.other?.home?.frontDefault ?? regionalForm.sprites.frontDefault {
            return url
        }
        return node.imageUrl ?? ""
    }

    /// 表示するタイプ（リージョンフォームがあればそちらのタイプ）
    private var displayTypes: [String] {
        if let regionalForm = regionalForm {
            return regionalForm.types.map { $0.name }
        }
        return node.types
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
            name: "bulbasaur",
            nameJa: "フシギダネ",
            imageUrl: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/home/1.png",
            types: ["grass", "poison"],
            evolvesTo: [],
            evolvesFrom: nil
        )
    )
    .environmentObject(LocalizationManager.shared)
}
