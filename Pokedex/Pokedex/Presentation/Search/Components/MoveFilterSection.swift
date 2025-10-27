//
//  MoveFilterSection.swift
//  Pokedex
//
//  技フィルターセクション
//

import SwiftUI

struct MoveFilterSection: View {
    @Binding var selectedMoves: [MoveEntity]
    @Binding var selectedMoveCategories: Set<String>
    @Binding var moveMetadataFilters: [MoveMetadataFilter]
    @Binding var filterMode: FilterMode
    @State private var searchText = ""

    let allMoves: [MoveEntity]
    let isLoading: Bool

    var body: some View {
        Section {
            if isLoading {
                ProgressView()
            } else {
                // OR/AND切り替え
                Picker(L10n.Filter.searchMode, selection: $filterMode) {
                    Text(L10n.Filter.or).tag(FilterMode.or)
                    Text(L10n.Filter.and).tag(FilterMode.and)
                }
                .pickerStyle(.segmented)

                // 検索バー
                TextField(L10n.Filter.moveSearchPlaceholder, text: $searchText)
                    .textFieldStyle(.roundedBorder)

                // 選択済み技の表示
                if !selectedMoves.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(L10n.Filter.selectedCount(selectedMoves.count))
                            .font(.caption)
                            .foregroundColor(.secondary)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(selectedMoves) { move in
                                    FilterChipView(
                                        text: move.nameJa,
                                        onRemove: { toggleMove(move) }
                                    )
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }

                // 技リスト
                ForEach(searchFilteredMoves.prefix(50)) { move in
                    Button {
                        toggleMove(move)
                    } label: {
                        HStack {
                            Text(move.nameJa)
                            Spacer()
                            Text(move.name)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .foregroundColor(.primary)
                }

                // 技の条件を追加
                NavigationLink(destination: MoveMetadataFilterView(onSave: { filter in
                    moveMetadataFilters.append(filter)
                })) {
                    HStack {
                        Text(L10n.Filter.moveAddCondition)
                        Spacer()
                        Image(systemName: "plus.circle")
                    }
                }

                // 設定中の条件を表示
                if !moveMetadataFilters.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(L10n.Filter.moveConditionsHeader)
                            .font(.caption)
                            .foregroundColor(.secondary)

                        ForEach(moveMetadataFilters) { filter in
                            if let index = moveMetadataFilters.firstIndex(where: { $0.id == filter.id }) {
                                NavigationLink {
                                    MoveMetadataFilterView(
                                        initialFilter: filter,
                                        onSave: { updatedFilter in
                                            moveMetadataFilters[index] = updatedFilter
                                        }
                                    )
                                } label: {
                                    MoveMetadataConditionRow(
                                        filter: filter,
                                        index: index,
                                        onRemove: { removeMoveMetadataFilter(id: filter.id) }
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
            }
        } header: {
            Text(L10n.Filter.move)
        } footer: {
            VStack(alignment: .leading, spacing: 4) {
                if !moveMetadataFilters.isEmpty {
                    Text(L10n.Filter.moveNote)
                        .font(.caption)
                }
                Text(filterMode == .or ? L10n.Filter.moveOrDescription : L10n.Filter.moveAndDescription)
                    .font(.caption)
            }
        }
    }

    private var searchFilteredMoves: [MoveEntity] {
        if searchText.isEmpty && selectedMoveCategories.isEmpty {
            return []
        }

        var moves = filteredMovesByCategory

        if !searchText.isEmpty {
            moves = moves.filter { move in
                move.nameJa.range(of: searchText, options: [.caseInsensitive, .widthInsensitive]) != nil ||
                move.name.range(of: searchText, options: [.caseInsensitive, .widthInsensitive]) != nil
            }
        }

        return moves
    }

    private var filteredMovesByCategory: [MoveEntity] {
        guard !selectedMoveCategories.isEmpty else {
            return allMoves
        }
        return allMoves.filter { move in
            MoveCategory.moveMatchesAnyCategory(move.name, categories: selectedMoveCategories)
        }
    }

    private func toggleMove(_ move: MoveEntity) {
        if let index = selectedMoves.firstIndex(where: { $0.id == move.id }) {
            selectedMoves.remove(at: index)
        } else {
            selectedMoves.append(move)
            searchText = ""
        }
    }

    private func removeMoveMetadataFilter(id: UUID) {
        moveMetadataFilters.removeAll { $0.id == id }
    }
}
