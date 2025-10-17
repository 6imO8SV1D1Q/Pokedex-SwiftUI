//
//  AbilityMetadataConditionRow.swift
//  Pokedex
//
//  特性のメタデータ条件表示行
//

import SwiftUI

struct AbilityMetadataConditionRow: View {
    let filter: AbilityMetadataFilter
    let index: Int
    let onRemove: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("条件\(index + 1)")
                    .font(.caption)
                    .fontWeight(.bold)

                if !filter.triggers.isEmpty {
                    Text("発動: \(filter.triggers.map { triggerDisplayName($0) }.joined(separator: ", "))")
                        .font(.caption)
                }
                if !filter.effectTypes.isEmpty {
                    Text("効果: \(filter.effectTypes.map { effectTypeDisplayName($0) }.joined(separator: ", "))")
                        .font(.caption)
                }
                if let condition = filter.statMultiplierCondition {
                    Text(condition.displayText(label: "能力値倍率"))
                        .font(.caption)
                }
                if let condition = filter.movePowerMultiplierCondition {
                    Text(condition.displayText(label: "技威力倍率"))
                        .font(.caption)
                }
                if let condition = filter.probabilityCondition {
                    Text(condition.displayText(label: "発動確率"))
                        .font(.caption)
                }
                if !filter.weathers.isEmpty {
                    Text("天候: \(filter.weathers.map { weatherDisplayName($0) }.joined(separator: ", "))")
                        .font(.caption)
                }
                if !filter.terrains.isEmpty {
                    Text("フィールド: \(filter.terrains.map { terrainDisplayName($0) }.joined(separator: ", "))")
                        .font(.caption)
                }
                if !filter.affectedTypes.isEmpty {
                    Text("タイプ: \(filter.affectedTypes.map { FilterHelpers.typeJapaneseName($0) }.joined(separator: ", "))")
                        .font(.caption)
                }
                if !filter.affectedStatuses.isEmpty {
                    Text("状態異常: \(filter.affectedStatuses.map { statusDisplayName($0) }.joined(separator: ", "))")
                        .font(.caption)
                }
                if !filter.categories.isEmpty {
                    Text("カテゴリ: \(filter.categories.map { $0.displayName }.joined(separator: ", "))")
                        .font(.caption)
                }
            }

            Spacer()

            Button {
                onRemove()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.red)
            }
            .buttonStyle(.borderless)
        }
        .padding(8)
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(8)
    }

    // MARK: - Display Name Helpers

    private func triggerDisplayName(_ trigger: String) -> String {
        Trigger(rawValue: trigger)?.displayName ?? trigger
    }

    private func effectTypeDisplayName(_ effectType: String) -> String {
        EffectType(rawValue: effectType)?.displayName ?? effectType
    }

    private func weatherDisplayName(_ weather: String) -> String {
        Weather(rawValue: weather)?.displayName ?? weather
    }

    private func terrainDisplayName(_ terrain: String) -> String {
        Terrain(rawValue: terrain)?.displayName ?? terrain
    }

    private func statusDisplayName(_ status: String) -> String {
        Status(rawValue: status)?.displayName ?? status
    }
}
