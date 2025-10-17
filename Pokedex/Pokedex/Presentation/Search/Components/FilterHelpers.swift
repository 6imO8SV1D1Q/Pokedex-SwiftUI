//
//  FilterHelpers.swift
//  Pokedex
//
//  フィルター画面用のヘルパー関数
//

import Foundation

enum FilterHelpers {
    /// タイプ名を日本語に変換
    static func typeJapaneseName(_ typeName: String) -> String {
        switch typeName {
        case "normal": return "ノーマル"
        case "fire": return "ほのお"
        case "water": return "みず"
        case "grass": return "くさ"
        case "electric": return "でんき"
        case "ice": return "こおり"
        case "fighting": return "かくとう"
        case "poison": return "どく"
        case "ground": return "じめん"
        case "flying": return "ひこう"
        case "psychic": return "エスパー"
        case "bug": return "むし"
        case "rock": return "いわ"
        case "ghost": return "ゴースト"
        case "dragon": return "ドラゴン"
        case "dark": return "あく"
        case "steel": return "はがね"
        case "fairy": return "フェアリー"
        default: return typeName.capitalized
        }
    }

    /// ダメージクラスのラベルを日本語に変換
    static func damageClassLabel(_ damageClass: String) -> String {
        switch damageClass {
        case "physical": return "物理"
        case "special": return "特殊"
        case "status": return "変化"
        default: return damageClass
        }
    }

    /// 回復効果のテキストを生成
    static func healingEffectsText(filter: MoveMetadataFilter) -> String {
        var effects: [String] = []
        if filter.hasDrain { effects.append("HP吸収") }
        if filter.hasHealing { effects.append("HP回復") }
        return effects.joined(separator: ", ")
    }

    /// 技の対象を日本語に変換
    static func targetJapaneseName(_ target: String) -> String {
        switch target {
        case "selected-pokemon": return "相手1体"
        case "selected-pokemon-me-first": return "相手1体（先制）"
        case "ally": return "味方1体"
        case "users-field": return "自分の場"
        case "user-or-ally": return "自分か味方"
        case "opponents-field": return "相手の場"
        case "user": return "自分"
        case "random-opponent": return "ランダムな相手"
        case "all-other-pokemon": return "自分以外"
        case "all-opponents": return "相手全体"
        case "entire-field": return "場全体"
        case "user-and-allies": return "自分と味方"
        case "all-pokemon": return "場の全員"
        case "all-allies": return "味方全体"
        case "specific-move": return "特定の技"
        case "fainting-pokemon": return "ひんし直前"
        default: return target
        }
    }
}
