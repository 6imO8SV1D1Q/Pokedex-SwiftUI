//
//  MoveStatChangeSection.swift
//  Pokedex
//
//  技の能力変化選択セクション
//

import SwiftUI

struct MoveStatChangeSection: View {
    @Binding var selectedStatChanges: Set<StatChangeFilter>
    let isUser: Bool

    private let gridColumns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        Section {
            LazyVGrid(columns: gridColumns, spacing: 10) {
                ForEach(StatChangeFilter.allCases.filter { $0.statChangeInfo.isUser == isUser }) { statChange in
                    GridButtonView(
                        text: statChange.rawValue,
                        isSelected: selectedStatChanges.contains(statChange),
                        action: { toggleStatChange(statChange) }
                    )
                }
            }
            .padding(.vertical, 8)
        } header: {
            Text(isUser ? "自分の能力変化" : "相手の能力変化")
        }
    }

    private func toggleStatChange(_ statChange: StatChangeFilter) {
        if selectedStatChanges.contains(statChange) {
            selectedStatChanges.remove(statChange)
        } else {
            selectedStatChanges.insert(statChange)
        }
    }
}
