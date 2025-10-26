//
//  PokemonForm.swift
//  Pokedex
//
//  Created on 2025-10-07.
//

import Foundation

/// ポケモンのフォーム情報を表すEntity
///
/// 通常フォーム、リージョンフォーム、メガシンカ、フォルムチェンジなどを表現します。
struct PokemonForm: Equatable, Identifiable {
    /// フォームのID
    let id: Int

    /// フォーム名（英語）
    let name: String

    /// ポケモンのID
    let pokemonId: Int

    /// 種族ID（pokemon-speciesのID）
    let speciesId: Int

    /// フォーム名（"normal", "alola", "galar", "mega-x" など）
    let formName: String

    /// タイプ（最大2つ）
    let types: [PokemonType]

    /// 画像URL
    let sprites: PokemonSprites

    /// ステータス（種族値）
    let stats: [PokemonStat]

    /// 特性
    let abilities: [PokemonAbility]

    /// デフォルトフォームかどうか
    let isDefault: Bool

    /// メガシンカフォームかどうか
    let isMega: Bool

    /// リージョンフォームかどうか
    let isRegional: Bool

    /// バージョングループ
    let versionGroup: String?

    // MARK: - Computed Properties

    /// 表示用のフォーム名
    var displayFormName: String {
        switch formName {
        case "normal":
            return "通常"
        case "alola":
            return "アローラ"
        case "galar":
            return "ガラル"
        case "hisui":
            return "ヒスイ"
        case "paldea":
            return "パルデア"
        case "mega":
            return "メガシンカ"
        case "mega-x":
            return "メガシンカX"
        case "mega-y":
            return "メガシンカY"
        case "primal":
            return "ゲンシカイキ"
        default:
            // ロトムのフォームなど
            if formName.contains("heat") {
                return "ヒート"
            } else if formName.contains("wash") {
                return "ウォッシュ"
            } else if formName.contains("frost") {
                return "フロスト"
            } else if formName.contains("fan") {
                return "スピン"
            } else if formName.contains("mow") {
                return "カット"
            }

            return formName.capitalized
        }
    }
}
