//
//  MoveTargetSection.swift
//  Pokedex
//
//  技の対象選択セクション
//

import SwiftUI

struct MoveTargetSection: View {
    @Binding var selectedTargets: Set<String>

    private let targets: [(id: String, label: String)] = [
        ("selected-pokemon", "相手単体"),
        ("user", "自分"),
        ("all-opponents", "相手全体"),
        ("all-other-pokemon", "自分以外"),
        ("user-and-allies", "味方全体"),
        ("all-pokemon", "全員")
    ]

    private let gridColumns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        Section {
            LazyVGrid(columns: gridColumns, spacing: 10) {
                ForEach(targets, id: \.id) { target in
                    GridButtonView(
                        text: target.label,
                        isSelected: selectedTargets.contains(target.id),
                        action: { toggleTarget(target.id) }
                    )
                }
            }
            .padding(.vertical, 8)
        } header: {
            Text("技の対象")
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
