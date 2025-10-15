//
//  AbilityMetadataFilterView.swift
//  Pokedex
//
//  特性の詳細フィルター画面
//

import SwiftUI

struct AbilityMetadataFilterView: View {
    @Environment(\.dismiss) var dismiss
    let onAdd: (AbilityMetadataFilter) -> Void

    @State private var tempFilter: AbilityMetadataFilter = AbilityMetadataFilter()

    var body: some View {
        NavigationStack {
            Form {
                AbilityTriggerSection(
                    selectedTriggers: $tempFilter.triggers
                )

                AbilityEffectTypeSection(
                    selectedEffectTypes: $tempFilter.effectTypes
                )

                AbilityNumericConditionSection(
                    statMultiplierCondition: $tempFilter.statMultiplierCondition,
                    movePowerMultiplierCondition: $tempFilter.movePowerMultiplierCondition,
                    probabilityCondition: $tempFilter.probabilityCondition
                )

                AbilityWeatherTerrainSection(
                    selectedWeathers: $tempFilter.weathers,
                    selectedTerrains: $tempFilter.terrains
                )
            }
            .navigationTitle("特性の条件")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                clearButton
                applyButton
            }
        }
    }

    // MARK: - Toolbar

    private var clearButton: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("クリア") {
                tempFilter = AbilityMetadataFilter()
            }
        }
    }

    private var applyButton: some ToolbarContent {
        ToolbarItem(placement: .confirmationAction) {
            Button("追加") {
                onAdd(tempFilter)
                dismiss()
            }
            .disabled(tempFilter.isEmpty)
        }
    }
}

#Preview {
    NavigationStack {
        AbilityMetadataFilterView(onAdd: { _ in })
    }
}
