//
//  AbilityTriggerSection.swift
//  Pokedex
//
//  特性の発動タイミング選択セクション
//

import SwiftUI

struct AbilityTriggerSection: View {
    @Binding var selectedTriggers: Set<String>

    private let gridColumns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        Section {
            LazyVGrid(columns: gridColumns, spacing: 10) {
                ForEach(Trigger.uiCases, id: \.rawValue) { trigger in
                    GridButtonView(
                        text: trigger.displayName,
                        isSelected: selectedTriggers.contains(trigger.rawValue),
                        action: { toggleTrigger(trigger.rawValue) }
                    )
                }
            }
        } header: {
            Text(L10n.Filter.triggerTiming)
        } footer: {
            if selectedTriggers.isEmpty {
                Text(L10n.Filter.triggerTimingDescriptionEmpty)
            } else {
                Text(L10n.Filter.triggerTimingDescription)
            }
        }
    }

    private func toggleTrigger(_ triggerId: String) {
        if selectedTriggers.contains(triggerId) {
            selectedTriggers.remove(triggerId)
        } else {
            selectedTriggers.insert(triggerId)
        }
    }
}
