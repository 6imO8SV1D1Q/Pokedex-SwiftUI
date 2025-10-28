//
//  MoveDamageClassSection.swift
//  Pokedex
//
//  技の分類フィルターセクション
//

import SwiftUI

struct MoveDamageClassSection: View {
    @Binding var selectedDamageClasses: Set<String>

    private let damageClasses: [String] = [
        "physical",
        "special",
        "status"
    ]

    private let gridColumns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        Section {
            LazyVGrid(columns: gridColumns, spacing: 10) {
                ForEach(damageClasses, id: \.self) { damageClass in
                    GridButtonView(
                        text: FilterHelpers.damageClassLabel(damageClass),
                        isSelected: selectedDamageClasses.contains(damageClass),
                        action: { toggleDamageClass(damageClass) }
                    )
                }
            }
            .padding(.vertical, 8)
        } header: {
            Text(L10n.Filter.damageClassHeader)
        }
    }

    private func toggleDamageClass(_ damageClass: String) {
        if selectedDamageClasses.contains(damageClass) {
            selectedDamageClasses.remove(damageClass)
        } else {
            selectedDamageClasses.insert(damageClass)
        }
    }
}
