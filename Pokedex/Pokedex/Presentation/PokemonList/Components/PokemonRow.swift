//
//  PokemonRow.swift
//  Pokedex
//
//  Created on 2025-10-04.
//

import SwiftUI

struct PokemonRow: View {
    let pokemon: Pokemon
    @EnvironmentObject private var localizationManager: LocalizationManager

    var body: some View {
        HStack(spacing: DesignConstants.Spacing.small) {
            pokemonImage
            pokemonInfo
            Spacer()
        }
        .padding(.vertical, DesignConstants.Spacing.xxSmall)
    }

    private var pokemonImage: some View {
        AsyncImage(url: URL(string: pokemon.sprites.preferredImageURL ?? "")) { phase in
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
        }
    }

    private var pokemonHeader: some View {
        HStack(spacing: DesignConstants.Spacing.xSmall) {
            Text(pokemon.formattedId)
                .font(.caption)
                .foregroundColor(.secondary)

            Text(localizationManager.displayName(for: pokemon))
                .font(.headline)
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
}
