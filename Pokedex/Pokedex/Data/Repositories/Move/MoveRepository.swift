//
//  MoveRepository.swift
//  Pokedex
//
//  Created on 2025-10-05.
//

import Foundation
import SwiftData

/// 技データを管理するリポジトリの実装
///
/// SwiftDataから技情報を取得し、キャッシュを管理します。
///
/// ## 主な責務
/// - 全技データの取得とキャッシュ
/// - ポケモンの技習得方法の取得（SwiftDataから）
///
/// ## キャッシュ戦略
/// - メモリキャッシュ（MoveCache）を使用
/// - バージョングループごとにキャッシュキーを分離
/// - MainActorで同期化
final class MoveRepository: MoveRepositoryProtocol {
    private let modelContext: ModelContext
    private let cache: MoveCache

    init(modelContext: ModelContext, cache: MoveCache) {
        self.modelContext = modelContext
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

    /// 指定されたポケモンが指定された技を習得できるか、習得方法とともに取得（SwiftDataから）
    ///
    /// - Parameters:
    ///   - pokemonId: ポケモンのID
    ///   - moveIds: 技のIDリスト
    ///   - versionGroup: 対象のバージョングループID（未使用、互換性のため保持）
    /// - Returns: 習得可能な技とその習得方法のリスト
    /// - Throws: SwiftDataエラー
    ///
    /// - Note: moveIdsに含まれていても習得不可能な技は結果に含まれません。
    func fetchLearnMethods(
        pokemonId: Int,
        moveIds: [Int],
        versionGroup: String
    ) async throws -> [MoveLearnMethod] {
        // SwiftDataからポケモンデータを取得
        let descriptor = FetchDescriptor<PokemonModel>(
            predicate: #Predicate { $0.id == pokemonId }
        )
        guard let pokemonModel = try modelContext.fetch(descriptor).first else {
            return []
        }

        var learnMethods: [MoveLearnMethod] = []

        for moveId in moveIds {
            // ポケモンの技リストから該当する技を検索
            guard let learnedMove = pokemonModel.moves.first(where: { $0.moveId == moveId }) else {
                continue
            }

            // 技詳細を取得
            let moveEntity = try await fetchMoveDetail(moveId: moveId, versionGroup: versionGroup)

            // 習得方法を変換
            let method = parseLearnMethod(
                methodName: learnedMove.learnMethod,
                level: learnedMove.level,
                machine: learnedMove.machineNumber
            )

            learnMethods.append(MoveLearnMethod(
                move: moveEntity,
                method: method,
                versionGroup: versionGroup
            ))
        }

        return learnMethods
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
