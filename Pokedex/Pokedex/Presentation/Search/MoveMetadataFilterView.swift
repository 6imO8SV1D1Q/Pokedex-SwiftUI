//
//  MoveMetadataFilterView.swift
//  Pokedex
//
//  技の条件フィルター画面（リファクタリング版）
//

import SwiftUI

struct MoveMetadataFilterView: View {
    @Environment(\.dismiss) var dismiss
    let onAdd: (MoveMetadataFilter) -> Void

    @State private var tempFilter: MoveMetadataFilter = MoveMetadataFilter()

    var body: some View {
        NavigationStack {
            Form {
                MoveTypeSection(
                    selectedTypes: $tempFilter.types
                )

                MoveDamageClassSection(
                    selectedDamageClasses: $tempFilter.damageClasses
                )

                MoveNumericConditionSection(
                    powerCondition: $tempFilter.powerCondition,
                    accuracyCondition: $tempFilter.accuracyCondition,
                    ppCondition: $tempFilter.ppCondition
                )

                MovePrioritySection(
                    priority: $tempFilter.priority
                )

                MoveTargetSection(
                    selectedTargets: $tempFilter.targets
                )

                MoveCategorySection(
                    selectedCategories: $tempFilter.categories
                )

                MoveStatChangeSection(
                    selectedStatChanges: $tempFilter.statChanges,
                    isUser: true
                )

                MoveStatChangeSection(
                    selectedStatChanges: $tempFilter.statChanges,
                    isUser: false
                )
            }
            .navigationTitle("技の条件")
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
                tempFilter = MoveMetadataFilter()
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
