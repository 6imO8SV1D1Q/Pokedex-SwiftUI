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
}
