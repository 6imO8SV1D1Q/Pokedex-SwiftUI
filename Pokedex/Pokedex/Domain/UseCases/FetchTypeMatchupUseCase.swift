//
//  FetchTypeMatchupUseCase.swift
//  Pokedex
//
//  Created on 2025-10-07.
//

import Foundation

/// タイプ相性を取得するUseCaseのプロトコル
protocol FetchTypeMatchupUseCaseProtocol {
    /// ポケモンのタイプから相性を計算
    /// - Parameter types: ポケモンのタイプ
    /// - Returns: タイプ相性情報
    func execute(types: [PokemonType]) async throws -> TypeMatchup
}

/// タイプ相性を取得するUseCase
final class FetchTypeMatchupUseCase: FetchTypeMatchupUseCaseProtocol {
    private let typeRepository: TypeRepositoryProtocol

    init(typeRepository: TypeRepositoryProtocol) {
        self.typeRepository = typeRepository
    }

    func execute(types: [PokemonType]) async throws -> TypeMatchup {
        // 各タイプの詳細を並列取得
        let typeDetails = try await withThrowingTaskGroup(of: (String, TypeDetail).self) { group in
            for type in types {
                group.addTask {
                    let detail = try await self.typeRepository.fetchTypeDetail(typeName: type.name)
                    return (type.name, detail)
                }
            }

            var results: [String: TypeDetail] = [:]
            for try await (typeName, detail) in group {
                results[typeName] = detail
            }
            return results
        }

        // 攻撃面の相性を計算
        let offensive = calculateOffensiveMatchup(typeDetails: typeDetails)

        // 防御面の相性を計算
        let defensive = calculateDefensiveMatchup(typeDetails: typeDetails)

        return TypeMatchup(offensive: offensive, defensive: defensive)
    }

    // MARK: - Private Methods

    /// 攻撃面の相性を計算
    private func calculateOffensiveMatchup(typeDetails: [String: TypeDetail]) -> TypeMatchup.OffensiveMatchup {
        var superEffective: Set<String> = []

        for (_, detail) in typeDetails {
            superEffective.formUnion(detail.damageRelations.doubleDamageTo)
        }

        return TypeMatchup.OffensiveMatchup(
            superEffective: superEffective.sorted()
        )
    }

    /// 防御面の相性を計算（複合タイプの倍率を掛け合わせる）
    private func calculateDefensiveMatchup(typeDetails: [String: TypeDetail]) -> TypeMatchup.DefensiveMatchup {
        // 全タイプの倍率を計算
        var multipliers: [String: Double] = [:]

        // 初期値: 全タイプ1.0倍
        let allTypes = Set(typeDetails.values.flatMap { detail in
            detail.damageRelations.doubleDamageFrom +
            detail.damageRelations.halfDamageFrom +
            detail.damageRelations.noDamageFrom
        })

        for typeName in allTypes {
            multipliers[typeName] = 1.0
        }

        // 各タイプの相性を掛け合わせる
        for (_, detail) in typeDetails {
            for typeName in detail.damageRelations.doubleDamageFrom {
                multipliers[typeName, default: 1.0] *= 2.0
            }
            for typeName in detail.damageRelations.halfDamageFrom {
                multipliers[typeName, default: 1.0] *= 0.5
            }
            for typeName in detail.damageRelations.noDamageFrom {
                multipliers[typeName] = 0.0
            }
        }

        // 倍率ごとに分類
        var quadrupleWeak: [String] = []
        var doubleWeak: [String] = []
        var doubleResist: [String] = []
        var quadrupleResist: [String] = []
        var immune: [String] = []

        for (typeName, multiplier) in multipliers {
            if multiplier == 0.0 {
                immune.append(typeName)
            } else if multiplier == 4.0 {
                quadrupleWeak.append(typeName)
            } else if multiplier == 2.0 {
                doubleWeak.append(typeName)
            } else if multiplier == 0.5 {
                doubleResist.append(typeName)
            } else if multiplier == 0.25 {
                quadrupleResist.append(typeName)
            }
        }

        return TypeMatchup.DefensiveMatchup(
            quadrupleWeak: quadrupleWeak.sorted(),
            doubleWeak: doubleWeak.sorted(),
            doubleResist: doubleResist.sorted(),
            quadrupleResist: quadrupleResist.sorted(),
            immune: immune.sorted()
        )
    }
}
