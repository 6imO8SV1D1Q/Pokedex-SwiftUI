//
//  PokemonGridItem.swift
//  Pokedex
//
//  Created on 2025-10-04.
//

import SwiftUI

struct PokemonGridItem: View {
    let pokemon: Pokemon

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
        Text(pokemon.formattedId)
            .font(.caption2)
            .foregroundColor(.secondary)
    }

    private var pokemonName: some View {
        Text(pokemon.displayName)
            .font(.caption)
            .fontWeight(.medium)
            .lineLimit(1)
    }

    private var typesBadges: some View {
        HStack(spacing: DesignConstants.Spacing.xxSmall) {
            ForEach(pokemon.types, id: \.slot) { type in
                Text(type.japaneseName)
                    .typeBadgeStyle(type, fontSize: 9)
            }
        }
    }

    private var abilitiesText: some View {
        Text(pokemon.abilitiesDisplayMultiline)
            .font(.caption2)
            .foregroundColor(.secondary)
            .lineLimit(3)
            .multilineTextAlignment(.center)
    }

    private var baseStatsText: some View {
        Text(pokemon.baseStatsDisplay)
            .font(.caption2)
            .foregroundColor(.secondary)
            .lineLimit(2)
            .multilineTextAlignment(.center)
    }
}
