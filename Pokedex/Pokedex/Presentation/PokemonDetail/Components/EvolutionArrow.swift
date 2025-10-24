//
//  EvolutionArrow.swift
//  Pokedex
//
//  Created on 2025-10-08.
//

import SwiftUI

/// 進化の矢印と条件を表示するコンポーネント
struct EvolutionArrow: View {
    let edge: EvolutionNode.EvolutionEdge
    @EnvironmentObject private var localizationManager: LocalizationManager

    var body: some View {
        VStack(spacing: 6) {
            // 矢印
            Image(systemName: "arrow.right")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.blue)

            // 進化条件テキスト
            if !conditionText.isEmpty {
                Text(conditionText)
                    .font(.caption)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(4)
                    .frame(width: 80)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 4)
                    .background(Color(.systemBackground))
                    .cornerRadius(6)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color(.systemGray4), lineWidth: 1)
                    )
            }
        }
        .padding(.horizontal, 8)
    }

    /// 進化条件を表示用テキストに変換
    private var conditionText: String {
        var components: [String] = []

        // トリガーテキスト
        if let triggerText = localizationManager.displayText(for: edge.trigger) {
            components.append(triggerText)
        }

        // 条件テキスト
        for condition in edge.conditions {
            components.append(localizationManager.displayText(for: condition))
        }

        return components.joined(separator: "\n")
    }
}

#Preview {
    VStack(spacing: 20) {
        // レベルアップ進化
        EvolutionArrow(
            edge: EvolutionNode.EvolutionEdge(
                target: 2,
                trigger: .levelUp,
                conditions: [
                    EvolutionNode.EvolutionCondition(type: .minLevel, value: "16")
                ]
            )
        )

        // アイテム進化
        EvolutionArrow(
            edge: EvolutionNode.EvolutionEdge(
                target: 3,
                trigger: .useItem,
                conditions: [
                    EvolutionNode.EvolutionCondition(type: .item, value: "fire-stone")
                ]
            )
        )

        // 通信交換進化
        EvolutionArrow(
            edge: EvolutionNode.EvolutionEdge(
                target: 4,
                trigger: .trade,
                conditions: []
            )
        )

        // 複雑な条件
        EvolutionArrow(
            edge: EvolutionNode.EvolutionEdge(
                target: 5,
                trigger: .levelUp,
                conditions: [
                    EvolutionNode.EvolutionCondition(type: .minLevel, value: "20"),
                    EvolutionNode.EvolutionCondition(type: .timeOfDay, value: "night")
                ]
            )
        )
    }
    .padding()
    .environmentObject(LocalizationManager.shared)
}
