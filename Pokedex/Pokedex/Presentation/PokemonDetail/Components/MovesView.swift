//
//  MovesView.swift
//  Pokedex
//
//  Created on 2025-10-08.
//

import SwiftUI

/// 技リスト表示ビュー
struct MovesView: View {
    let moves: [PokemonMove]
    @Binding var selectedLearnMethod: String

    /// 利用可能な習得方法一覧
    private var availableLearnMethods: [String] {
        let methods = Set(moves.map { $0.learnMethod })
        return Array(methods).sorted()
    }

    /// フィルタリングされた技リスト
    private var filteredMoves: [PokemonMove] {
        moves
            .filter { $0.learnMethod == selectedLearnMethod }
            .sorted { move1, move2 in
                // レベルアップ技の場合はレベル順、それ以外は名前順
                if let level1 = move1.level, let level2 = move2.level {
                    return level1 < level2
                }
                return move1.name < move2.name
            }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("わざ")
                .font(.headline)

            // 習得方法フィルター
            if !availableLearnMethods.isEmpty {
                LearnMethodPicker(
                    methods: availableLearnMethods,
                    selectedMethod: $selectedLearnMethod
                )
            }

            // 技リスト
            if filteredMoves.isEmpty {
                Text("この方法で習得できる技はありません")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(filteredMoves, id: \.name) { move in
                            MoveRow(move: move)
                        }
                    }
                }
                .frame(maxHeight: 400)
            }
        }
        .padding()
    }
}

/// 習得方法選択ピッカー
struct LearnMethodPicker: View {
    let methods: [String]
    @Binding var selectedMethod: String

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(methods, id: \.self) { method in
                    Button {
                        selectedMethod = method
                    } label: {
                        Text(learnMethodDisplayName(method))
                            .font(.caption)
                            .fontWeight(.medium)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                selectedMethod == method
                                    ? Color.blue
                                    : Color(.systemGray5)
                            )
                            .foregroundColor(
                                selectedMethod == method
                                    ? .white
                                    : .primary
                            )
                            .cornerRadius(16)
                    }
                }
            }
        }
    }

    /// 習得方法を日本語表示に変換
    private func learnMethodDisplayName(_ method: String) -> String {
        switch method {
        case "level-up":
            return "レベルアップ"
        case "machine":
            return "わざマシン"
        case "egg":
            return "タマゴわざ"
        case "tutor":
            return "教え技"
        default:
            return method
                .replacingOccurrences(of: "-", with: " ")
                .capitalized
        }
    }
}

/// 個別技の行
struct MoveRow: View {
    let move: PokemonMove

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            // レベル表示（レベルアップ技の場合）
            if let level = move.level {
                Text("Lv.\(level)")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(width: 50)
                    .padding(.vertical, 4)
                    .background(Color.blue)
                    .cornerRadius(4)
            } else {
                // レベルなしの場合はスペーサー
                Color.clear
                    .frame(width: 50)
            }

            // 技名
            Text(move.displayName)
                .font(.subheadline)
                .fontWeight(.medium)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

#Preview {
    MovesView(
        moves: [
            PokemonMove(
                name: "tackle",
                learnMethod: "level-up",
                level: 1
            ),
            PokemonMove(
                name: "vine-whip",
                learnMethod: "level-up",
                level: 9
            ),
            PokemonMove(
                name: "solar-beam",
                learnMethod: "machine",
                level: nil
            ),
            PokemonMove(
                name: "leaf-storm",
                learnMethod: "tutor",
                level: nil
            )
        ],
        selectedLearnMethod: .constant("level-up")
    )
}
