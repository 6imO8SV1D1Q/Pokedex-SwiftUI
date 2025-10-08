//
//  EvolutionChainView.swift
//  Pokedex
//
//  Created on 2025-10-08.
//

import SwiftUI

/// 進化チェーン表示ビュー
struct EvolutionChainView: View {
    let chain: EvolutionChainEntity
    let onPokemonTap: (Int) -> Void

    /// ノードIDからノードへのマッピング（再帰的探索用）
    private var nodeMap: [Int: EvolutionNode] {
        buildNodeMap(from: chain.rootNode)
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            ScrollView(.vertical, showsIndicators: false) {
                HStack(alignment: .center, spacing: 0) {
                    buildEvolutionTreeView(node: chain.rootNode)
                }
                .padding()
            }
        }
    }

    // MARK: - Private Methods

    /// ノードマップを構築（再帰的）
    private func buildNodeMap(from node: EvolutionNode) -> [Int: EvolutionNode] {
        var map: [Int: EvolutionNode] = [node.speciesId: node]

        // 子ノードがある場合、再帰的にマップに追加
        // 注: 現在の実装ではEvolutionEdgeにtarget IDしかないため、
        // 完全なマップ構築には Repository で完全な再帰構造を構築する必要がある
        for edge in node.evolvesTo {
            if let childNode = nodeMap[edge.target] {
                let childMap = buildNodeMap(from: childNode)
                map.merge(childMap) { current, _ in current }
            }
        }

        return map
    }

    /// 進化ツリーを再帰的に構築
    private func buildEvolutionTreeView(node: EvolutionNode) -> AnyView {
        AnyView(
            HStack(spacing: 0) {
                // 現在のノード
                EvolutionNodeCard(node: node) {
                    onPokemonTap(node.speciesId)
                }

                // 進化先がある場合
                if !node.evolvesTo.isEmpty {
                    // 分岐進化の場合（複数の進化先）
                    if node.evolvesTo.count > 1 {
                        // 縦に並べる
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(Array(node.evolvesTo.enumerated()), id: \.offset) { index, edge in
                                HStack(spacing: 0) {
                                    // 進化条件付き矢印
                                    EvolutionArrow(edge: edge)

                                    // 進化先ノード
                                    if let targetNode = nodeMap[edge.target] {
                                        // 再帰的に進化先を表示
                                        buildEvolutionTreeView(node: targetNode)
                                    } else {
                                        // ノードデータがない場合はプレースホルダー
                                        evolutionPlaceholder(speciesId: edge.target)
                                    }
                                }
                            }
                        }
                    } else {
                        // 単一進化（一直線）
                        if let edge = node.evolvesTo.first {
                            // 進化条件付き矢印
                            EvolutionArrow(edge: edge)

                            // 進化先ノード
                            if let targetNode = nodeMap[edge.target] {
                                // 再帰的に進化先を表示
                                buildEvolutionTreeView(node: targetNode)
                            } else {
                                // ノードデータがない場合はプレースホルダー
                                evolutionPlaceholder(speciesId: edge.target)
                            }
                        }
                    }
                }
            }
        )
    }

    /// 進化先ノードのプレースホルダー
    @ViewBuilder
    private func evolutionPlaceholder(speciesId: Int) -> some View {
        VStack {
            Text("ID: \(speciesId)")
                .font(.caption)
                .foregroundColor(.secondary)
            Text("データ読込中...")
                .font(.caption2)
                .foregroundColor(.secondary)
                .opacity(0.6)
        }
        .frame(width: 80, height: 80)
        .padding(8)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

#Preview("単一進化") {
    EvolutionChainView(
        chain: EvolutionChainEntity(
            id: 1,
            rootNode: EvolutionNode(
                id: 1,
                speciesId: 1,
                name: "フシギダネ",
                imageUrl: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/home/1.png",
                types: ["grass", "poison"],
                evolvesTo: [
                    EvolutionNode.EvolutionEdge(
                        target: 2,
                        trigger: .levelUp,
                        conditions: [
                            EvolutionNode.EvolutionCondition(type: .minLevel, value: "16")
                        ]
                    )
                ],
                evolvesFrom: nil
            )
        ),
        onPokemonTap: { _ in }
    )
}

#Preview("分岐進化（イーブイ風）") {
    EvolutionChainView(
        chain: EvolutionChainEntity(
            id: 67,
            rootNode: EvolutionNode(
                id: 133,
                speciesId: 133,
                name: "イーブイ",
                imageUrl: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/home/133.png",
                types: ["normal"],
                evolvesTo: [
                    EvolutionNode.EvolutionEdge(
                        target: 134,
                        trigger: .useItem,
                        conditions: [
                            EvolutionNode.EvolutionCondition(type: .item, value: "water-stone")
                        ]
                    ),
                    EvolutionNode.EvolutionEdge(
                        target: 135,
                        trigger: .useItem,
                        conditions: [
                            EvolutionNode.EvolutionCondition(type: .item, value: "thunder-stone")
                        ]
                    ),
                    EvolutionNode.EvolutionEdge(
                        target: 136,
                        trigger: .useItem,
                        conditions: [
                            EvolutionNode.EvolutionCondition(type: .item, value: "fire-stone")
                        ]
                    )
                ],
                evolvesFrom: nil
            )
        ),
        onPokemonTap: { _ in }
    )
}
