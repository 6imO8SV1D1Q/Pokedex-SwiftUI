//
//  AbilityFilterSection.swift
//  Pokedex
//
//  特性フィルターセクション
//

import SwiftUI

struct AbilityFilterSection: View {
    @Binding var selectedAbilities: Set<String>
    @Binding var filterMode: FilterMode
    @State private var searchText = ""

    let allAbilities: [AbilityEntity]
    let isLoading: Bool

    var body: some View {
        Section {
            if isLoading {
                ProgressView()
            } else {
                // OR/AND切り替え
                Picker("検索モード", selection: $filterMode) {
                    Text("OR（いずれか）").tag(FilterMode.or)
                    Text("AND（全て）").tag(FilterMode.and)
                }
                .pickerStyle(.segmented)

                // 検索バー
                TextField("特性を検索", text: $searchText)
                    .textFieldStyle(.roundedBorder)

                // 選択済み特性の表示
                if !selectedAbilities.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(Array(selectedAbilities), id: \.self) { abilityName in
                                FilterChipView(
                                    text: displayName(for: abilityName),
                                    onRemove: { toggleAbility(abilityName) }
                                )
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }

                // 特性リスト
                ForEach(filteredAbilities.prefix(50)) { ability in
                    Button {
                        toggleAbility(ability.name)
                    } label: {
                        HStack {
                            Text(ability.nameJa)
                            Spacer()
                            Text(ability.name)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .foregroundColor(.primary)
                }
            }
        } header: {
            Text("特性")
        } footer: {
            Text(filterMode == .or
                 ? "選択した特性のいずれかを持つポケモンを表示"
                 : "選択した特性を全て持つポケモンを表示")
        }
    }

    private var filteredAbilities: [AbilityEntity] {
        if searchText.isEmpty {
            return []
        }
        return allAbilities.filter { ability in
            ability.nameJa.range(of: searchText, options: [.caseInsensitive, .widthInsensitive]) != nil ||
            ability.name.range(of: searchText, options: [.caseInsensitive, .widthInsensitive]) != nil
        }
    }

    private func toggleAbility(_ abilityName: String) {
        if selectedAbilities.contains(abilityName) {
            selectedAbilities.remove(abilityName)
        } else {
            selectedAbilities.insert(abilityName)
            searchText = ""
        }
    }

    private func displayName(for abilityName: String) -> String {
        allAbilities.first { $0.name == abilityName }?.nameJa ?? abilityName
    }
}
