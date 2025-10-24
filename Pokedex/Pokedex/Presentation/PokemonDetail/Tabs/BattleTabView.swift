//
//  BattleTabView.swift
//  Pokedex
//
//  Created on 2025-10-21.
//

import SwiftUI

/// バトルタブ: 対戦用情報を表示
struct BattleTabView: View {
    @ObservedObject var viewModel: PokemonDetailViewModel
    @EnvironmentObject private var localizationManager: LocalizationManager

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // タイプ相性
                if let matchup = viewModel.typeMatchup {
                    GroupBoxSection(title: "タイプ相性", icon: "shield.fill") {
                        TypeMatchupView(matchup: matchup)
                            .padding(.horizontal, -16)
                            .padding(.vertical, -12)
                    }
                }

                // 種族値
                GroupBoxSection(title: "種族値", icon: "chart.bar.fill") {
                    PokemonStatsView(stats: viewModel.displayStats)
                }

                // 実数値
                if let calculatedStats = viewModel.calculatedStats {
                    GroupBoxSection(title: "実数値（Lv.50）", icon: "number") {
                        CalculatedStatsView(
                            stats: calculatedStats,
                            baseStats: viewModel.displayStats
                        )
                        .padding(.horizontal, -16)
                        .padding(.vertical, -12)
                    }
                }

                // 特性
                GroupBoxSection(title: "特性", icon: "star.fill") {
                    if !viewModel.abilityDetails.isEmpty {
                        AbilitiesView(
                            abilities: viewModel.displayAbilities,
                            abilityDetails: viewModel.abilityDetails
                        )
                        .padding(.horizontal, -16)
                        .padding(.vertical, -12)
                    } else {
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(viewModel.displayAbilities, id: \.name) { ability in
                                Text(localizationManager.displayName(for: ability))
                                    .font(.body)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }

                // 覚える技
                GroupBoxSection(title: "覚える技", icon: "bolt.fill") {
                    MovesView(
                        moves: viewModel.pokemon.moves,
                        moveDetails: viewModel.moveDetails,
                        selectedLearnMethod: $viewModel.selectedLearnMethod
                    )
                    .padding(.horizontal, -16)
                    .padding(.vertical, -12)
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
    }
}

/// InsetGroupedスタイル風のセクション
struct GroupBoxSection<Content: View>: View {
    let title: String
    let icon: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: icon)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
                .textCase(.uppercase)
                .padding(.horizontal, 16)
                .padding(.bottom, 4)

            VStack(spacing: 0) {
                content
                    .padding(16)
            }
            .background(Color(.secondarySystemGroupedBackground))
            .cornerRadius(10)
        }
    }
}
