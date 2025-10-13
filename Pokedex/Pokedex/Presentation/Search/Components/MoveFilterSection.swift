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
                Picker("検索モード", selection: $filterMode) {
                    Text("OR（いずれか）").tag(FilterMode.or)
                    Text("AND（全て）").tag(FilterMode.and)
                }
                .pickerStyle(.segmented)

                // 検索バー
                TextField("技を検索", text: $searchText)
                    .textFieldStyle(.roundedBorder)

                // 選択済み技の表示
                if !selectedMoves.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("選択中: \(selectedMoves.count)件")
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
                NavigationLink(destination: MoveMetadataFilterView(onAdd: { filter in
                    moveMetadataFilters.append(filter)
                })) {
                    HStack {
                        Text("技の条件を追加")
                        Spacer()
                        Image(systemName: "plus.circle")
                    }
                }

                // 設定中の条件を表示
                if !moveMetadataFilters.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("設定中の条件")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        ForEach(moveMetadataFilters) { filter in
                            if let index = moveMetadataFilters.firstIndex(where: { $0.id == filter.id }) {
                                MoveMetadataConditionRow(
                                    filter: filter,
                                    index: index,
                                    onRemove: { removeMoveMetadataFilter(id: filter.id) }
                                )
                            }
                        }
                    }
                }
            }
        } header: {
            Text("技")
        } footer: {
            VStack(alignment: .leading, spacing: 4) {
                if !moveMetadataFilters.isEmpty {
                    Text("技の条件: メタデータで絞り込んだ技も含まれます")
                        .font(.caption)
                }
                Text(filterMode == .or
                     ? "選択した技のいずれかを覚えられるポケモンを表示"
                     : "選択した技を全て覚えられるポケモンを表示")
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
