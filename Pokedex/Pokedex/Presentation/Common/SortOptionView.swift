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
                Picker("並び順", selection: $isAscending) {
                    Text("昇順 ↑").tag(true)
                    Text("降順 ↓").tag(false)
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
                    Section("基本") {
                        sortButton(.pokedexNumber(ascending: isAscending), label: "図鑑番号")
                    }

                    Section("種族値") {
                        sortButton(.hp(ascending: isAscending), label: "HP")
                        sortButton(.attack(ascending: isAscending), label: "攻撃")
                        sortButton(.defense(ascending: isAscending), label: "防御")
                        sortButton(.specialAttack(ascending: isAscending), label: "特攻")
                        sortButton(.specialDefense(ascending: isAscending), label: "特防")
                        sortButton(.speed(ascending: isAscending), label: "素早さ")
                        sortButton(.totalStats(ascending: isAscending), label: "種族値合計")
                    }
                }
                .listStyle(.insetGrouped)
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

    private func sortButton(_ option: SortOption, label: String) -> some View {
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
