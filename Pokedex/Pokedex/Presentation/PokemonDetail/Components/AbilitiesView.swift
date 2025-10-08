//
//  AbilitiesView.swift
//  Pokedex
//
//  Created on 2025-10-08.
//

import SwiftUI

/// 特性一覧を表示するビュー
struct AbilitiesView: View {
    let abilities: [PokemonAbility]
    let abilityDetails: [String: AbilityDetail]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("特性")
                .font(.headline)

            ForEach(abilities, id: \.name) { ability in
                AbilityCard(
                    ability: ability,
                    detail: abilityDetails[ability.name]
                )
            }
        }
        .padding()
    }
}

/// 個別特性カード
struct AbilityCard: View {
    let ability: PokemonAbility
    let detail: AbilityDetail?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                // 特性名
                Text(displayAbilityName)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                // 隠れ特性バッジ
                if ability.isHidden {
                    Text("隠れ特性")
                        .font(.caption2)
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.purple)
                        .cornerRadius(4)
                }

                Spacer()
            }

            // 特性の効果説明
            if let detail = detail {
                Text(detail.effect)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
            } else {
                // 詳細データがない場合
                Text("特性の詳細を読み込み中...")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .opacity(0.6)
                    .italic()
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }

    /// 特性名を日本語で表示
    private var displayAbilityName: String {
        // 特性の日本語名があればそれを使用、なければ英語名
        if let detail = detail, !detail.name.isEmpty {
            return detail.name
        }
        // フォールバック: 英語名を整形
        return ability.name
            .replacingOccurrences(of: "-", with: " ")
            .capitalized
    }
}

#Preview {
    AbilitiesView(
        abilities: [
            PokemonAbility(
                name: "overgrow",
                isHidden: false
            ),
            PokemonAbility(
                name: "chlorophyll",
                isHidden: true
            )
        ],
        abilityDetails: [
            "overgrow": AbilityDetail(
                id: 65,
                name: "しんりょく",
                effect: "HPが1/3以下のとき、くさタイプの技の威力が1.5倍になる。",
                flavorText: nil,
                isHidden: false
            ),
            "chlorophyll": AbilityDetail(
                id: 34,
                name: "ようりょくそ",
                effect: "天気が「ひざしがつよい」のとき、すばやさが2倍になる。",
                flavorText: nil,
                isHidden: true
            )
        ]
    )
}

#Preview("詳細なし") {
    AbilitiesView(
        abilities: [
            PokemonAbility(
                name: "overgrow",
                isHidden: false
            )
        ],
        abilityDetails: [:]
    )
}
