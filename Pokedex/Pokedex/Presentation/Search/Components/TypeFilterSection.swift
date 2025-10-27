//
//  TypeFilterSection.swift
//  Pokedex
//
//  タイプフィルターセクション
//

import SwiftUI

struct TypeFilterSection: View {
    @Binding var selectedTypes: Set<String>
    @Binding var filterMode: FilterMode

    private let allTypes = [
        "normal", "fire", "water", "grass", "electric", "ice",
        "fighting", "poison", "ground", "flying", "psychic", "bug",
        "rock", "ghost", "dragon", "dark", "steel", "fairy"
    ]

    private let gridColumns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        Section {
            Picker(L10n.Filter.searchMode, selection: $filterMode) {
                Text(L10n.Filter.or).tag(FilterMode.or)
                Text(L10n.Filter.and).tag(FilterMode.and)
            }
            .pickerStyle(.segmented)

            LazyVGrid(columns: gridColumns, spacing: 10) {
                ForEach(allTypes, id: \.self) { typeName in
                    GridButtonView(
                        text: FilterHelpers.typeJapaneseName(typeName),
                        isSelected: selectedTypes.contains(typeName),
                        action: { toggleType(typeName) }
                    )
                }
            }
            .padding(.vertical, 8)
        } header: {
            Text(L10n.Filter.type)
        } footer: {
            Text(filterMode == .or ? L10n.Filter.typeOrDescription : L10n.Filter.typeAndDescription)
        }
    }

    private func toggleType(_ typeName: String) {
        if selectedTypes.contains(typeName) {
            selectedTypes.remove(typeName)
        } else {
            selectedTypes.insert(typeName)
        }
    }
}
