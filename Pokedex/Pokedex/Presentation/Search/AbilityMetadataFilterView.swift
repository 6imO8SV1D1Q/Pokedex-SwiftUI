//
//  AbilityMetadataFilterView.swift
//  Pokedex
//
//  特性の詳細フィルター画面
//

import SwiftUI

struct AbilityMetadataFilterView: View {
    @Environment(\.dismiss) var dismiss
    let initialFilter: AbilityMetadataFilter?
    let onSave: (AbilityMetadataFilter) -> Void

    @State private var tempFilter: AbilityMetadataFilter

    init(initialFilter: AbilityMetadataFilter? = nil, onSave: @escaping (AbilityMetadataFilter) -> Void) {
        self.initialFilter = initialFilter
        self.onSave = onSave
        self._tempFilter = State(initialValue: initialFilter ?? AbilityMetadataFilter())
    }

    var body: some View {
        NavigationStack {
            Form {
                AbilityMetadataFilterSection(
                    selectedCategories: $tempFilter.categories
                )

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
            .navigationTitle(L10n.Filter.abilityConditions)
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
            Button(L10n.Common.clear) {
                tempFilter = AbilityMetadataFilter()
            }
        }
    }

    private var applyButton: some ToolbarContent {
        ToolbarItem(placement: .confirmationAction) {
            Button(initialFilter == nil ? L10n.Common.add : L10n.Common.save) {
                onSave(tempFilter)
                dismiss()
            }
            .disabled(tempFilter.isEmpty)
        }
    }
}

#Preview {
    NavigationStack {
        AbilityMetadataFilterView(onSave: { _ in })
    }
}
