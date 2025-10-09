//
//  MockTypeRepository.swift
//  PokedexTests
//
//  Created on 2025-10-09.
//

import Foundation
@testable import Pokedex

final class MockTypeRepository: TypeRepositoryProtocol {
    // MARK: - Mock Configuration

    var shouldThrowError = false
    var errorToThrow: Error = PokemonError.networkError(NSError(domain: "test", code: -1))
    var typeDetailsToReturn: [String: TypeDetail] = [:]
    var fetchTypeDetailCallCount = 0

    // MARK: - TypeRepositoryProtocol

    func fetchTypeDetail(typeName: String) async throws -> TypeDetail {
        fetchTypeDetailCallCount += 1

        if shouldThrowError {
            throw errorToThrow
        }

        guard let typeDetail = typeDetailsToReturn[typeName] else {
            throw PokemonError.notFound
        }

        return typeDetail
    }

    // MARK: - Helper Methods

    /// テストデータをセットアップ
    func setupMockData() {
        // ほのおタイプ
        typeDetailsToReturn["fire"] = TypeDetail(
            typeName: "fire",
            damageRelations: TypeDetail.DamageRelations(
                doubleDamageTo: ["grass", "ice", "bug", "steel"],
                halfDamageTo: ["fire", "water", "rock", "dragon"],
                noDamageTo: [],
                doubleDamageFrom: ["water", "ground", "rock"],
                halfDamageFrom: ["fire", "grass", "ice", "bug", "steel", "fairy"],
                noDamageFrom: []
            )
        )

        // みずタイプ
        typeDetailsToReturn["water"] = TypeDetail(
            typeName: "water",
            damageRelations: TypeDetail.DamageRelations(
                doubleDamageTo: ["fire", "ground", "rock"],
                halfDamageTo: ["water", "grass", "dragon"],
                noDamageTo: [],
                doubleDamageFrom: ["electric", "grass"],
                halfDamageFrom: ["fire", "water", "ice", "steel"],
                noDamageFrom: []
            )
        )

        // くさタイプ
        typeDetailsToReturn["grass"] = TypeDetail(
            typeName: "grass",
            damageRelations: TypeDetail.DamageRelations(
                doubleDamageTo: ["water", "ground", "rock"],
                halfDamageTo: ["fire", "grass", "poison", "flying", "bug", "dragon", "steel"],
                noDamageTo: [],
                doubleDamageFrom: ["fire", "ice", "poison", "flying", "bug"],
                halfDamageFrom: ["water", "electric", "grass", "ground"],
                noDamageFrom: []
            )
        )

        // でんきタイプ
        typeDetailsToReturn["electric"] = TypeDetail(
            typeName: "electric",
            damageRelations: TypeDetail.DamageRelations(
                doubleDamageTo: ["water", "flying"],
                halfDamageTo: ["electric", "grass", "dragon"],
                noDamageTo: ["ground"],
                doubleDamageFrom: ["ground"],
                halfDamageFrom: ["electric", "flying", "steel"],
                noDamageFrom: []
            )
        )

        // ひこうタイプ
        typeDetailsToReturn["flying"] = TypeDetail(
            typeName: "flying",
            damageRelations: TypeDetail.DamageRelations(
                doubleDamageTo: ["grass", "fighting", "bug"],
                halfDamageTo: ["electric", "rock", "steel"],
                noDamageTo: [],
                doubleDamageFrom: ["electric", "ice", "rock"],
                halfDamageFrom: ["grass", "fighting", "bug"],
                noDamageFrom: ["ground"]
            )
        )

        // いわタイプ
        typeDetailsToReturn["rock"] = TypeDetail(
            typeName: "rock",
            damageRelations: TypeDetail.DamageRelations(
                doubleDamageTo: ["fire", "ice", "flying", "bug"],
                halfDamageTo: ["fighting", "ground", "steel"],
                noDamageTo: [],
                doubleDamageFrom: ["water", "grass", "fighting", "ground", "steel"],
                halfDamageFrom: ["normal", "fire", "poison", "flying"],
                noDamageFrom: []
            )
        )

        // じめんタイプ
        typeDetailsToReturn["ground"] = TypeDetail(
            typeName: "ground",
            damageRelations: TypeDetail.DamageRelations(
                doubleDamageTo: ["fire", "electric", "poison", "rock", "steel"],
                halfDamageTo: ["grass", "bug"],
                noDamageTo: ["flying"],
                doubleDamageFrom: ["water", "grass", "ice"],
                halfDamageFrom: ["poison", "rock"],
                noDamageFrom: ["electric"]
            )
        )
    }

    /// リセット
    func reset() {
        shouldThrowError = false
        typeDetailsToReturn.removeAll()
        fetchTypeDetailCallCount = 0
    }
}
