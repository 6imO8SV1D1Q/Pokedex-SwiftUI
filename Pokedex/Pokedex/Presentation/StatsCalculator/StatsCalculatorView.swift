//
//  StatsCalculatorView.swift
//  Pokedex
//
//  Created on 2025-10-26.
//

import SwiftUI

/// 実数値計算機画面
struct StatsCalculatorView: View {
    @StateObject private var viewModel: StatsCalculatorViewModel

    init(viewModel: StatsCalculatorViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // ポケモン選択
                    PokemonSearchView(
                        selectedPokemon: $viewModel.selectedPokemon,
                        searchText: $viewModel.searchText,
                        filteredPokemon: viewModel.filteredPokemon,
                        isLoadingPokemon: viewModel.isLoadingPokemon,
                        onSelect: { pokemon in
                            viewModel.selectPokemon(pokemon)
                        }
                    )

                    // ポケモン選択後の入力UI
                    if viewModel.selectedPokemon != nil {
                        // コンパクトなステータス入力（種族値・個体値・努力値・性格・実数値を統合）
                        CompactStatsInputView(
                            pokemon: viewModel.selectedPokemon,
                            calculatedStats: viewModel.calculatedStats,
                            level: $viewModel.level,
                            ivs: $viewModel.ivs,
                            evs: $viewModel.evs,
                            natureModifiers: $viewModel.nature,
                            remainingEVs: viewModel.remainingEVs,
                            isEVOverLimit: viewModel.isEVOverLimit,
                            onSetAllIVsToMax: {
                                viewModel.setAllIVsToMax()
                            },
                            onSetAllIVsToMin: {
                                viewModel.setAllIVsToMin()
                            },
                            onIncrementEV: { stat in
                                viewModel.incrementEV(for: stat)
                            },
                            onDecrementEV: { stat in
                                viewModel.decrementEV(for: stat)
                            },
                            onSetNature: { stat, modifier in
                                viewModel.setNature(for: stat, modifier: modifier)
                            }
                        )
                        .onChange(of: viewModel.level) {
                            viewModel.calculateStats()
                        }
                        .onChange(of: viewModel.ivs) {
                            viewModel.calculateStats()
                        }
                    }
                }
                .padding()
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle(L10n.StatsCalc.title)
        }
    }
}

#Preview {
    StatsCalculatorView(
        viewModel: StatsCalculatorViewModel(
            pokemonRepository: DIContainer.shared.makePokemonRepository()
        )
    )
}
