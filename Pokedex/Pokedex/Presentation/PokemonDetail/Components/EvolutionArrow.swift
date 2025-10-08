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

    var body: some View {
        VStack(spacing: 4) {
            // 矢印
            Image(systemName: "arrow.right")
                .font(.title3)
                .foregroundColor(.secondary)

            // 進化条件テキスト
            if !conditionText.isEmpty {
                Text(conditionText)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .frame(width: 60)
            }
        }
        .padding(.horizontal, 4)
    }

    /// 進化条件を表示用テキストに変換
    private var conditionText: String {
        var components: [String] = []

        // トリガーテキスト
        switch edge.trigger {
        case .levelUp:
            break // レベルアップは表示しない（条件にLv.が含まれるため）
        case .trade:
            components.append("通信交換")
        case .useItem:
            components.append("アイテム")
        case .shed:
            components.append("脱皮")
        case .other:
            components.append("特殊")
        }

        // 条件テキスト
        for condition in edge.conditions {
            let text = condition.displayText
            // アイテム名の場合は「～のいし」などの表記を短縮
            if condition.type == .item, let value = condition.value {
                if value.contains("stone") {
                    // 「～stone」を「～のいし」に変換
                    let stoneName = value
                        .replacingOccurrences(of: "-", with: " ")
                        .capitalized
                    components.append(stoneName)
                } else {
                    components.append(text)
                }
            } else {
                components.append(text)
            }
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
}
