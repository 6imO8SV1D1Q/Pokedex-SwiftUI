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
        let pkmPokemon = try await apiClient.fetchRawPokemon(pokemonId)
        var learnMethods: [MoveLearnMethod] = []

        for moveId in moveIds {
            if let learnMethod = try await extractLearnMethod(
                from: pkmPokemon,
                moveId: moveId,
                versionGroup: versionGroup
            ) {
                learnMethods.append(learnMethod)
            }
        }

        return learnMethods
    }

    /// ポケモンの技習得方法を抽出
    /// - Parameters:
    ///   - pkmPokemon: PokéAPIのポケモンデータ
    ///   - moveId: 技ID
    ///   - versionGroup: バージョングループ
    /// - Returns: 習得方法、習得できない場合はnil
    private func extractLearnMethod(
        from pkmPokemon: PKMPokemon,
        moveId: Int,
        versionGroup: String
    ) async throws -> MoveLearnMethod? {
        guard let pkmMove = findPokemonMove(in: pkmPokemon, moveId: moveId),
              let versionGroupDetail = findVersionGroupDetail(in: pkmMove, versionGroup: versionGroup) else {
            return nil
        }

        let method = parseLearnMethod(
            methodName: versionGroupDetail.moveLearnMethod?.name ?? "",
            level: versionGroupDetail.levelLearnedAt,
            machine: nil  // TODO: TM/TR番号の取得
        )

        let moveEntity = try await fetchMoveEntity(moveId: moveId)

        return MoveLearnMethod(
            move: moveEntity,
            method: method,
            versionGroup: versionGroup
        )
    }

    /// ポケモンが覚える技の中から指定IDの技を検索
    /// - Parameters:
    ///   - pkmPokemon: PokéAPIのポケモンデータ
    ///   - moveId: 技ID
    /// - Returns: 見つかった技データ、なければnil
    private func findPokemonMove(in pkmPokemon: PKMPokemon, moveId: Int) -> PKMPokemonMove? {
        pkmPokemon.moves?.first { move in
            guard let urlString = move.move?.url,
                  let urlComponents = urlString.split(separator: "/").last,
                  let id = Int(urlComponents) else {
                return false
            }
            return id == moveId
        }
    }

    /// 技の習得方法からバージョングループに対応する詳細を検索
    /// - Parameters:
    ///   - pkmMove: ポケモンの技データ
    ///   - versionGroup: バージョングループ
    /// - Returns: バージョン別の習得詳細、なければnil
    private func findVersionGroupDetail(
        in pkmMove: PKMPokemonMove,
        versionGroup: String
    ) -> PKMPokemonMoveVersion? {
        pkmMove.versionGroupDetails?.first { detail in
            detail.versionGroup?.name == versionGroup
        }
    }

    /// 技の詳細情報を取得してEntityに変換
    /// - Parameter moveId: 技ID
    /// - Returns: 技Entity
    private func fetchMoveEntity(moveId: Int) async throws -> MoveEntity {
        let moveDetail = try await apiClient.fetchMove(moveId)

        return MoveEntity(
            id: moveId,
            name: moveDetail.name ?? "unknown",
            type: PokemonType(
                slot: 1,
                name: moveDetail.type?.name ?? "normal"
            )
        )
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
