//
//  AbilityEffectTypeSection.swift
//  Pokedex
//
//  特性の効果タイプ選択セクション
//

import SwiftUI

struct AbilityEffectTypeSection: View {
    @Binding var selectedEffectTypes: Set<String>

    private let gridColumns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        Section {
            LazyVGrid(columns: gridColumns, spacing: 10) {
                ForEach(EffectType.uiCases, id: \.rawValue) { effectType in
                    GridButtonView(
                        text: effectType.displayName,
                        isSelected: selectedEffectTypes.contains(effectType.rawValue),
                        action: { toggleEffectType(effectType.rawValue) },
                        selectedColor: .green
                    )
                }
            }
        } header: {
            Text(L10n.Filter.effectType)
        } footer: {
            if selectedEffectTypes.isEmpty {
                Text(L10n.Filter.effectTypeDescriptionEmpty)
            } else {
                Text(L10n.Filter.effectTypeDescription)
            }
        }
    }

    private func toggleEffectType(_ effectTypeId: String) {
        if selectedEffectTypes.contains(effectTypeId) {
            selectedEffectTypes.remove(effectTypeId)
        } else {
            selectedEffectTypes.insert(effectTypeId)
        }
    }
}
