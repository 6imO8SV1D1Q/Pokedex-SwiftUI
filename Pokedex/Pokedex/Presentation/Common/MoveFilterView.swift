//
//  MoveFilterView.swift
//  Pokedex
//
//  Created on 2025-10-05.
//

import SwiftUI

struct MoveFilterView: View {
    @Binding var selectedMoves: [MoveEntity]
    let availableMoves: [MoveEntity]
    let isEnabled: Bool
    @State private var searchText = ""

    var filteredMoves: [MoveEntity] {
        if searchText.isEmpty {
            return availableMoves
        }
        return availableMoves.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(L10n.MoveFilter.title)
                .font(.headline)

            if !isEnabled {
                infoMessage
            } else {
                enabledContent
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1.0 : 0.6)
    }

    private var infoMessage: some View {
        Text(L10n.Loading.moveFilterDisabled)
            .font(.caption)
            .foregroundColor(.secondary)
            .padding()
            .background(Color.secondary.opacity(0.1))
            .cornerRadius(8)
    }

    private var enabledContent: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 検索フィールド
            TextField(text: $searchText) {
                Text(L10n.MoveFilter.searchPlaceholder)
            }
            .textFieldStyle(RoundedBorderTextFieldStyle())

            // 選択済みタグ
            if !selectedMoves.isEmpty {
                selectedMoveTags
            }

            // カウンター
            Text(L10n.MoveFilter.maxSelectionWithCount(selectedMoves.count))
                .font(.caption)
                .foregroundColor(.secondary)

            // 技リスト
            moveList
        }
    }

    private var selectedMoveTags: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(selectedMoves) { move in
                    HStack(spacing: 4) {
                        Text(move.name)
                            .font(.caption)
                        Button(action: {
                            removeMove(move)
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.caption)
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(8)
                }
            }
        }
    }

    private var moveList: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 4) {
                ForEach(filteredMoves) { move in
                    moveRow(move)
                }
            }
        }
        .frame(maxHeight: 200)
    }

    private func moveRow(_ move: MoveEntity) -> some View {
        Button(action: {
            toggleMove(move)
        }) {
            HStack {
                Text(move.name)
                Spacer()
                if selectedMoves.contains(where: { $0.id == move.id }) {
                    Image(systemName: "checkmark")
                        .foregroundColor(.blue)
                }
            }
            .padding(.vertical, 4)
        }
        .disabled(
            selectedMoves.count >= 4 &&
            !selectedMoves.contains(where: { $0.id == move.id })
        )
    }

    private func toggleMove(_ move: MoveEntity) {
        if let index = selectedMoves.firstIndex(where: { $0.id == move.id }) {
            selectedMoves.remove(at: index)
        } else if selectedMoves.count < 4 {
            selectedMoves.append(move)
        }
    }

    private func removeMove(_ move: MoveEntity) {
        selectedMoves.removeAll { $0.id == move.id }
    }
}
