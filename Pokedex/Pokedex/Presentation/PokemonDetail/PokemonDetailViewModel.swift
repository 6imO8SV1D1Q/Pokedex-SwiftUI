//
//  PokemonDetailViewModel.swift
//  Pokedex
//
//  Created on 2025-10-04.
//

import Foundation
import Combine

@MainActor
final class PokemonDetailViewModel: ObservableObject {
    @Published var pokemon: Pokemon
    @Published var isShiny = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var evolutionChain: [Int] = []
    @Published var selectedLearnMethod = "level-up"

    private let fetchEvolutionChainUseCase: FetchEvolutionChainUseCaseProtocol

    // フィルタリングされた技リスト
    var filteredMoves: [PokemonMove] {
        pokemon.moves.filter { move in
            move.learnMethod == selectedLearnMethod
        }
        .sorted { move1, move2 in
            if let level1 = move1.level, let level2 = move2.level {
                return level1 < level2
            }
            return move1.name < move2.name
        }
    }

    init(
        pokemon: Pokemon,
        fetchEvolutionChainUseCase: FetchEvolutionChainUseCaseProtocol = DIContainer.shared.makeFetchEvolutionChainUseCase()
    ) {
        self.pokemon = pokemon
        self.fetchEvolutionChainUseCase = fetchEvolutionChainUseCase
    }

    // 表示する画像URLを返す
    var displayImageURL: String? {
        if isShiny {
            return pokemon.sprites.shinyImageURL ?? pokemon.sprites.preferredImageURL
        } else {
            return pokemon.sprites.preferredImageURL
        }
    }

    func toggleShiny() {
        isShiny.toggle()
    }

    func loadEvolutionChain() async {
        do {
            evolutionChain = try await fetchEvolutionChainUseCase.execute(pokemonId: pokemon.id)
        } catch {
            // 進化チェーン取得失敗時は空配列のまま
            evolutionChain = []
        }
    }
}
