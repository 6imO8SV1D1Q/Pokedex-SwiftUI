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

    @State private var isAscending: Bool

    init(currentSortOption: Binding<SortOption>, onSortChange: @escaping (SortOption) -> Void) {
        self._currentSortOption = currentSortOption
        self.onSortChange = onSortChange

        // 現在のソートオプションから昇順/降順を取得
        switch currentSortOption.wrappedValue {
        case .pokedexNumber(let ascending),
             .totalStats(let ascending),
             .hp(let ascending),
             .attack(let ascending),
             .defense(let ascending),
             .specialAttack(let ascending),
             .specialDefense(let ascending),
             .speed(let ascending):
            self._isAscending = State(initialValue: ascending)
        }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 昇順/降順切り替え
                Picker(selection: $isAscending) {
                    Text(L10n.Sort.ascending).tag(true)
                    Text(L10n.Sort.descending).tag(false)
                } label: {
                    Text(L10n.Sort.order)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 16)
                .background(Color(uiColor: .systemGroupedBackground))
                .onChange(of: isAscending) { _, newValue in
                    // 昇順/降順が変更されたら、現在選択中の項目で再ソート
                    applyCurrentSort(ascending: newValue)
                }

                List {
                    Section {
                        sortButton(.pokedexNumber(ascending: isAscending), label: L10n.Sort.pokedexNumber)
                    } header: {
                        Text(L10n.Sort.sectionBasic)
                    }

                    Section {
                        sortButton(.hp(ascending: isAscending), label: L10n.Stat.hp)
                        sortButton(.attack(ascending: isAscending), label: L10n.Sort.attack)
                        sortButton(.defense(ascending: isAscending), label: L10n.Sort.defense)
                        sortButton(.specialAttack(ascending: isAscending), label: L10n.Sort.specialAttack)
                        sortButton(.specialDefense(ascending: isAscending), label: L10n.Sort.specialDefense)
                        sortButton(.speed(ascending: isAscending), label: L10n.Sort.speed)
                        sortButton(.totalStats(ascending: isAscending), label: L10n.Sort.totalStats)
                    } header: {
                        Text(L10n.Sort.sectionBaseStats)
                    }
                }
                .listStyle(.insetGrouped)
            }
            .navigationTitle(L10n.Sort.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Text(L10n.Sort.done)
                    }
                }
            }
        }
    }

    private func sortButton(_ option: SortOption, label: LocalizedStringKey) -> some View {
        Button(action: {
            currentSortOption = option
            onSortChange(option)
        }) {
            HStack {
                Text(label)
                    .foregroundColor(.primary)
                Spacer()
                if isSameOption(currentSortOption, option) {
                    Image(systemName: "checkmark")
                        .foregroundColor(.accentColor)
                }
            }
        }
    }

    /// 現在の昇順/降順で選択中の項目を再ソート
    private func applyCurrentSort(ascending: Bool) {
        let newOption: SortOption

        switch currentSortOption {
        case .pokedexNumber:
            newOption = .pokedexNumber(ascending: ascending)
        case .totalStats:
            newOption = .totalStats(ascending: ascending)
        case .hp:
            newOption = .hp(ascending: ascending)
        case .attack:
            newOption = .attack(ascending: ascending)
        case .defense:
            newOption = .defense(ascending: ascending)
        case .specialAttack:
            newOption = .specialAttack(ascending: ascending)
        case .specialDefense:
            newOption = .specialDefense(ascending: ascending)
        case .speed:
            newOption = .speed(ascending: ascending)
        }

        currentSortOption = newOption
        onSortChange(newOption)
    }

    /// 2つのSortOptionが同じ項目かどうか（昇順/降順は無視）
    private func isSameOption(_ lhs: SortOption, _ rhs: SortOption) -> Bool {
        switch (lhs, rhs) {
        case (.pokedexNumber, .pokedexNumber):
            return true
        case (.totalStats, .totalStats):
            return true
        case (.hp, .hp):
            return true
        case (.attack, .attack):
            return true
        case (.defense, .defense):
            return true
        case (.specialAttack, .specialAttack):
            return true
        case (.specialDefense, .specialDefense):
            return true
        case (.speed, .speed):
            return true
        default:
            return false
        }
    }
}
