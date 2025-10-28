//
//  FilterHelpers.swift
//  Pokedex
//
//  フィルター画面用のヘルパー関数
//

import Foundation

enum FilterHelpers {
    /// タイプ名をローカライズして取得
    static func typeJapaneseName(_ typeName: String) -> String {
        return L10n.PokemonType.localizedString(typeName)
    }

    /// ダメージクラスのラベルをローカライズして取得
    static func damageClassLabel(_ damageClass: String) -> String {
        return L10n.DamageClass.localizedString(damageClass)
    }

    /// 回復効果のテキストを生成
    static func healingEffectsText(filter: MoveMetadataFilter) -> String {
        var effects: [String] = []
        if filter.hasDrain { effects.append(NSLocalizedString("filter.hp_drain", comment: "")) }
        if filter.hasHealing { effects.append(NSLocalizedString("filter.hp_healing", comment: "")) }
        return effects.joined(separator: ", ")
    }

    /// 技の対象をローカライズして取得
    static func targetJapaneseName(_ target: String) -> String {
        return L10n.Target.localizedString(target)
    }

    /// たまごグループ名をローカライズして取得
    static func eggGroupName(_ name: String) -> String {
        return L10n.EggGroup.localizedString(name)
    }

    /// ステータス名をローカライズして取得
    static func statName(_ name: String) -> String {
        let key = name.replacingOccurrences(of: "-", with: "_")
        return NSLocalizedString("stat.\(key)", comment: "")
    }

    /// パターン名をローカライズして取得
    static func patternName(_ patternId: String) -> String {
        return L10n.PatternName.localizedString(patternId)
    }

    /// 性別比の表示テキストを生成
    static func genderRatioText(genderRate: Int) -> String {
        if genderRate == -1 {
            return L10n.GenderRatio.unknown
        }
        let femaleRate = Double(genderRate) / 8.0 * 100.0
        let maleRate = 100.0 - femaleRate
        return String(format: "♂ %.1f%% / ♀ %.1f%%", maleRate, femaleRate)
    }
}
