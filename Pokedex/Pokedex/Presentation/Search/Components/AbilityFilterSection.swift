//
//  AbilityFilterSection.swift
//  Pokedex
//
//  特性フィルターセクション
//

import SwiftUI

struct AbilityFilterSection: View {
    @Binding var selectedAbilities: Set<String>
    @Binding var abilityMetadataFilters: [AbilityMetadataFilter]
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

                // 特性の条件を追加
                NavigationLink(destination: AbilityMetadataFilterView(onSave: { filter in
                    abilityMetadataFilters.append(filter)
                })) {
                    HStack {
                        Text("特性の条件を追加")
                        Spacer()
                        Image(systemName: "plus.circle")
                    }
                }

                // 設定中の条件を表示
                if !abilityMetadataFilters.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("設定中の条件")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        ForEach(abilityMetadataFilters) { filter in
                            if let index = abilityMetadataFilters.firstIndex(where: { $0.id == filter.id }) {
                                NavigationLink {
                                    AbilityMetadataFilterView(
                                        initialFilter: filter,
                                        onSave: { updatedFilter in
                                            abilityMetadataFilters[index] = updatedFilter
                                        }
                                    )
                                } label: {
                                    AbilityMetadataConditionRow(
                                        filter: filter,
                                        index: index,
                                        onRemove: { removeAbilityMetadataFilter(id: filter.id) }
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
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

    private func removeAbilityMetadataFilter(id: UUID) {
        abilityMetadataFilters.removeAll { $0.id == id }
    }
}
