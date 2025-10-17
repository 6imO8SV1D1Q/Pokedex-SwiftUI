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
    @EnvironmentObject private var localizationManager: LocalizationManager

    init(pokemon: Pokemon, selectedPokedex: PokedexType, matchInfo: PokemonMatchInfo? = nil) {
        self.pokemon = pokemon
        self.selectedPokedex = selectedPokedex
        self.matchInfo = matchInfo
    }

    var body: some View {
        HStack(spacing: DesignConstants.Spacing.small) {
            pokemonImage
            pokemonInfo
            Spacer()
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
            abilitiesText
            baseStatsText
            if let matchInfo = matchInfo, !matchInfo.isEmpty {
                matchInfoView(matchInfo)
            }
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

    private var baseStatsText: some View {
        Text(pokemon.baseStatsDisplay)
            .font(.caption)
            .foregroundColor(.secondary)
            .lineLimit(1)
    }

    /// 絞り込み条件に合致した理由を表示
    private func matchInfoView(_ matchInfo: PokemonMatchInfo) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            // 合致した特性を表示
            if !matchInfo.matchedAbilities.isEmpty {
                HStack(alignment: .top, spacing: 4) {
                    Text("特性:")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .frame(width: 32, alignment: .leading)
                    HStack(spacing: 4) {
                        ForEach(matchInfo.matchedAbilities.prefix(3), id: \.self) { abilityName in
                            Text(displayNameForAbility(abilityName))
                                .font(.caption2)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.blue.opacity(0.15))
                                .foregroundColor(.blue)
                                .cornerRadius(4)
                        }
                    }
                }
            }

            // 合致した技を表示（最大3つ）
            if !matchInfo.matchedMoves.isEmpty {
                HStack(alignment: .top, spacing: 4) {
                    Text("技:")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .frame(width: 32, alignment: .leading)
                    HStack(spacing: 4) {
                        ForEach(Array(matchInfo.matchedMoves.prefix(3)), id: \.move.id) { learnMethod in
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
                        if matchInfo.matchedMoves.count > 3 {
                            Text("+\(matchInfo.matchedMoves.count - 3)")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
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
