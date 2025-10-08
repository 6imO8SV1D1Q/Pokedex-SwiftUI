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
    let onPokemonTap: ((Int) -> Void)?

    init(chain: EvolutionChainEntity, onPokemonTap: ((Int) -> Void)? = nil) {
        self.chain = chain
        self.onPokemonTap = onPokemonTap
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

    /// 進化ツリーを再帰的に構築
    private func buildEvolutionTreeView(node: EvolutionNode) -> AnyView {
        AnyView(
            HStack(spacing: 0) {
                // 現在のノード
                if let onTap = onPokemonTap {
                    // コールバックが提供されている場合はそれを使用
                    EvolutionNodeCard(node: node, onTap: {
                        onTap(node.speciesId)
                    })
                } else {
                    // NavigationLinkを使用
                    NavigationLink(value: node.speciesId) {
                        EvolutionNodeCard(node: node)
                    }
                    .buttonStyle(PlainButtonStyle())
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
                                    if let targetNode = chain.nodeMap[edge.target] {
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
                            if let targetNode = chain.nodeMap[edge.target] {
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
    let ivysaur = EvolutionNode(
        id: 2,
        speciesId: 2,
        name: "フシギソウ",
        imageUrl: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/home/2.png",
        types: ["grass", "poison"],
        evolvesTo: [],
        evolvesFrom: nil
    )
    let bulbasaur = EvolutionNode(
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
    let nodeMap: [Int: EvolutionNode] = [
        1: bulbasaur,
        2: ivysaur
    ]
    return EvolutionChainView(
        chain: EvolutionChainEntity(
            id: 1,
            rootNode: bulbasaur,
            nodeMap: nodeMap
        )
    )
}

#Preview("分岐進化（イーブイ風）") {
    let vaporeon = EvolutionNode(
        id: 134,
        speciesId: 134,
        name: "シャワーズ",
        imageUrl: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/home/134.png",
        types: ["water"],
        evolvesTo: [],
        evolvesFrom: nil
    )
    let jolteon = EvolutionNode(
        id: 135,
        speciesId: 135,
        name: "サンダース",
        imageUrl: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/home/135.png",
        types: ["electric"],
        evolvesTo: [],
        evolvesFrom: nil
    )
    let flareon = EvolutionNode(
        id: 136,
        speciesId: 136,
        name: "ブースター",
        imageUrl: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/home/136.png",
        types: ["fire"],
        evolvesTo: [],
        evolvesFrom: nil
    )
    let eevee = EvolutionNode(
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
    let nodeMap: [Int: EvolutionNode] = [
        133: eevee,
        134: vaporeon,
        135: jolteon,
        136: flareon
    ]
    return EvolutionChainView(
        chain: EvolutionChainEntity(
            id: 67,
            rootNode: eevee,
            nodeMap: nodeMap
        )
    )
}
