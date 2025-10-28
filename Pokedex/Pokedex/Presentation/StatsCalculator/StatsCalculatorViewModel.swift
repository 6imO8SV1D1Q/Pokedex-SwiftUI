//
//  StatsCalculatorViewModel.swift
//  Pokedex
//
//  Created on 2025-10-26.
//

import Foundation
import SwiftUI
import Combine

/// 実数値計算機画面のViewModel
@MainActor
final class StatsCalculatorViewModel: ObservableObject {
    // MARK: - Published Properties

    // ポケモン選択
    @Published var searchText: String = "" {
        didSet {
            Task {
                await filterPokemon()
            }
        }
    }
    @Published var selectedPokemon: Pokemon?
    @Published var filteredPokemon: [Pokemon] = []
    @Published var isLoadingPokemon: Bool = false

    // 入力値
    @Published var level: Int = 50
    @Published var ivs: [String: Int] = [
        "hp": 31, "attack": 31, "defense": 31,
        "special-attack": 31, "special-defense": 31, "speed": 31
    ]
    @Published var evs: [String: Int] = [
        "hp": 0, "attack": 0, "defense": 0,
        "special-attack": 0, "special-defense": 0, "speed": 0
    ]
    @Published var nature: [String: NatureModifier] = [
        "attack": .neutral, "defense": .neutral,
        "special-attack": .neutral, "special-defense": .neutral, "speed": .neutral
    ]

    // 計算結果
    @Published var calculatedStats: [String: Int] = [:]

    // MARK: - Private Properties

    private var allPokemon: [Pokemon] = []

    // MARK: - Computed Properties

    var remainingEVs: Int {
        let totalEVs = evs.values.reduce(0, +)
        return 510 - totalEVs
    }

    var isEVOverLimit: Bool {
        remainingEVs < 0
    }

    // MARK: - Dependencies

    private let pokemonRepository: PokemonRepositoryProtocol

    // MARK: - Initialization

    init(pokemonRepository: PokemonRepositoryProtocol) {
        self.pokemonRepository = pokemonRepository
        Task {
            await loadAllPokemon()
        }
    }

    // MARK: - Methods

    /// 全ポケモンをロード
    @MainActor
    private func loadAllPokemon() async {
        isLoadingPokemon = true
        do {
            allPokemon = try await pokemonRepository.fetchPokemonList(versionGroup: .nationalDex, progressHandler: nil)
            print("📋 Loaded \(allPokemon.count) pokemon for stats calculator")
        } catch {
            print("❌ Failed to load pokemon: \(error)")
        }
        isLoadingPokemon = false
    }

    /// 検索テキスト変更時の絞り込み
    @MainActor
    func filterPokemon() async {
        guard !searchText.isEmpty else {
            filteredPokemon = []
            return
        }

        let query = searchText.lowercased()

        filteredPokemon = allPokemon.filter { pokemon in
            // 名前で検索（日本語・英語両方）
            let nameMatch = pokemon.name.lowercased().contains(query) ||
                           (pokemon.nameJa?.lowercased().contains(query) ?? false)

            // 図鑑番号で検索
            let numberMatch = pokemon.nationalDexNumber.map { String($0).contains(query) } ?? false

            return nameMatch || numberMatch
        }
    }

    /// ポケモン選択時の処理
    func selectPokemon(_ pokemon: Pokemon) {
        selectedPokemon = pokemon
        resetInputs()
        calculateStats()
    }

    /// 入力値をデフォルトにリセット
    func resetInputs() {
        level = 50
        ivs = [
            "hp": 31, "attack": 31, "defense": 31,
            "special-attack": 31, "special-defense": 31, "speed": 31
        ]
        evs = [
            "hp": 0, "attack": 0, "defense": 0,
            "special-attack": 0, "special-defense": 0, "speed": 0
        ]
        nature = [
            "attack": .neutral, "defense": .neutral,
            "special-attack": .neutral, "special-defense": .neutral, "speed": .neutral
        ]
    }

    /// すべてのIVを31に設定
    func setAllIVsToMax() {
        ivs = ivs.mapValues { _ in 31 }
        calculateStats()
    }

    /// すべてのIVを0に設定
    func setAllIVsToMin() {
        ivs = ivs.mapValues { _ in 0 }
        calculateStats()
    }

    /// EVの増減（+ボタン）
    func incrementEV(for stat: String) {
        guard let currentValue = evs[stat] else { return }

        // 既に252に達している場合は何もしない
        if currentValue >= 252 {
            return
        }

        // 増加量を決定（0の場合は4、それ以外は8）
        let increment = currentValue == 0 ? 4 : 8
        let newValue = min(currentValue + increment, 252)

        // 510制限チェック
        let totalEVs = evs.values.reduce(0, +)
        let newTotal = totalEVs - currentValue + newValue

        if newTotal <= 510 {
            evs[stat] = newValue
            calculateStats()
        }
    }

    /// EVの減少（-ボタン）
    func decrementEV(for stat: String) {
        guard let currentValue = evs[stat] else { return }

        // 既に0の場合は何もしない
        if currentValue <= 0 {
            return
        }

        // 減少量を決定（4以下の場合は現在値、4より大きい場合は8）
        let decrement = currentValue <= 4 ? currentValue : 8
        let newValue = max(currentValue - decrement, 0)

        evs[stat] = newValue
        calculateStats()
    }

    /// 性格補正の変更
    func setNature(for stat: String, modifier: NatureModifier) {
        // 現在の補正状態を確認
        let currentModifier = nature[stat] ?? .neutral

        // 同じ補正を選択した場合は何もしない
        if currentModifier == modifier {
            return
        }

        // 制約チェック
        if modifier == .boosted {
            // 既に他のステータスが↑の場合は、そのステータスをneutralに戻す
            for (key, value) in nature where value == .boosted && key != stat {
                nature[key] = .neutral
            }
        } else if modifier == .hindered {
            // 既に他のステータスが↓の場合は、そのステータスをneutralに戻す
            for (key, value) in nature where value == .hindered && key != stat {
                nature[key] = .neutral
            }
        }

        nature[stat] = modifier
        calculateStats()
    }

    /// 実数値計算
    func calculateStats() {
        guard let pokemon = selectedPokemon else {
            calculatedStats = [:]
            return
        }

        var results: [String: Int] = [:]

        let statKeys = ["hp", "attack", "defense", "special-attack", "special-defense", "speed"]

        for statKey in statKeys {
            // 種族値を取得
            guard let baseStat = pokemon.stats.first(where: { $0.name == statKey })?.baseStat else {
                continue
            }

            // 個体値・努力値を取得
            let iv = ivs[statKey] ?? 0
            let ev = evs[statKey] ?? 0

            // 性格補正を取得（HPには補正なし）
            let natureModifier = statKey == "hp" ? 1.0 : (nature[statKey] ?? .neutral).multiplier

            // 実数値計算
            let calculatedValue: Int

            if statKey == "hp" {
                // HP計算式: floor((base * 2 + iv + floor(ev / 4)) * level / 100) + level + 10
                let base = Double(baseStat * 2 + iv + (ev / 4))
                calculatedValue = Int(floor(base * Double(level) / 100.0)) + level + 10
            } else {
                // その他のステータス計算式: floor((floor((base * 2 + iv + floor(ev / 4)) * level / 100) + 5) * nature_modifier)
                let base = Double(baseStat * 2 + iv + (ev / 4))
                let beforeNature = Int(floor(base * Double(level) / 100.0)) + 5
                calculatedValue = Int(floor(Double(beforeNature) * natureModifier))
            }

            results[statKey] = calculatedValue
        }

        calculatedStats = results
    }
}

/// 性格補正の列挙型
enum NatureModifier: Equatable {
    case boosted   // ↑ (1.1倍)
    case neutral   // - (1.0倍)
    case hindered  // ↓ (0.9倍)

    var multiplier: Double {
        switch self {
        case .boosted: return 1.1
        case .neutral: return 1.0
        case .hindered: return 0.9
        }
    }
}
