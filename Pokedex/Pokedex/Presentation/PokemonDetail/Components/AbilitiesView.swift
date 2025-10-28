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
    let currentLanguage: AppLanguage

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(abilities, id: \.name) { ability in
                AbilityCard(
                    ability: ability,
                    detail: abilityDetails[ability.name],
                    currentLanguage: currentLanguage
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
    let currentLanguage: AppLanguage

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                // 特性名
                Text(abilityDisplayName)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                // 隠れ特性バッジ
                if ability.isHidden {
                    Text(hiddenBadgeText)
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
                Text(detail.localizedEffect(language: currentLanguage))
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
            } else {
                // 詳細データがない場合
                Text(loadingText)
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

    /// 特性名を表示
    private var abilityDisplayName: String {
        // detailがあればlocalizedNameを使用、なければability.nameJaまたはability.nameを使用
        if let detail = detail {
            return detail.localizedName(language: currentLanguage)
        }

        switch currentLanguage {
        case .japanese:
            return ability.nameJa ?? ability.name
                .replacingOccurrences(of: "-", with: " ")
                .capitalized
        case .english:
            return ability.name
                .replacingOccurrences(of: "-", with: " ")
                .capitalized
        }
    }

    /// 隠れ特性バッジのテキスト
    private var hiddenBadgeText: String {
        switch currentLanguage {
        case .japanese:
            return "隠れ特性"
        case .english:
            return "Hidden"
        }
    }

    /// ローディングテキスト
    private var loadingText: String {
        switch currentLanguage {
        case .japanese:
            return "読み込み中..."
        case .english:
            return "Loading..."
        }
    }
}

#Preview {
    AbilitiesView(
        abilities: [
            PokemonAbility(
                name: "overgrow",
                nameJa: "しんりょく",
                isHidden: false
            ),
            PokemonAbility(
                name: "chlorophyll",
                nameJa: "ようりょくそ",
                isHidden: true
            )
        ],
        abilityDetails: [
            "overgrow": AbilityDetail(
                id: 65,
                name: "overgrow",
                nameJa: "しんりょく",
                effect: "Boosts Grass moves in a pinch.",
                effectJa: "HPが1/3以下のとき、くさタイプの技の威力が1.5倍になる。",
                flavorText: nil,
                isHidden: false
            ),
            "chlorophyll": AbilityDetail(
                id: 34,
                name: "chlorophyll",
                nameJa: "ようりょくそ",
                effect: "Boosts Speed in sunshine.",
                effectJa: "天気が「ひざしがつよい」のとき、すばやさが2倍になる。",
                flavorText: nil,
                isHidden: true
            )
        ],
        currentLanguage: .japanese
    )
}

#Preview("詳細なし") {
    AbilitiesView(
        abilities: [
            PokemonAbility(
                name: "overgrow",
                nameJa: "しんりょく",
                isHidden: false
            )
        ],
        abilityDetails: [:],
        currentLanguage: .japanese
    )
}
