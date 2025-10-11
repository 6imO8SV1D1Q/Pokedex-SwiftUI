//
//  MoveRepository.swift
//  Pokedex
//
//  Created on 2025-10-05.
//

import Foundation
import SwiftData
import PokemonAPI

/// 技データを管理するリポジトリの実装
///
/// SwiftDataから技情報を取得し、キャッシュを管理します。
/// バージョングループごとに異なる技リストを返すことができます。
///
/// ## 主な責務
/// - 全技データの取得とキャッシュ
/// - ポケモンの技習得方法の取得
/// - バージョングループ別の技フィルタリング
///
/// ## キャッシュ戦略
/// - メモリキャッシュ（MoveCache）を使用
/// - バージョングループごとにキャッシュキーを分離
/// - MainActorで同期化
final class MoveRepository: MoveRepositoryProtocol {
    private let apiClient: PokemonAPIClient
    private let modelContext: ModelContext
    private let cache: MoveCache

    init(modelContext: ModelContext, apiClient: PokemonAPIClient, cache: MoveCache) {
        self.modelContext = modelContext
        self.apiClient = apiClient
        self.cache = cache
    }

    /// 指定されたバージョングループで使用可能な全ての技を取得（SwiftDataから）
    ///
    /// - Parameter versionGroup: バージョングループID。nilの場合は全技を返す
    /// - Returns: 技のリスト（名前順にソート済み）
    /// - Throws: SwiftDataエラー
    ///
    /// - Note: 結果はメモリキャッシュに保存されます。
    ///         2回目以降の呼び出しはキャッシュから即座に返されます。
    func fetchAllMoves(versionGroup: String?) async throws -> [MoveEntity] {
        let cacheKey = "moves_\(versionGroup ?? "all")"

        if let cached = cache.getMoves(key: cacheKey) {
            print("🔍 [MoveRepository] Cache hit: \(cached.count) moves")
            return cached
        }

        // SwiftDataから全技を取得
        let descriptor = FetchDescriptor<MoveModel>(
            sortBy: [SortDescriptor(\.name)]
        )
        let models = try modelContext.fetch(descriptor)
        print("📦 [MoveRepository] Fetched from SwiftData: \(models.count) moves")

        // MoveEntityに変換
        let moves: [MoveEntity] = models.map { model in
            MoveEntity(
                id: model.id,
                name: model.name,
                nameJa: model.nameJa,
                type: PokemonType(slot: 1, name: model.type),
                power: model.power,
                accuracy: model.accuracy,
                pp: model.pp,
                damageClass: model.damageClass,
                effect: model.effect,
                machineNumber: nil,  // TODO: 技マシン番号は別途管理
                categories: model.categories
            )
        }

        cache.setMoves(key: cacheKey, moves: moves)
        return moves
    }

    /// 指定されたポケモンが指定された技を習得できるか、習得方法とともに取得
    ///
    /// - Parameters:
    ///   - pokemonId: ポケモンのID
    ///   - moveIds: 技のIDリスト
    ///   - versionGroup: 対象のバージョングループID（例: "red-blue", "scarlet-violet"）
    /// - Returns: 習得可能な技とその習得方法のリスト
    /// - Throws: APIエラー、ネットワークエラー
    ///
    /// - Note: moveIdsに含まれていても習得不可能な技は結果に含まれません。
    ///         各技ごとにAPIリクエストが発生するため、多数の技を指定すると時間がかかります。
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
            machine: nil  // マシン番号はMoveEntityに含まれる
        )

        let moveEntity = try await fetchMoveDetail(moveId: moveId, versionGroup: versionGroup)

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

    /// 技の詳細情報を取得してEntityに変換（SwiftDataから）
    /// - Parameters:
    ///   - moveId: 技ID
    ///   - versionGroup: バージョングループ（現在は未使用）
    /// - Returns: 技Entity
    func fetchMoveDetail(moveId: Int, versionGroup: String?) async throws -> MoveEntity {
        // SwiftDataから技情報を取得
        let descriptor = FetchDescriptor<MoveModel>(
            predicate: #Predicate { $0.id == moveId }
        )
        guard let model = try modelContext.fetch(descriptor).first else {
            throw NSError(domain: "MoveRepository", code: 404, userInfo: [NSLocalizedDescriptionKey: "Move not found: \(moveId)"])
        }

        return MoveEntity(
            id: model.id,
            name: model.name,
            nameJa: model.nameJa,
            type: PokemonType(
                slot: 1,
                name: model.type
            ),
            power: model.power,
            accuracy: model.accuracy,
            pp: model.pp,
            damageClass: model.damageClass,
            effect: model.effect,
            machineNumber: nil,  // TODO: 技マシン番号の管理
            categories: model.categories
        )
    }

    /// マシン番号を抽出
    /// - Parameters:
    ///   - move: PKMMoveデータ
    ///   - versionGroup: バージョングループ
    /// - Returns: マシン番号（例: "TM24", "HM03", "TR12"）
    private func extractMachineNumber(from move: PKMMove, versionGroup: String?) async -> String? {
        guard let versionGroup = versionGroup,
              let machines = move.machines else {
            return nil
        }

        // バージョングループに対応するマシンを検索
        for machine in machines {
            if machine.versionGroup?.name == versionGroup,
               let machineUrl = machine.machine?.url {
                // URLからマシンIDを抽出（例: "https://pokeapi.co/api/v2/machine/1/" -> 1）
                let components = machineUrl.split(separator: "/")
                guard let machineIdString = components.last,
                      let machineId = Int(machineIdString) else {
                    continue
                }

                // Machine APIを呼び出してitem.nameを取得
                do {
                    let pkmMachine = try await apiClient.fetchMachine(machineId)
                    guard let itemName = pkmMachine.item?.name else {
                        continue
                    }

                    // item.nameを大文字化して返す（例: "tm24" -> "TM24", "hm03" -> "HM03", "tr11" -> "TR11"）
                    return itemName.uppercased()
                } catch {
                    // Machine API取得失敗時はログ出力して次のマシンを試す
                    print("Failed to fetch machine \(machineId): \(error)")
                    continue
                }
            }
        }

        return nil
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
