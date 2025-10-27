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
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        Section {
            ForEach(0..<AbilityCategory.categoryGroups.count, id: \.self) { groupIndex in
                let group = AbilityCategory.categoryGroups[groupIndex]
                VStack(alignment: .leading, spacing: 8) {
                    // グループ名
                    Text(group.name)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .padding(.top, groupIndex > 0 ? 8 : 0)

                    // カテゴリーボタン
                    LazyVGrid(columns: gridColumns, spacing: 10) {
                        ForEach(group.categories, id: \.id) { category in
                            GridButtonView(
                                text: category.displayName,
                                isSelected: selectedCategories.contains(category),
                                action: { toggleCategory(category) },
                                selectedColor: .orange
                            )
                        }
                    }
                }
            }
        } header: {
            Text(L10n.Filter.abilityCategory)
        } footer: {
            if selectedCategories.isEmpty {
                Text(L10n.Filter.abilityCategoryDescriptionEmpty)
            } else {
                Text(L10n.Filter.abilityCategoryDescription)
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
