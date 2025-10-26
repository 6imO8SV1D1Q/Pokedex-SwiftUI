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
        preferredVersion: String? = nil
    ) -> PokemonFlavorText? {
        guard let flavorTextEntries = species.flavorTextEntries else {
            return nil
        }

        // preferredVersionが指定されている場合（例: "scarlet" または "violet"）
        if let preferredVersion = preferredVersion {
            // 完全一致で検索
            let matchingTexts = flavorTextEntries.filter { entry in
                entry.version?.name == preferredVersion
            }

            // 日本語を優先的に取得
            if let jaText = matchingTexts.first(where: { $0.language?.name == "ja" }) {
                return PokemonFlavorText(
                    text: jaText.flavorText ?? "",
                    language: "ja",
                    versionGroup: preferredVersion
                )
            }

            // 日本語がなければ英語
            if let enText = matchingTexts.first(where: { $0.language?.name == "en" }) {
                return PokemonFlavorText(
                    text: enText.flavorText ?? "",
                    language: "en",
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

            // マッチした中から日本語を優先的に取得（最後のものが最新）
            if let jaText = matchingTexts.last(where: { $0.language?.name == "ja" }) {
                return PokemonFlavorText(
                    text: jaText.flavorText ?? "",
                    language: "ja",
                    versionGroup: versionGroup  // 指定されたversionGroupをそのまま使用
                )
            }

            // 日本語がなければ英語（最後のものが最新）
            if let enText = matchingTexts.last(where: { $0.language?.name == "en" }) {
                return PokemonFlavorText(
                    text: enText.flavorText ?? "",
                    language: "en",
                    versionGroup: versionGroup  // 指定されたversionGroupをそのまま使用
                )
            }
        }

        // バージョングループ指定なし、または見つからない場合は最新の日本語テキスト
        if let jaText = flavorTextEntries.last(where: { $0.language?.name == "ja" }) {
            return PokemonFlavorText(
                text: jaText.flavorText ?? "",
                language: "ja",
                versionGroup: versionGroup ?? jaText.version?.name ?? "unknown"
            )
        }

        // 日本語がなければ最新の英語テキスト
        if let enText = flavorTextEntries.last(where: { $0.language?.name == "en" }) {
            return PokemonFlavorText(
                text: enText.flavorText ?? "",
                language: "en",
                versionGroup: versionGroup ?? enText.version?.name ?? "unknown"
            )
        }

        return nil
    }
}
