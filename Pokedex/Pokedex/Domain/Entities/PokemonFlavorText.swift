//
//  PokemonFlavorText.swift
//  Pokedex
//
//  Created on 2025-10-07.
//

import Foundation

/// ポケモンの図鑑説明（フレーバーテキスト）を表すEntity
struct PokemonFlavorText: Equatable {
    /// 説明文
    let text: String

    /// 言語（"ja", "en" など）
    let language: String

    /// バージョングループ
    let versionGroup: String
}
