//
//  PokemonLocation.swift
//  Pokedex
//
//  Created on 2025-10-07.
//

import Foundation

/// ポケモンの生息地情報を表すEntity
struct PokemonLocation: Equatable {
    /// 生息地名
    let locationName: String

    /// バージョンごとの詳細情報
    let versionDetails: [LocationVersionDetail]

    /// バージョンごとの生息地詳細
    struct LocationVersionDetail: Equatable {
        /// バージョン名
        let version: String

        /// 出現情報のリスト
        let encounterDetails: [EncounterDetail]
    }

    /// 出現情報
    struct EncounterDetail: Equatable {
        /// 最低レベル
        let minLevel: Int

        /// 最高レベル
        let maxLevel: Int

        /// 出現方法（"walk", "surf", "old-rod" など）
        let method: String

        /// 出現率（パーセント）
        let chance: Int

        /// 表示用の出現方法
        var displayMethod: String {
            switch method {
            case "walk":
                return "歩く"
            case "surf":
                return "なみのり"
            case "old-rod":
                return "ボロのつりざお"
            case "good-rod":
                return "いいつりざお"
            case "super-rod":
                return "すごいつりざお"
            case "rock-smash":
                return "いわくだき"
            case "headbutt":
                return "ずつき"
            case "gift":
                return "もらう"
            case "gift-egg":
                return "タマゴをもらう"
            default:
                return method.capitalized
            }
        }
    }
}
