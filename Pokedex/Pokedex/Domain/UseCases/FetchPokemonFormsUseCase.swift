//
//  FetchPokemonFormsUseCase.swift
//  Pokedex
//
//  Created on 2025-10-07.
//

import Foundation

/// ポケモンのフォーム一覧を取得するUseCaseのプロトコル
protocol FetchPokemonFormsUseCaseProtocol {
    /// ポケモンのフォーム一覧を取得
    /// - Parameters:
    ///   - pokemonId: ポケモンID
    ///   - versionGroup: バージョングループ（nilの場合は全フォーム）
    /// - Returns: フォームのリスト
    func execute(pokemonId: Int, versionGroup: String?) async throws -> [PokemonForm]
}

/// ポケモンのフォーム一覧を取得するUseCase
final class FetchPokemonFormsUseCase: FetchPokemonFormsUseCaseProtocol {
    private let pokemonRepository: PokemonRepositoryProtocol

    init(pokemonRepository: PokemonRepositoryProtocol) {
        self.pokemonRepository = pokemonRepository
    }

    func execute(pokemonId: Int, versionGroup: String?) async throws -> [PokemonForm] {
        let allForms = try await pokemonRepository.fetchPokemonForms(pokemonId: pokemonId)

        // バージョングループ指定がない場合は全フォームを返す
        guard let versionGroup = versionGroup else {
            return allForms
        }

        // バージョングループでフィルタリング
        return filterByVersionGroup(forms: allForms, versionGroup: versionGroup)
    }

    // MARK: - Private Methods

    /// バージョングループでフォームをフィルタリング
    private func filterByVersionGroup(forms: [PokemonForm], versionGroup: String) -> [PokemonForm] {
        forms.filter { form in
            // デフォルトフォームは常に含める
            if form.isDefault {
                return true
            }

            // メガシンカ：X-Y以降
            if form.isMega {
                return isVersionGroupAfter(versionGroup, thanOrEqualTo: "x-y")
            }

            // リージョンフォーム
            if form.isRegional {
                // アローラフォーム：サン・ムーン以降
                if form.formName.contains("alola") {
                    return isVersionGroupAfter(versionGroup, thanOrEqualTo: "sun-moon")
                }
                // ガラルフォーム：ソード・シールド以降
                if form.formName.contains("galar") {
                    return isVersionGroupAfter(versionGroup, thanOrEqualTo: "sword-shield")
                }
                // ヒスイフォーム：レジェンズアルセウス以降
                if form.formName.contains("hisui") {
                    return isVersionGroupAfter(versionGroup, thanOrEqualTo: "legends-arceus")
                }
                // パルデアフォーム：スカーレット・バイオレット以降
                if form.formName.contains("paldea") {
                    return isVersionGroupAfter(versionGroup, thanOrEqualTo: "scarlet-violet")
                }
            }

            // バージョングループが一致するフォーム
            if let formVersionGroup = form.versionGroup {
                return formVersionGroup == versionGroup
            }

            // その他のフォームは含める
            return true
        }
    }

    /// バージョングループの順序を比較
    private func isVersionGroupAfter(_ versionGroup: String, thanOrEqualTo threshold: String) -> Bool {
        let order = [
            "red-blue", "yellow",
            "gold-silver", "crystal",
            "ruby-sapphire", "emerald", "firered-leafgreen",
            "diamond-pearl", "platinum", "heartgold-soulsilver",
            "black-white", "black-2-white-2",
            "x-y", "omega-ruby-alpha-sapphire",
            "sun-moon", "ultra-sun-ultra-moon",
            "sword-shield",
            "legends-arceus",
            "scarlet-violet"
        ]

        guard let currentIndex = order.firstIndex(of: versionGroup),
              let thresholdIndex = order.firstIndex(of: threshold) else {
            return false
        }

        return currentIndex >= thresholdIndex
    }
}
