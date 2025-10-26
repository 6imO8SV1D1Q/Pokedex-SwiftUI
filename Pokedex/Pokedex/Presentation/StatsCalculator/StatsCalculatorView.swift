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
                        onSelect: { pokemon in
                            viewModel.selectPokemon(pokemon)
                        }
                    )

                    // ポケモン選択後の入力UI
                    if viewModel.selectedPokemon != nil {
                        // ステータス入力（レベル、個体値、努力値）
                        StatsInputView(
                            level: $viewModel.level,
                            ivs: $viewModel.ivs,
                            evs: $viewModel.evs,
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
                            }
                        )
                        .onChange(of: viewModel.level) { _ in
                            viewModel.calculateStats()
                        }
                        .onChange(of: viewModel.ivs) { _ in
                            viewModel.calculateStats()
                        }

                        // 性格補正入力
                        NatureInputView(
                            natureModifiers: $viewModel.nature,
                            onSetNature: { stat, modifier in
                                viewModel.setNature(for: stat, modifier: modifier)
                            }
                        )

                        // 計算結果表示
                        if !viewModel.calculatedStats.isEmpty,
                           let pokemon = viewModel.selectedPokemon {
                            StatsResultView(
                                pokemon: pokemon,
                                calculatedStats: viewModel.calculatedStats,
                                natureModifiers: viewModel.nature
                            )
                        }
                    }
                }
                .padding()
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle("実数値計算機")
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
