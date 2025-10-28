//
//  CategoryFilterSection.swift
//  Pokedex
//
//  区分フィルターセクション
//

import SwiftUI

struct CategoryFilterSection: View {
    @Binding var selectedCategories: Set<PokemonCategory>

    private let gridColumns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        Section {
            LazyVGrid(columns: gridColumns, spacing: 10) {
                ForEach(PokemonCategory.allCases) { category in
                    GridButtonView(
                        text: category.displayName,
                        isSelected: selectedCategories.contains(category),
                        action: { toggleCategory(category) },
                        selectedColor: .purple
                    )
                }
            }
            .padding(.vertical, 8)
        } header: {
            Text(L10n.Filter.region)
        } footer: {
            Text(L10n.Filter.regionDescription)
        }
    }

    private func toggleCategory(_ category: PokemonCategory) {
        if selectedCategories.contains(category) {
            selectedCategories.remove(category)
        } else {
            selectedCategories.insert(category)
        }
    }
}
