//
//  FlavorTextMapper.swift
//  Pokedex
//
//  Created on 2025-10-07.
//

import Foundation
import PokemonAPI

enum FlavorTextMapper {
    /// PKMPokemonSpeciesからPokemonFlavorTextにマッピング
    nonisolated static func mapFlavorText(
        from species: PKMPokemonSpecies,
        versionGroup: String?
    ) -> PokemonFlavorText? {
        guard let flavorTextEntries = species.flavorTextEntries else {
            return nil
        }

        // バージョングループが指定されている場合
        if let versionGroup = versionGroup {
            // 日本語のフレーバーテキストを優先的に取得
            if let jaText = flavorTextEntries.first(where: {
                $0.language?.name == "ja" && $0.version?.name?.contains(versionGroup) == true
            }) {
                return PokemonFlavorText(
                    text: jaText.flavorText ?? "",
                    language: "ja",
                    versionGroup: versionGroup
                )
            }

            // 日本語がなければ英語
            if let enText = flavorTextEntries.first(where: {
                $0.language?.name == "en" && $0.version?.name?.contains(versionGroup) == true
            }) {
                return PokemonFlavorText(
                    text: enText.flavorText ?? "",
                    language: "en",
                    versionGroup: versionGroup
                )
            }
        }

        // バージョングループ指定なし、または見つからない場合は最新の日本語テキスト
        if let jaText = flavorTextEntries.last(where: { $0.language?.name == "ja" }) {
            return PokemonFlavorText(
                text: jaText.flavorText ?? "",
                language: "ja",
                versionGroup: jaText.version?.name ?? "unknown"
            )
        }

        // 日本語がなければ最新の英語テキスト
        if let enText = flavorTextEntries.last(where: { $0.language?.name == "en" }) {
            return PokemonFlavorText(
                text: enText.flavorText ?? "",
                language: "en",
                versionGroup: enText.version?.name ?? "unknown"
            )
        }

        return nil
    }
}
