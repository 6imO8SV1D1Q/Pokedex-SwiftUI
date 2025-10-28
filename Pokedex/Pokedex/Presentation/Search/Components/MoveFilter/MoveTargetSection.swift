//
//  MoveTargetSection.swift
//  Pokedex
//
//  技の対象選択セクション
//

import SwiftUI

struct MoveTargetSection: View {
    @Binding var selectedTargets: Set<String>

    private let targets: [String] = [
        "selected-pokemon",
        "user",
        "all-opponents",
        "all-other-pokemon",
        "user-and-allies",
        "all-pokemon"
    ]

    private let gridColumns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        Section {
            LazyVGrid(columns: gridColumns, spacing: 10) {
                ForEach(targets, id: \.self) { target in
                    GridButtonView(
                        text: FilterHelpers.targetJapaneseName(target),
                        isSelected: selectedTargets.contains(target),
                        action: { toggleTarget(target) }
                    )
                }
            }
            .padding(.vertical, 8)
        } header: {
            Text(L10n.Filter.moveTarget)
        }
    }

    private func toggleTarget(_ target: String) {
        if selectedTargets.contains(target) {
            selectedTargets.remove(target)
        } else {
            selectedTargets.insert(target)
        }
    }
}
