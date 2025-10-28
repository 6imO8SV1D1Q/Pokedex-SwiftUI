//
//  MoveCategorySection.swift
//  Pokedex
//
//  技カテゴリー選択セクション
//

import SwiftUI

struct MoveCategorySection: View {
    @Binding var selectedCategories: Set<String>

    private let gridColumns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        Section {
            ForEach(0..<MoveCategory.categoryGroups.count, id: \.self) { groupIndex in
                let group = MoveCategory.categoryGroups[groupIndex]
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
                                text: category.name,
                                isSelected: selectedCategories.contains(category.id),
                                action: { toggleCategory(category.id) }
                            )
                        }
                    }
                }
            }
        } header: {
            Text(L10n.Filter.moveCategoryHeader)
        } footer: {
            Text(L10n.Filter.moveCategoryFooter)
        }
    }

    private func toggleCategory(_ categoryId: String) {
        if selectedCategories.contains(categoryId) {
            selectedCategories.remove(categoryId)
        } else {
            selectedCategories.insert(categoryId)
        }
    }
}
