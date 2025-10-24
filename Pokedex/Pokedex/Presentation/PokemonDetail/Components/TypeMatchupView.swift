//
//  TypeMatchupView.swift
//  Pokedex
//
//  Created on 2025-10-08.
//

import SwiftUI

/// タイプ相性表示ビュー
struct TypeMatchupView: View {
    let matchup: TypeMatchup

    var body: some View {
        VStack(spacing: 12) {
            // 4倍弱点
            if !matchup.defensive.quadrupleWeak.isEmpty {
                MatchupCard(
                    multiplier: "×4",
                    effectText: "ばつぐん",
                    types: matchup.defensive.quadrupleWeak,
                    backgroundColor: Color.red.opacity(0.1),
                    accentColor: .red
                )
            }

            // 2倍弱点
            if !matchup.defensive.doubleWeak.isEmpty {
                MatchupCard(
                    multiplier: "×2",
                    effectText: "ばつぐん",
                    types: matchup.defensive.doubleWeak,
                    backgroundColor: Color.orange.opacity(0.1),
                    accentColor: .orange
                )
            }

            // 1/2耐性
            if !matchup.defensive.doubleResist.isEmpty {
                MatchupCard(
                    multiplier: "×1/2",
                    effectText: "いまひとつ",
                    types: matchup.defensive.doubleResist,
                    backgroundColor: Color.green.opacity(0.1),
                    accentColor: .green
                )
            }

            // 1/4耐性
            if !matchup.defensive.quadrupleResist.isEmpty {
                MatchupCard(
                    multiplier: "×1/4",
                    effectText: "いまひとつ",
                    types: matchup.defensive.quadrupleResist,
                    backgroundColor: Color.green.opacity(0.1),
                    accentColor: .green
                )
            }

            // 無効
            if !matchup.defensive.immune.isEmpty {
                MatchupCard(
                    multiplier: "×0",
                    effectText: "無効",
                    types: matchup.defensive.immune,
                    backgroundColor: Color.gray.opacity(0.1),
                    accentColor: .gray
                )
            }
        }
        .padding()
    }
}

/// タイプ相性カード
struct MatchupCard: View {
    let multiplier: String
    let effectText: String
    let types: [String]
    let backgroundColor: Color
    let accentColor: Color

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            // 倍率バッジ
            VStack(spacing: 2) {
                Text(multiplier)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(accentColor)
                Text(effectText)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(accentColor)
            }
            .frame(width: 55)

            // タイプ一覧
            TypeListView(types: types)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(backgroundColor)
        .cornerRadius(8)
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    TypeMatchupView(
        matchup: TypeMatchup(
            offensive: TypeMatchup.OffensiveMatchup(
                superEffective: ["grass", "bug", "ice"]
            ),
            defensive: TypeMatchup.DefensiveMatchup(
                quadrupleWeak: ["rock"],
                doubleWeak: ["water", "electric"],
                doubleResist: ["fighting", "bug", "steel"],
                quadrupleResist: [],
                immune: ["ground"]
            )
        )
    )
}
