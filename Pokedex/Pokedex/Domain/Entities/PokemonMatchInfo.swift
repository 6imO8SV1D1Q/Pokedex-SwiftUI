//
//  PokemonMatchInfo.swift
//  Pokedex
//
//  ポケモンが絞り込み条件に合致した理由を保持するエンティティ
//

import Foundation

/// ポケモンが絞り込み条件に合致した理由
struct PokemonMatchInfo: Equatable {
    /// 合致した特性名のリスト
    let matchedAbilities: [String]

    /// 合致した技と習得方法のリスト
    let matchedMoves: [MoveLearnMethod]

    /// 空かどうか（何も合致していない）
    var isEmpty: Bool {
        matchedAbilities.isEmpty && matchedMoves.isEmpty
    }

    /// 空の状態を作成
    static var empty: PokemonMatchInfo {
        PokemonMatchInfo(matchedAbilities: [], matchedMoves: [])
    }
}

/// ポケモンと合致理由をまとめた構造体
struct PokemonWithMatchInfo: Identifiable {
    let pokemon: Pokemon
    let matchInfo: PokemonMatchInfo

    var id: Int { pokemon.id }

    /// 合致理由なしで作成
    init(pokemon: Pokemon) {
        self.pokemon = pokemon
        self.matchInfo = .empty
    }

    /// 合致理由ありで作成
    init(pokemon: Pokemon, matchInfo: PokemonMatchInfo) {
        self.pokemon = pokemon
        self.matchInfo = matchInfo
    }
}

// MARK: - Array Extensions

extension Array where Element == String {
    /// 重複を除いた配列を返す
    func unique() -> [String] {
        var seen = Set<String>()
        return filter { seen.insert($0).inserted }
    }
}

extension Array where Element == MoveLearnMethod {
    /// 技IDベースで重複を除いた配列を返す
    func uniqueByMoveId() -> [MoveLearnMethod] {
        var seen = Set<Int>()
        return filter { seen.insert($0.move.id).inserted }
    }
}
