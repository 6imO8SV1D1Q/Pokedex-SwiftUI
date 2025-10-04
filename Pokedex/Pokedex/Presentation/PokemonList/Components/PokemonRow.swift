//
//  PokemonRow.swift
//  Pokedex
//
//  Created on 2025-10-04.
//

import SwiftUI

struct PokemonRow: View {
    let pokemon: Pokemon

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
        }
    }

    private var pokemonHeader: some View {
        HStack(spacing: DesignConstants.Spacing.xSmall) {
            Text(pokemon.formattedId)
                .font(.caption)
                .foregroundColor(.secondary)

            Text(pokemon.displayName)
                .font(.headline)
        }
    }

    private var typesBadges: some View {
        HStack(spacing: DesignConstants.Spacing.xxSmall) {
            ForEach(pokemon.types.sorted(by: { $0.slot < $1.slot })) { type in
                Text(type.japaneseName)
                    .typeBadgeStyle(type)
            }
        }
    }
}
