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
    let moveDetails: [String: MoveEntity]  // 技詳細情報
    @Binding var selectedLearnMethod: String

    /// 利用可能な習得方法一覧（「すべて」を含む）
    private var availableLearnMethods: [String] {
        let methods = Set(moves.map { $0.learnMethod })
        var result = ["all"] // 「すべて」を最初に追加
        result.append(contentsOf: Array(methods).sorted())
        return result
    }

    /// 習得方法の表示順序
    private let methodOrder = ["level-up", "machine", "egg", "tutor"]

    /// 「すべて」が選択されている場合の、習得方法ごとにグループ化された技
    private var groupedMoves: [(method: String, moves: [PokemonMove])] {
        let grouped = Dictionary(grouping: moves) { $0.learnMethod }

        return methodOrder.compactMap { method in
            guard let movesForMethod = grouped[method], !movesForMethod.isEmpty else {
                return nil
            }

            let sortedMoves = movesForMethod.sorted { move1, move2 in
                // レベルアップ技の場合はレベル順、それ以外は名前順
                if let level1 = move1.level, let level2 = move2.level {
                    return level1 < level2
                }
                return move1.name < move2.name
            }

            return (method, sortedMoves)
        }
    }

    /// フィルタリングされた技リスト（特定の習得方法が選択されている場合）
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
            // 習得方法フィルター
            if !availableLearnMethods.isEmpty {
                LearnMethodPicker(
                    methods: availableLearnMethods,
                    selectedMethod: $selectedLearnMethod
                )
            }

            // 技リスト
            if selectedLearnMethod == "all" {
                // 「すべて」が選択されている場合は習得方法ごとにグループ化
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(groupedMoves, id: \.method) { group in
                        VStack(alignment: .leading, spacing: 8) {
                            // セクションヘッダー
                            HStack {
                                Text(learnMethodDisplayName(group.method))
                                    .font(.subheadline)
                                    .fontWeight(.semibold)

                                Text("(\(group.moves.count))")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            // 技リスト
                            VStack(spacing: 8) {
                                ForEach(group.moves, id: \.name) { move in
                                    MoveRow(
                                        move: move,
                                        moveDetail: moveDetails[move.name]
                                    )
                                }
                            }
                        }
                    }
                }
            } else {
                // 特定の習得方法が選択されている場合
                if filteredMoves.isEmpty {
                    Text("この方法で習得できる技はありません")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding()
                } else {
                    VStack(spacing: 8) {
                        ForEach(filteredMoves, id: \.name) { move in
                            MoveRow(
                                move: move,
                                moveDetail: moveDetails[move.name]
                            )
                        }
                    }
                }
            }
        }
        .padding()
    }

    /// 習得方法を日本語表示に変換
    private func learnMethodDisplayName(_ method: String) -> String {
        switch method {
        case "all":
            return "すべて"
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
        case "all":
            return "すべて"
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
    let moveDetail: MoveEntity?  // 技詳細情報（オプショナル）
    @EnvironmentObject private var localizationManager: LocalizationManager
    @State private var isExpanded = false

    init(move: PokemonMove, moveDetail: MoveEntity? = nil) {
        self.move = move
        self.moveDetail = moveDetail
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .center, spacing: 12) {
                // レベルまたはマシン番号表示
                switch move.learnMethod {
                case "level-up":
                    if let level = move.level, level > 0 {
                        // レベルアップ技の場合
                        Text("Lv.\(level)")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(width: 50)
                            .padding(.vertical, 4)
                            .background(Color.blue)
                            .cornerRadius(4)
                    } else {
                        Color.clear.frame(width: 50)
                    }

                case "machine":
                    if let machineNumber = moveDetail?.machineNumber {
                        // マシンで習得する場合
                        Text(machineNumber)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(width: 50)
                            .padding(.vertical, 4)
                            .background(Color.purple)
                            .cornerRadius(4)
                    } else {
                        Color.clear.frame(width: 50)
                    }

                default:
                    // タマゴわざ、教え技などはスペーサーのみ
                    Color.clear.frame(width: 50)
                }

                // 技名（moveDetailがあれば日本語名、なければ英語名）
                Text(moveDetail?.nameJa ?? move.displayName)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Spacer()

                // 技詳細情報（取得済みの場合）
                if let detail = moveDetail {
                    // タイプバッジ
                    Text(localizationManager.displayName(for: detail.type))
                        .typeBadgeStyle(detail.type)
                        .font(.caption)

                    // 開閉ボタン（説明がある場合のみ）
                    if detail.effect != nil {
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                isExpanded.toggle()
                            }
                        } label: {
                            Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }

            // 詳細情報行
            if let detail = moveDetail {
                HStack(spacing: 16) {
                    // 分類
                    Text(detail.categoryDisplayName)
                        .font(.caption)
                        .foregroundColor(.secondary)

                    // 威力
                    HStack(spacing: 2) {
                        Text("威力:")
                        Text(detail.displayPower)
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)

                    // 命中率
                    HStack(spacing: 2) {
                        Text("命中:")
                        Text(detail.displayAccuracy)
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)

                    // PP
                    HStack(spacing: 2) {
                        Text("PP:")
                        Text(detail.displayPP)
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }

                // 技カテゴリー
                if !detail.categories.isEmpty {
                    HStack(spacing: 4) {
                        ForEach(detail.categories, id: \.self) { categoryId in
                            Text(MoveCategory.displayName(for: categoryId))
                                .font(.caption2)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.blue.opacity(0.15))
                                .foregroundColor(.blue)
                                .cornerRadius(4)
                        }
                    }
                }

                // 説明文（展開時のみ表示）
                if isExpanded, let effect = detail.effect {
                    Text(effect)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
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
                id: 1,
                name: "tackle",
                learnMethod: "level-up",
                level: 1,
                machineNumber: nil
            ),
            PokemonMove(
                id: 2,
                name: "vine-whip",
                learnMethod: "level-up",
                level: 9,
                machineNumber: nil
            ),
            PokemonMove(
                id: 3,
                name: "solar-beam",
                learnMethod: "machine",
                level: nil,
                machineNumber: "TM22"
            ),
            PokemonMove(
                id: 4,
                name: "leaf-storm",
                learnMethod: "tutor",
                level: nil,
                machineNumber: nil
            )
        ],
        moveDetails: [:],  // 空の辞書
        selectedLearnMethod: .constant("level-up")
    )
    .environmentObject(LocalizationManager.shared)
}
