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
        VStack(spacing: 8) {
            pokemonImage
            pokemonNumber
            pokemonName
            typesBadges
        }
        .padding(8)
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
        .pokemonImageStyle(size: 100, clipShape: false)
    }

    private var pokemonNumber: some View {
        Text("#\(String(format: "%03d", pokemon.id))")
            .font(.caption2)
            .foregroundColor(.gray)
    }

    private var pokemonName: some View {
        Text(pokemon.displayName)
            .font(.caption)
            .fontWeight(.medium)
            .lineLimit(1)
    }

    private var typesBadges: some View {
        HStack(spacing: 4) {
            ForEach(pokemon.types, id: \.slot) { type in
                Text(type.japaneseName)
                    .typeBadgeStyle(type, fontSize: 9)
            }
        }
    }
}
