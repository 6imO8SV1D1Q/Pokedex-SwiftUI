//
//  TypeDetailMapper.swift
//  Pokedex
//
//  Created on 2025-10-07.
//

import Foundation
import PokemonAPI

enum TypeDetailMapper {
    /// PKMTypeからTypeDetailにマッピング
    nonisolated static func map(from pkmType: PKMType) -> TypeDetail {
        let typeName = pkmType.name ?? "unknown"
        let damageRelations = mapDamageRelations(from: pkmType.damageRelations)

        return TypeDetail(
            typeName: typeName,
            damageRelations: damageRelations
        )
    }

    // MARK: - Private Helpers

    nonisolated private static func mapDamageRelations(from relations: PKMTypeRelations?) -> TypeDetail.DamageRelations {
        TypeDetail.DamageRelations(
            doubleDamageTo: extractTypeNames(from: relations?.doubleDamageTo),
            halfDamageTo: extractTypeNames(from: relations?.halfDamageTo),
            noDamageTo: extractTypeNames(from: relations?.noDamageTo),
            doubleDamageFrom: extractTypeNames(from: relations?.doubleDamageFrom),
            halfDamageFrom: extractTypeNames(from: relations?.halfDamageFrom),
            noDamageFrom: extractTypeNames(from: relations?.noDamageFrom)
        )
    }

    nonisolated private static func extractTypeNames(from types: [Any]?) -> [String] {
        guard let types = types else { return [] }
        return types.compactMap { type in
            // PKMNamedAPIResourceから名前を抽出
            let typeObj = type as AnyObject
            if let name = typeObj.value(forKey: "name") as? String {
                return name
            }
            return nil
        }
    }
}
