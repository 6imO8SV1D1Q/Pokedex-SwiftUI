//
//  AbilityMetadataFilterSection.swift
//  Pokedex
//
//  特性メタデータフィルターセクション
//  特性のカテゴリ（天候設定、能力上昇など）でフィルタリング
//

import SwiftUI

struct AbilityMetadataFilterSection: View {
    @Binding var selectedCategories: Set<AbilityCategory>

    private let gridColumns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        Section {
            LazyVGrid(columns: gridColumns, spacing: 10) {
                ForEach(AbilityCategory.allCases) { category in
                    GridButtonView(
                        text: category.displayName,
                        isSelected: selectedCategories.contains(category),
                        action: { toggleCategory(category) },
                        selectedColor: .orange
                    )
                }
            }
            .padding(.vertical, 8)
        } header: {
            Text("特性カテゴリ")
        } footer: {
            if selectedCategories.isEmpty {
                Text("特性の種類でフィルタリングできます")
            } else {
                Text("選択したカテゴリのいずれかに該当する特性を持つポケモンを表示")
            }
        }
    }

    private func toggleCategory(_ category: AbilityCategory) {
        if selectedCategories.contains(category) {
            selectedCategories.remove(category)
        } else {
            selectedCategories.insert(category)
        }
    }
}

#Preview {
    Form {
        AbilityMetadataFilterSection(selectedCategories: .constant([.weatherSetter, .statBoost]))
    }
}
