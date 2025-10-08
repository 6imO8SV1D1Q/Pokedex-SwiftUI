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

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                buildEvolutionTreeView(node: chain.rootNode)
            }
            .padding()
        }
    }

    // MARK: - Private Methods

    /// 進化ツリーを再帰的に構築
    @ViewBuilder
    private func buildEvolutionTreeView(node: EvolutionNode) -> some View {
        HStack(spacing: 0) {
            // 現在のノード
            EvolutionNodeCard(node: node) {
                onPokemonTap(node.speciesId)
            }

            // 進化先がある場合
            if !node.evolvesTo.isEmpty {
                // 今回は通常進化（一直線）のみ実装
                // 最初の進化先のみ表示
                if let firstEvolution = node.evolvesTo.first {
                    // 矢印（進化条件なし、簡易版）
                    Image(systemName: "arrow.right")
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)

                    // 再帰的に進化先を表示
                    // TODO: 進化先のノードを取得する必要があるが、
                    // 現在の構造ではtarget IDしかないため、一旦スキップ
                    // プロンプト4-3で完全実装
                    Text("進化先ID: \(firstEvolution.target)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

#Preview {
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
