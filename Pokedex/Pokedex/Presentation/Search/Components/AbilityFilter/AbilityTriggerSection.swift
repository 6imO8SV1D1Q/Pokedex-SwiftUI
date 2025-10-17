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
            Text("発動タイミング")
        } footer: {
            if selectedTriggers.isEmpty {
                Text("発動タイミングでフィルタリングできます")
            } else {
                Text("選択したタイミングのいずれかで発動する特性を表示")
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
