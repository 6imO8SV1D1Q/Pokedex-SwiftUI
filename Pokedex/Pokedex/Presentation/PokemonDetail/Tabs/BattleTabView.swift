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

    var body: some View {
        ScrollView {
            VStack(spacing: DesignConstants.Spacing.large) {
                // タイプ相性
                if let matchup = viewModel.typeMatchup {
                    ExpandableSection(
                        title: "タイプ相性",
                        systemImage: "shield.fill",
                        isExpanded: sectionBinding("typeMatchup")
                    ) {
                        TypeMatchupView(matchup: matchup)
                    }
                }

                // 種族値
                ExpandableSection(
                    title: viewModel.calculatedStats != nil ? "種族値・実数値" : "種族値",
                    systemImage: "chart.bar.fill",
                    isExpanded: sectionBinding("stats")
                ) {
                    if let calculatedStats = viewModel.calculatedStats {
                        CalculatedStatsView(
                            stats: calculatedStats,
                            baseStats: viewModel.displayStats
                        )
                    } else {
                        PokemonStatsView(stats: viewModel.displayStats)
                            .padding()
                    }
                }

                // 特性
                ExpandableSection(
                    title: "特性",
                    systemImage: "star.fill",
                    isExpanded: sectionBinding("abilities")
                ) {
                    if !viewModel.abilityDetails.isEmpty {
                        AbilitiesView(
                            abilities: viewModel.displayAbilities,
                            abilityDetails: viewModel.abilityDetails
                        )
                    } else {
                        abilitiesViewLegacy
                    }
                }

                // 覚える技
                ExpandableSection(
                    title: "覚える技",
                    systemImage: "bolt.fill",
                    isExpanded: sectionBinding("moves")
                ) {
                    MovesView(
                        moves: viewModel.pokemon.moves,
                        moveDetails: viewModel.moveDetails,
                        selectedLearnMethod: $viewModel.selectedLearnMethod
                    )
                }
            }
            .padding(DesignConstants.Spacing.medium)
        }
    }

    // MARK: - Section Binding Helper

    private func sectionBinding(_ sectionId: String) -> Binding<Bool> {
        Binding(
            get: { viewModel.isSectionExpanded[sectionId, default: true] },
            set: { _ in viewModel.toggleSection(sectionId) }
        )
    }

    // MARK: - Legacy Abilities View

    @EnvironmentObject private var localizationManager: LocalizationManager

    private var abilitiesViewLegacy: some View {
        VStack(alignment: .leading, spacing: DesignConstants.Spacing.xSmall) {
            ForEach(viewModel.displayAbilities, id: \.name) { ability in
                Text(localizationManager.displayName(for: ability))
                    .font(.body)
                    .foregroundColor(.primary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
    }
}
