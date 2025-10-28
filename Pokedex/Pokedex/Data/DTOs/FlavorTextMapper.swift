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
        versionGroup: String?,
        preferredVersion: String? = nil,
        preferredLanguage: String = "ja"
    ) -> PokemonFlavorText? {
        guard let flavorTextEntries = species.flavorTextEntries else {
            return nil
        }

        let secondaryLanguage = preferredLanguage == "ja" ? "en" : "ja"

        // preferredVersionが指定されている場合（例: "scarlet" または "violet"）
        if let preferredVersion = preferredVersion {
            // 完全一致で検索
            let matchingTexts = flavorTextEntries.filter { entry in
                entry.version?.name == preferredVersion
            }

            // 優先言語を取得
            if let preferredText = matchingTexts.first(where: { $0.language?.name == preferredLanguage }) {
                return PokemonFlavorText(
                    text: preferredText.flavorText ?? "",
                    language: preferredLanguage,
                    versionGroup: preferredVersion
                )
            }

            // 優先言語がなければ代替言語
            if let fallbackText = matchingTexts.first(where: { $0.language?.name == secondaryLanguage }) {
                return PokemonFlavorText(
                    text: fallbackText.flavorText ?? "",
                    language: secondaryLanguage,
                    versionGroup: preferredVersion
                )
            }
        }

        // バージョングループが指定されている場合（後方互換性のため残す）
        if let versionGroup = versionGroup {
            // versionGroup (例: "scarlet-violet") に version.name (例: "scarlet", "violet") が含まれるかチェック
            let matchingTexts = flavorTextEntries.filter { entry in
                if let versionName = entry.version?.name {
                    return versionGroup.contains(versionName)
                }
                return false
            }

            // マッチした中から優先言語を取得（最後のものが最新）
            if let preferredText = matchingTexts.last(where: { $0.language?.name == preferredLanguage }) {
                return PokemonFlavorText(
                    text: preferredText.flavorText ?? "",
                    language: preferredLanguage,
                    versionGroup: versionGroup
                )
            }

            // 優先言語がなければ代替言語（最後のものが最新）
            if let fallbackText = matchingTexts.last(where: { $0.language?.name == secondaryLanguage }) {
                return PokemonFlavorText(
                    text: fallbackText.flavorText ?? "",
                    language: secondaryLanguage,
                    versionGroup: versionGroup
                )
            }
        }

        // バージョングループ指定なし、または見つからない場合は優先言語のテキスト
        if let preferredText = flavorTextEntries.last(where: { $0.language?.name == preferredLanguage }) {
            return PokemonFlavorText(
                    text: preferredText.flavorText ?? "",
                language: preferredLanguage,
                versionGroup: versionGroup ?? preferredText.version?.name ?? "unknown"
            )
        }

        // 優先言語がなければ代替言語のテキスト
        if let fallbackText = flavorTextEntries.last(where: { $0.language?.name == secondaryLanguage }) {
            return PokemonFlavorText(
                text: fallbackText.flavorText ?? "",
                language: secondaryLanguage,
                versionGroup: versionGroup ?? fallbackText.version?.name ?? "unknown"
            )
        }

        return nil
    }
}
