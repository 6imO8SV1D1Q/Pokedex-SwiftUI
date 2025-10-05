//
//  SortOptionView.swift
//  Pokedex
//
//  Created on 2025-10-05.
//

import SwiftUI

struct SortOptionView: View {
    @Binding var currentSortOption: SortOption
    let onSortChange: (SortOption) -> Void
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            List {
                Section("全国図鑑No") {
                    sortButton(.pokedexNumber)
                    sortButton(.name(ascending: true))
                    sortButton(.name(ascending: false))
                }

                Section("種族値") {
                    sortButton(.totalStats(ascending: false))
                    sortButton(.totalStats(ascending: true))
                    sortButton(.hp(ascending: false))
                    sortButton(.attack(ascending: false))
                    sortButton(.defense(ascending: false))
                    sortButton(.specialAttack(ascending: false))
                    sortButton(.specialDefense(ascending: false))
                    sortButton(.speed(ascending: false))
                }
            }
            .navigationTitle("並び替え")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完了") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func sortButton(_ option: SortOption) -> some View {
        Button(action: {
            currentSortOption = option
            onSortChange(option)
            dismiss()
        }) {
            HStack {
                Text(option.displayName)
                    .foregroundColor(.primary)
                Spacer()
                if currentSortOption == option {
                    Image(systemName: "checkmark")
                        .foregroundColor(.accentColor)
                }
            }
        }
    }
}
