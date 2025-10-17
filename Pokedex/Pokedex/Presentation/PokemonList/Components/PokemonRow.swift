//
//  PokemonRow.swift
//  Pokedex
//
//  Created on 2025-10-04.
//

import SwiftUI

struct PokemonRow: View {
    let pokemon: Pokemon
    let selectedPokedex: PokedexType
    let matchInfo: PokemonMatchInfo?
    let statFilterConditions: [StatFilterCondition]
    let selectedMoves: [MoveEntity]
    let moveMetadataFilters: [MoveMetadataFilter]
    @EnvironmentObject private var localizationManager: LocalizationManager
    @State private var expandedGroups: Set<Int> = []

    init(
        pokemon: Pokemon,
        selectedPokedex: PokedexType,
        matchInfo: PokemonMatchInfo? = nil,
        statFilterConditions: [StatFilterCondition] = [],
        selectedMoves: [MoveEntity] = [],
        moveMetadataFilters: [MoveMetadataFilter] = []
    ) {
        self.pokemon = pokemon
        self.selectedPokedex = selectedPokedex
        self.matchInfo = matchInfo
        self.statFilterConditions = statFilterConditions
        self.selectedMoves = selectedMoves
        self.moveMetadataFilters = moveMetadataFilters
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DesignConstants.Spacing.small) {
            HStack(alignment: .top, spacing: DesignConstants.Spacing.small) {
                pokemonImage

                VStack(alignment: .leading, spacing: DesignConstants.Spacing.xxSmall) {
                    pokemonInfo
                }

                Spacer()
            }

            // 合致した技がある場合のみ表示
            if let matchInfo = matchInfo, !matchInfo.matchedMoves.isEmpty {
                matchedMovesView(matchInfo.matchedMoves)
                    .padding(.leading, DesignConstants.Spacing.small)
            }
        }
        .padding(.vertical, DesignConstants.Spacing.xxSmall)
    }

    private var pokemonImage: some View {
        AsyncImage(url: URL(string: pokemon.displayImageURL ?? "")) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            case .empty:
                ProgressView()
            case .failure:
                Image(systemName: "questionmark.circle")
                    .foregroundColor(.gray)
            @unknown default:
                EmptyView()
            }
        }
        .frame(width: DesignConstants.ImageSize.medium, height: DesignConstants.ImageSize.medium)
        .background(Color(.tertiarySystemFill))
        .clipShape(Circle())
        .shadow(color: Color(.systemGray).opacity(DesignConstants.Shadow.opacity), radius: DesignConstants.Shadow.medium, x: 0, y: 2)
    }

    private var pokemonInfo: some View {
        VStack(alignment: .leading, spacing: DesignConstants.Spacing.xxSmall) {
            pokemonHeader
            typesBadges

            // 合致した特性がある場合は合致理由のみ表示、ない場合は通常の特性表示
            if let matchInfo = matchInfo, !matchInfo.matchedAbilities.isEmpty {
                matchedAbilitiesView(matchInfo.matchedAbilities)
            } else {
                abilitiesText
            }

            baseStatsView
        }
    }

    private var pokemonHeader: some View {
        HStack(spacing: DesignConstants.Spacing.xSmall) {
            Text(pokedexNumber)
                .font(.caption)
                .foregroundColor(.secondary)

            Text(localizationManager.displayName(for: pokemon))
                .font(.headline)
        }
    }

    /// 選択された図鑑の番号を表示
    private var pokedexNumber: String {
        if selectedPokedex == .national {
            return pokemon.formattedId
        } else {
            if let number = pokemon.pokedexNumbers?[selectedPokedex.rawValue] {
                return String(format: "#%03d", number)
            } else {
                return pokemon.formattedId
            }
        }
    }

    private var typesBadges: some View {
        HStack(spacing: DesignConstants.Spacing.xxSmall) {
            ForEach(pokemon.types.sorted(by: { $0.slot < $1.slot })) { type in
                Text(localizationManager.displayName(for: type))
                    .typeBadgeStyle(type)
            }
        }
    }

    private var abilitiesText: some View {
        Text(abilitiesDisplay)
            .font(.caption)
            .foregroundColor(.secondary)
    }

    /// 特性の表示文字列（言語対応）
    private var abilitiesDisplay: String {
        if pokemon.abilities.isEmpty {
            return "-"
        }

        let normalAbilities = pokemon.abilities.filter { !$0.isHidden }
        let hiddenAbilities = pokemon.abilities.filter { $0.isHidden }

        var parts: [String] = []

        if !normalAbilities.isEmpty {
            parts.append(normalAbilities.map { localizationManager.displayName(for: $0).replacingOccurrences(of: " (隠れ特性)", with: "") }.joined(separator: " "))
        }

        if !hiddenAbilities.isEmpty {
            parts.append(hiddenAbilities.map { localizationManager.displayName(for: $0).replacingOccurrences(of: " (隠れ特性)", with: "") }.joined(separator: " "))
        }

        return parts.isEmpty ? "-" : parts.joined(separator: " ")
    }

    private var baseStatsView: some View {
        let hp = pokemon.stats.first { $0.name == "hp" }?.baseStat ?? 0
        let attack = pokemon.stats.first { $0.name == "attack" }?.baseStat ?? 0
        let defense = pokemon.stats.first { $0.name == "defense" }?.baseStat ?? 0
        let specialAttack = pokemon.stats.first { $0.name == "special-attack" }?.baseStat ?? 0
        let specialDefense = pokemon.stats.first { $0.name == "special-defense" }?.baseStat ?? 0
        let speed = pokemon.stats.first { $0.name == "speed" }?.baseStat ?? 0
        let total = pokemon.totalBaseStat

        let hpHighlighted = isStatHighlighted(value: hp, statType: .hp)
        let attackHighlighted = isStatHighlighted(value: attack, statType: .attack)
        let defenseHighlighted = isStatHighlighted(value: defense, statType: .defense)
        let specialAttackHighlighted = isStatHighlighted(value: specialAttack, statType: .specialAttack)
        let specialDefenseHighlighted = isStatHighlighted(value: specialDefense, statType: .specialDefense)
        let speedHighlighted = isStatHighlighted(value: speed, statType: .speed)
        let totalHighlighted = isStatHighlighted(value: total, statType: .total)

        return HStack(spacing: 0) {
            statText("\(hp)", highlighted: hpHighlighted)
            Text("-")
            statText("\(attack)", highlighted: attackHighlighted)
            Text("-")
            statText("\(defense)", highlighted: defenseHighlighted)
            Text("-")
            statText("\(specialAttack)", highlighted: specialAttackHighlighted)
            Text("-")
            statText("\(specialDefense)", highlighted: specialDefenseHighlighted)
            Text("-")
            statText("\(speed)", highlighted: speedHighlighted)
            Text(" (")
            statText("\(total)", highlighted: totalHighlighted)
            Text(")")
        }
        .font(.caption)
        .foregroundColor(.secondary)
        .fixedSize(horizontal: true, vertical: false)
    }

    private func statText(_ value: String, highlighted: Bool) -> some View {
        Text(value)
            .foregroundColor(highlighted ? .blue : .secondary)
            .fontWeight(highlighted ? .bold : .regular)
    }

    private func isStatHighlighted(value: Int, statType: StatType) -> Bool {
        statFilterConditions.contains { condition in
            condition.statType == statType && condition.matches(value)
        }
    }

    /// 合致した特性を表示
    private func matchedAbilitiesView(_ abilities: [String]) -> some View {
        HStack(alignment: .top, spacing: 4) {
            Text("特性:")
                .font(.caption2)
                .foregroundColor(.secondary)
                .frame(width: 32, alignment: .leading)
            HStack(spacing: 4) {
                ForEach(abilities.prefix(3), id: \.self) { abilityName in
                    Text(displayNameForAbility(abilityName))
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.15))
                        .foregroundColor(.blue)
                        .cornerRadius(4)
                }
                if abilities.count > 3 {
                    Text("+\(abilities.count - 3)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
    }

    /// 合致した技を表示（開閉可能・グループ分け）
    private func matchedMovesView(_ moves: [MoveLearnMethod]) -> some View {
        let grouped = groupMovesByCondition(moves)

        return VStack(alignment: .leading, spacing: 4) {
            ForEach(Array(grouped.enumerated()), id: \.offset) { index, group in
                MoveGroupView(
                    title: group.title,
                    detail: group.detail,
                    moves: group.moves,
                    isExpanded: Binding(
                        get: { expandedGroups.contains(index) },
                        set: { isExpanded in
                            if isExpanded {
                                expandedGroups.insert(index)
                            } else {
                                expandedGroups.remove(index)
                            }
                        }
                    )
                )
            }
        }
    }

    /// 技を条件ごとにグループ化
    private func groupMovesByCondition(_ moves: [MoveLearnMethod]) -> [(title: String, detail: String?, moves: [MoveLearnMethod])] {
        var groups: [(title: String, detail: String?, moves: [MoveLearnMethod])] = []

        // 選択した技でマッチしたもの
        let selectedMovesMatched = moves.filter { learnMethod in
            selectedMoves.contains(where: { $0.name == learnMethod.move.name })
        }
        if !selectedMovesMatched.isEmpty {
            groups.append((
                title: "選択した技",
                detail: nil,
                moves: selectedMovesMatched
            ))
        }

        // 各メタデータ条件でマッチしたもの
        for (index, filter) in moveMetadataFilters.enumerated() {
            let matchedByThisFilter = moves.filter { learnMethod in
                matchesMoveFilter(learnMethod.move, filter: filter)
            }
            if !matchedByThisFilter.isEmpty {
                groups.append((
                    title: "条件\(index + 1)",
                    detail: filterDetailText(filter),
                    moves: matchedByThisFilter
                ))
            }
        }

        return groups
    }

    /// フィルター条件の詳細テキストを生成
    private func filterDetailText(_ filter: MoveMetadataFilter) -> String {
        var parts: [String] = []

        if !filter.types.isEmpty {
            parts.append("タイプ: \(filter.types.map { FilterHelpers.typeJapaneseName($0) }.joined(separator: ", "))")
        }
        if !filter.damageClasses.isEmpty {
            parts.append("分類: \(filter.damageClasses.map { FilterHelpers.damageClassLabel($0) }.joined(separator: ", "))")
        }
        if let condition = filter.powerCondition {
            parts.append(condition.displayText(label: "威力"))
        }
        if let condition = filter.accuracyCondition {
            parts.append(condition.displayText(label: "命中率"))
        }
        if let condition = filter.ppCondition {
            parts.append(condition.displayText(label: "PP"))
        }
        if let priority = filter.priority {
            parts.append("優先度: \(priority >= 0 ? "+\(priority)" : "\(priority)")")
        }
        if !filter.targets.isEmpty {
            parts.append("対象: \(filter.targets.map { FilterHelpers.targetJapaneseName($0) }.joined(separator: ", "))")
        }

        return parts.isEmpty ? "すべて" : parts.joined(separator: ", ")
    }

    /// 技がフィルター条件に合致するか判定
    private func matchesMoveFilter(_ move: MoveEntity, filter: MoveMetadataFilter) -> Bool {
        // タイプ
        if !filter.types.isEmpty && !filter.types.contains(move.type.name) {
            return false
        }

        // 分類
        if !filter.damageClasses.isEmpty && !filter.damageClasses.contains(move.damageClass) {
            return false
        }

        // 威力
        if let condition = filter.powerCondition,
           let power = move.power {
            if !condition.matches(power) {
                return false
            }
        }

        // 命中率
        if let condition = filter.accuracyCondition,
           let accuracy = move.accuracy {
            if !condition.matches(accuracy) {
                return false
            }
        }

        // PP
        if let condition = filter.ppCondition {
            if !condition.matches(move.pp) {
                return false
            }
        }

        // 優先度
        if let priority = filter.priority,
           priority != move.priority {
            return false
        }

        // 対象
        if !filter.targets.isEmpty && !filter.targets.contains(move.target) {
            return false
        }

        return true
    }

    /// 特性名から表示名を取得
    private func displayNameForAbility(_ abilityName: String) -> String {
        // ポケモンの特性リストから該当する特性の日本語名を探す
        if let ability = pokemon.abilities.first(where: { $0.name == abilityName }) {
            return localizationManager.displayName(for: ability).replacingOccurrences(of: " (隠れ特性)", with: "")
        }
        return abilityName
    }
}

// MARK: - MoveGroupView

private struct MoveGroupView: View {
    let title: String
    let detail: String?
    let moves: [MoveLearnMethod]
    @Binding var isExpanded: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Button(action: {
                withAnimation {
                    isExpanded.toggle()
                }
            }) {
                HStack(spacing: 4) {
                    Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)

                    VStack(alignment: .leading, spacing: 1) {
                        Text(title)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        if let detail = detail {
                            Text(detail)
                                .font(.system(size: 9))
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .buttonStyle(.plain)

            if isExpanded {
                VStack(alignment: .leading, spacing: 2) {
                    ForEach(moves, id: \.move.id) { learnMethod in
                        HStack(spacing: 2) {
                            Text(learnMethod.move.nameJa)
                                .font(.caption2)
                            Text("(\(learnMethod.method.displayName))")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.green.opacity(0.15))
                        .foregroundColor(.green)
                        .cornerRadius(4)
                    }
                }
                .padding(.leading, 14)
            }
        }
    }
}
