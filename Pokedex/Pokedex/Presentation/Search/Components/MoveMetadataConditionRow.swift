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
                Text(L10n.Filter.condition(index + 1))
                    .font(.caption)
                    .fontWeight(.bold)

                if !filter.types.isEmpty {
                    Text(L10n.Filter.affectedTypesValue(filter.types.map { FilterHelpers.typeJapaneseName($0) }.joined(separator: ", ")))
                        .font(.caption)
                }
                if !filter.damageClasses.isEmpty {
                    Text(NSLocalizedString("filter.category", comment: "") + ": " + filter.damageClasses.map { FilterHelpers.damageClassLabel($0) }.joined(separator: ", "))
                        .font(.caption)
                }
                if let condition = filter.powerCondition {
                    Text(condition.displayText(label: L10n.Filter.powerLabel))
                        .font(.caption)
                }
                if let condition = filter.accuracyCondition {
                    Text(condition.displayText(label: L10n.Filter.accuracyLabel))
                        .font(.caption)
                }
                if let condition = filter.ppCondition {
                    Text(condition.displayText(label: L10n.Filter.ppLabel))
                        .font(.caption)
                }
                if let priority = filter.priority {
                    Text(L10n.Filter.priorityValue(priority >= 0 ? "+\(priority)" : "\(priority)"))
                        .font(.caption)
                }
                if !filter.targets.isEmpty {
                    Text(L10n.Filter.targetValue(filter.targets.map { FilterHelpers.targetJapaneseName($0) }.joined(separator: ", ")))
                        .font(.caption)
                }
                if !filter.ailments.isEmpty {
                    Text(L10n.Filter.statusConditionValue(filter.ailments.map { $0.rawValue }.joined(separator: ", ")))
                        .font(.caption)
                }
                if filter.hasDrain || filter.hasHealing {
                    Text(L10n.Filter.recoveryValue(FilterHelpers.healingEffectsText(filter: filter)))
                        .font(.caption)
                }
                if !filter.statChanges.isEmpty {
                    Text(L10n.Filter.statChangeValue(filter.statChanges.map { $0.rawValue }.joined(separator: ", ")))
                        .font(.caption)
                }
                if !filter.categories.isEmpty {
                    Text(L10n.Filter.categoriesCount(filter.categories.count))
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
}
