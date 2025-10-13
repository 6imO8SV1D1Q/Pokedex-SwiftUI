//
//  MoveMetadataConditionRow.swift
//  Pokedex
//
//  技のメタデータ条件表示行
//

import SwiftUI

struct MoveMetadataConditionRow: View {
    let filter: MoveMetadataFilter
    let index: Int
    let onRemove: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("条件\(index + 1)")
                    .font(.caption)
                    .fontWeight(.bold)

                if !filter.types.isEmpty {
                    Text("タイプ: \(filter.types.map { FilterHelpers.typeJapaneseName($0) }.joined(separator: ", "))")
                        .font(.caption)
                }
                if !filter.damageClasses.isEmpty {
                    Text("分類: \(filter.damageClasses.map { FilterHelpers.damageClassLabel($0) }.joined(separator: ", "))")
                        .font(.caption)
                }
                if let condition = filter.powerCondition {
                    Text(condition.displayText(label: "威力"))
                        .font(.caption)
                }
                if let condition = filter.accuracyCondition {
                    Text(condition.displayText(label: "命中率"))
                        .font(.caption)
                }
                if let condition = filter.ppCondition {
                    Text(condition.displayText(label: "PP"))
                        .font(.caption)
                }
                if let priority = filter.priority {
                    Text("優先度: \(priority >= 0 ? "+\(priority)" : "\(priority)")")
                        .font(.caption)
                }
                if !filter.targets.isEmpty {
                    Text("対象: \(filter.targets.count)件")
                        .font(.caption)
                }
                if !filter.ailments.isEmpty {
                    Text("状態異常: \(filter.ailments.map { $0.rawValue }.joined(separator: ", "))")
                        .font(.caption)
                }
                if filter.hasDrain || filter.hasHealing {
                    Text("回復: \(FilterHelpers.healingEffectsText(filter: filter))")
                        .font(.caption)
                }
                if !filter.statChanges.isEmpty {
                    Text("能力変化: \(filter.statChanges.map { $0.rawValue }.joined(separator: ", "))")
                        .font(.caption)
                }
                if !filter.categories.isEmpty {
                    Text("カテゴリー: \(filter.categories.count)件")
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
        }
        .padding(8)
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(8)
    }
}
