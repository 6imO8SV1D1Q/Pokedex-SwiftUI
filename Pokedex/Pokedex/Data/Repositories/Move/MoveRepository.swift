//
//  MoveRepository.swift
//  Pokedex
//
//  Created on 2025-10-05.
//

import Foundation
import PokemonAPI

/// 技情報を管理するRepository
final class MoveRepository: MoveRepositoryProtocol {
    private let apiClient: PokemonAPIClient
    private let cache: MoveCache

    init(apiClient: PokemonAPIClient, cache: MoveCache) {
        self.apiClient = apiClient
        self.cache = cache
    }

    func fetchAllMoves(versionGroup: String?) async throws -> [MoveEntity] {
        let cacheKey = "moves_\(versionGroup ?? "all")"

        if let cached = cache.getMoves(key: cacheKey) {
            return cached
        }

        // PokéAPI: /api/v2/move?limit=1000
        let movesData = try await apiClient.fetchAllMoves()

        // データからEntityに変換（タイプ情報は後で必要な時に取得）
        var moves: [MoveEntity] = movesData.map { moveData in
            MoveEntity(
                id: moveData.id,
                name: moveData.name,
                type: PokemonType(slot: 1, name: "normal") // 仮のタイプ（リスト表示では不要）
            )
        }

        // 名前順にソート
        moves.sort { $0.name < $1.name }

        cache.setMoves(key: cacheKey, moves: moves)
        return moves
    }

    func fetchLearnMethods(
        pokemonId: Int,
        moveIds: [Int],
        versionGroup: String
    ) async throws -> [MoveLearnMethod] {

        // ポケモン情報を取得（PKMPokemon from PokemonAPI）
        let pkmPokemon = try await apiClient.fetchRawPokemon(pokemonId)

        var learnMethods: [MoveLearnMethod] = []

        for moveId in moveIds {
            // このポケモンがこの技を習得できるか確認
            guard let pkmMove = pkmPokemon.moves?.first(where: { move in
                // PKMAPIResourceのURLからIDを抽出して比較
                guard let urlString = move.move?.url,
                      let urlComponents = urlString.split(separator: "/").last,
                      let id = Int(urlComponents) else {
                    return false
                }
                return id == moveId
            }) else {
                continue
            }

            // バージョングループ別の習得方法を探す
            if let versionGroupDetail = pkmMove.versionGroupDetails?.first(where: { detail in
                detail.versionGroup?.name == versionGroup
            }) {
                let method = parseLearnMethod(
                    methodName: versionGroupDetail.moveLearnMethod?.name ?? "",
                    level: versionGroupDetail.levelLearnedAt,
                    machine: nil  // TODO: TM/TR番号の取得
                )

                // 技の詳細情報を取得
                let moveDetail = try await apiClient.fetchMove(moveId)

                let moveEntity = MoveEntity(
                    id: moveId,
                    name: moveDetail.name ?? "unknown",
                    type: PokemonType(
                        slot: 1,
                        name: moveDetail.type?.name ?? "normal"
                    )
                )

                learnMethods.append(MoveLearnMethod(
                    move: moveEntity,
                    method: method,
                    versionGroup: versionGroup
                ))
            }
        }

        return learnMethods
    }

    private func parseLearnMethod(
        methodName: String,
        level: Int?,
        machine: String?
    ) -> MoveLearnMethodType {
        switch methodName {
        case "level-up":
            return .levelUp(level: level ?? 1)
        case "machine":
            return .machine(number: machine ?? "TM??")
        case "egg":
            return .egg
        case "tutor":
            return .tutor
        case "form-change":
            return .form
        default:
            return .tutor
        }
    }
}
