//
//  MoveDamageClassSection.swift
//  Pokedex
//
//  技の分類フィルターセクション
//

import SwiftUI

struct MoveDamageClassSection: View {
    @Binding var selectedDamageClasses: Set<String>

    private let damageClasses: [(id: String, label: String)] = [
        ("physical", "物理"),
        ("special", "特殊"),
        ("status", "変化")
    ]

    private let gridColumns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        Section {
            LazyVGrid(columns: gridColumns, spacing: 10) {
                ForEach(damageClasses, id: \.id) { damageClass in
                    GridButtonView(
                        text: damageClass.label,
                        isSelected: selectedDamageClasses.contains(damageClass.id),
                        action: { toggleDamageClass(damageClass.id) }
                    )
                }
            }
            .padding(.vertical, 8)
        } header: {
            Text("分類")
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
