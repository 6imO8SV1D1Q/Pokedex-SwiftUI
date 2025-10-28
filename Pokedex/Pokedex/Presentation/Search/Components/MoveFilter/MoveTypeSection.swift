//
//  MoveTypeSection.swift
//  Pokedex
//
//  技のタイプフィルターセクション
//

import SwiftUI

struct MoveTypeSection: View {
    @Binding var selectedTypes: Set<String>

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
            Text(L10n.Filter.moveType)
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
