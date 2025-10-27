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
}
