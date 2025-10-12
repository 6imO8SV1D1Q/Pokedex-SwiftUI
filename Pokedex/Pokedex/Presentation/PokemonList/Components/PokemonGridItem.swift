//
//  PokemonGridItem.swift
//  Pokedex
//
//  Created on 2025-10-04.
//

import SwiftUI

struct PokemonGridItem: View {
    let pokemon: Pokemon
    let selectedPokedex: PokedexType
    @EnvironmentObject private var localizationManager: LocalizationManager

    var body: some View {
        VStack(spacing: DesignConstants.Spacing.xSmall) {
            pokemonImage
            pokemonNumber
            pokemonName
            typesBadges
            abilitiesText
            baseStatsText
        }
        .frame(height: 280)
        .padding(DesignConstants.Spacing.xSmall)
        .cardStyle()
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
        .pokemonImageStyle(size: DesignConstants.ImageSize.large, clipShape: false)
    }

    private var pokemonNumber: some View {
        Text(pokedexNumber)
            .font(.caption2)
            .foregroundColor(.secondary)
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

    private var pokemonName: some View {
        Text(localizationManager.displayName(for: pokemon))
            .font(.caption)
            .fontWeight(.medium)
            .lineLimit(1)
    }

    private var typesBadges: some View {
        HStack(spacing: DesignConstants.Spacing.xxSmall) {
            ForEach(pokemon.types, id: \.slot) { type in
                Text(localizationManager.displayName(for: type))
                    .typeBadgeStyle(type, fontSize: 9)
            }
        }
    }

    private var abilitiesText: some View {
        Text(abilitiesDisplay)
            .font(.caption2)
            .foregroundColor(.secondary)
            .lineLimit(3)
            .multilineTextAlignment(.center)
    }

    /// 特性の表示文字列（改行区切り、言語対応）
    private var abilitiesDisplay: String {
        if pokemon.abilities.isEmpty {
            return "-"
        }

        return pokemon.abilities.map {
            localizationManager.displayName(for: $0).replacingOccurrences(of: " (隠れ特性)", with: "")
        }.joined(separator: "\n")
    }

    private var baseStatsText: some View {
        Text(pokemon.baseStatsDisplay)
            .font(.caption2)
            .foregroundColor(.secondary)
            .lineLimit(2)
            .multilineTextAlignment(.center)
    }
}
