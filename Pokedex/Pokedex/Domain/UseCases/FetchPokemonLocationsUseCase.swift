//
//  FetchPokemonLocationsUseCase.swift
//  Pokedex
//
//  Created on 2025-10-07.
//

import Foundation

/// ポケモンの出現場所を取得するUseCaseのプロトコル
protocol FetchPokemonLocationsUseCaseProtocol {
    /// ポケモンの出現場所を取得
    /// - Parameters:
    ///   - pokemonId: ポケモンID
    ///   - versionGroup: バージョングループ（nilの場合は全バージョン）
    /// - Returns: 出現場所のリスト
    func execute(pokemonId: Int, versionGroup: String?) async throws -> [PokemonLocation]
}

/// ポケモンの出現場所を取得するUseCase
final class FetchPokemonLocationsUseCase: FetchPokemonLocationsUseCaseProtocol {
    private let pokemonRepository: PokemonRepositoryProtocol

    init(pokemonRepository: PokemonRepositoryProtocol) {
        self.pokemonRepository = pokemonRepository
    }

    func execute(pokemonId: Int, versionGroup: String?) async throws -> [PokemonLocation] {
        let allLocations = try await pokemonRepository.fetchPokemonLocations(pokemonId: pokemonId)

        // バージョングループ指定がない場合は全場所を返す
        guard let versionGroup = versionGroup else {
            return allLocations
        }

        // バージョングループでフィルタリング
        return allLocations.compactMap { location in
            let filteredVersions = location.versionDetails.filter { versionDetail in
                belongsToVersionGroup(version: versionDetail.version, versionGroup: versionGroup)
            }

            guard !filteredVersions.isEmpty else {
                return nil
            }

            return PokemonLocation(
                locationName: location.locationName,
                versionDetails: filteredVersions
            )
        }
    }

    // MARK: - Private Methods

    /// バージョンが指定されたバージョングループに属するか判定
    private func belongsToVersionGroup(version: String, versionGroup: String) -> Bool {
        // バージョングループとバージョンのマッピング
        let versionGroupMap: [String: [String]] = [
            "red-blue": ["red", "blue"],
            "yellow": ["yellow"],
            "gold-silver": ["gold", "silver"],
            "crystal": ["crystal"],
            "ruby-sapphire": ["ruby", "sapphire"],
            "emerald": ["emerald"],
            "firered-leafgreen": ["firered", "leafgreen"],
            "diamond-pearl": ["diamond", "pearl"],
            "platinum": ["platinum"],
            "heartgold-soulsilver": ["heartgold", "soulsilver"],
            "black-white": ["black", "white"],
            "black-2-white-2": ["black-2", "white-2"],
            "x-y": ["x", "y"],
            "omega-ruby-alpha-sapphire": ["omega-ruby", "alpha-sapphire"],
            "sun-moon": ["sun", "moon"],
            "ultra-sun-ultra-moon": ["ultra-sun", "ultra-moon"],
            "sword-shield": ["sword", "shield"],
            "legends-arceus": ["legends-arceus"],
            "scarlet-violet": ["scarlet", "violet"]
        ]

        guard let versions = versionGroupMap[versionGroup] else {
            return false
        }

        return versions.contains(version)
    }
}
