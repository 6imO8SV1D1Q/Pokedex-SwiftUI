//
//  GetAbilityCategoriesUseCase.swift
//  Pokedex
//
//  特性のカテゴリ情報を取得するUseCase
//  Created by Claude Code on 2025-10-15.
//

import Foundation

/// 特性カテゴリマッピング
struct AbilityCategoryMapping: Codable {
    let abilityCategories: [String: [String]]

    enum CodingKeys: String, CodingKey {
        case abilityCategories = "ability_categories"
    }
}

protocol GetAbilityCategoriesUseCaseProtocol {
    func execute() -> [String: [AbilityCategory]]
}

struct GetAbilityCategoriesUseCase: GetAbilityCategoriesUseCaseProtocol {

    func execute() -> [String: [AbilityCategory]] {
        guard let url = Bundle.main.url(forResource: "ability_categories", withExtension: "json", subdirectory: "Resources/PreloadedData") else {
            print("❌ ability_categories.json not found")
            return [:]
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let mapping = try decoder.decode(AbilityCategoryMapping.self, from: data)

            // String配列をAbilityCategory enumに変換
            var result: [String: [AbilityCategory]] = [:]
            for (abilityName, categoryStrings) in mapping.abilityCategories {
                let categories = categoryStrings.compactMap { AbilityCategory(rawValue: $0) }
                if !categories.isEmpty {
                    result[abilityName] = categories
                }
            }

            print("✅ Loaded categories for \(result.count) abilities")
            return result

        } catch {
            print("❌ Failed to decode ability_categories.json: \(error)")
            return [:]
        }
    }
}
