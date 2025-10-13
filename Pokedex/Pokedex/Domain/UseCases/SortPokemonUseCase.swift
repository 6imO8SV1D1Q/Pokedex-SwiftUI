//
//  SortPokemonUseCase.swift
//  Pokedex
//
//  Created on 2025-10-05.
//

import Foundation

/// ポケモンリストをソートするUseCase
final class SortPokemonUseCase: SortPokemonUseCaseProtocol {
    func execute(
        pokemonList: [Pokemon],
        sortOption: SortOption
    ) -> [Pokemon] {
        switch sortOption {
        case .pokedexNumber(let ascending):
            // 図鑑番号(speciesId)でソート、同じ種族の場合はid(フォーム)でソート
            return pokemonList.sorted {
                if $0.speciesId == $1.speciesId {
                    return ascending ? $0.id < $1.id : $0.id > $1.id
                }
                return ascending ? $0.speciesId < $1.speciesId : $0.speciesId > $1.speciesId
            }

        case .totalStats(let ascending):
            return pokemonList.sorted {
                ascending
                    ? $0.totalBaseStat < $1.totalBaseStat
                    : $0.totalBaseStat > $1.totalBaseStat
            }

        case .hp(let ascending):
            return pokemonList.sorted {
                let hp1 = $0.stats.first { $0.name == "hp" }?.baseStat ?? 0
                let hp2 = $1.stats.first { $0.name == "hp" }?.baseStat ?? 0
                return ascending ? hp1 < hp2 : hp1 > hp2
            }

        case .attack(let ascending):
            return pokemonList.sorted {
                let atk1 = $0.stats.first { $0.name == "attack" }?.baseStat ?? 0
                let atk2 = $1.stats.first { $0.name == "attack" }?.baseStat ?? 0
                return ascending ? atk1 < atk2 : atk1 > atk2
            }

        case .defense(let ascending):
            return pokemonList.sorted {
                let def1 = $0.stats.first { $0.name == "defense" }?.baseStat ?? 0
                let def2 = $1.stats.first { $0.name == "defense" }?.baseStat ?? 0
                return ascending ? def1 < def2 : def1 > def2
            }

        case .specialAttack(let ascending):
            return pokemonList.sorted {
                let spAtk1 = $0.stats.first { $0.name == "special-attack" }?.baseStat ?? 0
                let spAtk2 = $1.stats.first { $0.name == "special-attack" }?.baseStat ?? 0
                return ascending ? spAtk1 < spAtk2 : spAtk1 > spAtk2
            }

        case .specialDefense(let ascending):
            return pokemonList.sorted {
                let spDef1 = $0.stats.first { $0.name == "special-defense" }?.baseStat ?? 0
                let spDef2 = $1.stats.first { $0.name == "special-defense" }?.baseStat ?? 0
                return ascending ? spDef1 < spDef2 : spDef1 > spDef2
            }

        case .speed(let ascending):
            return pokemonList.sorted {
                let spd1 = $0.stats.first { $0.name == "speed" }?.baseStat ?? 0
                let spd2 = $1.stats.first { $0.name == "speed" }?.baseStat ?? 0
                return ascending ? spd1 < spd2 : spd1 > spd2
            }
        }
    }
}
