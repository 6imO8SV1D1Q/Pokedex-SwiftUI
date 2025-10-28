//
//  AbilityDetailMapper.swift
//  Pokedex
//
//  Created on 2025-10-07.
//

import Foundation
import PokemonAPI

enum AbilityDetailMapper {
    /// PKMAbilityからAbilityDetailにマッピング
    nonisolated static func map(from pkmAbility: PKMAbility, isHidden: Bool = false) -> AbilityDetail {
        let id = pkmAbility.id ?? 0
        let name = pkmAbility.name ?? "unknown"

        // nameJa（特性名、日本語）を取得
        let nameJa = pkmAbility.names?.first(where: { $0.language?.name == "ja" })?.name

        // effect（対戦向け説明、英語）を取得
        let effect = pkmAbility.effectEntries?.first(where: { $0.language?.name == "en" })?.effect ?? ""

        // effectJa（対戦向け説明、日本語）を取得
        let effectJa = pkmAbility.effectEntries?.first(where: { $0.language?.name == "ja" })?.effect

        // flavorText（ゲーム内説明、日本語）を取得
        let flavorText = pkmAbility.flavorTextEntries?.first(where: { $0.language?.name == "ja" })?.flavorText

        return AbilityDetail(
            id: id,
            name: name,
            nameJa: nameJa,
            effect: effect,
            effectJa: effectJa,
            flavorText: flavorText,
            isHidden: isHidden
        )
    }
}
