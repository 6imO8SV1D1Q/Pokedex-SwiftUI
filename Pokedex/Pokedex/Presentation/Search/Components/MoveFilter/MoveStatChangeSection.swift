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
                        text: statChange.displayName,
                        isSelected: selectedStatChanges.contains(statChange),
                        action: { toggleStatChange(statChange) }
                    )
                }
            }
            .padding(.vertical, 8)
        } header: {
            Text(isUser ? L10n.Filter.statChangeUser : L10n.Filter.statChangeOpponent)
        }
    }

    private func toggleStatChange(_ statChange: StatChangeFilter) {
        print("🔧 toggleStatChange called: \(statChange.rawValue)")
        print("🔧 Before: \(selectedStatChanges.map { $0.rawValue })")
        if selectedStatChanges.contains(statChange) {
            selectedStatChanges.remove(statChange)
            print("🔧 Removed")
        } else {
            selectedStatChanges.insert(statChange)
            print("🔧 Inserted")
        }
        print("🔧 After: \(selectedStatChanges.map { $0.rawValue })")
    }
}
