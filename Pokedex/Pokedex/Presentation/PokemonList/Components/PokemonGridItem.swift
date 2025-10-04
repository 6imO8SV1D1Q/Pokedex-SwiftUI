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
            // ポケモン画像
            AsyncImage(url: URL(string: pokemon.sprites.preferredImageURL ?? "")) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                case .failure:
                    Image(systemName: "questionmark.circle")
                        .foregroundColor(.gray)
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: 100, height: 100)

            // 図鑑番号
            Text("#\(String(format: "%03d", pokemon.id))")
                .font(.caption2)
                .foregroundColor(.gray)

            // 名前
            Text(pokemon.displayName)
                .font(.caption)
                .fontWeight(.medium)
                .lineLimit(1)

            // タイプバッジ
            HStack(spacing: 4) {
                ForEach(pokemon.types, id: \.slot) { type in
                    Text(type.japaneseName)
                        .font(.system(size: 9))
                        .fontWeight(.semibold)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(type.color)
                        .foregroundColor(.white)
                        .cornerRadius(4)
                }
            }
        }
        .padding(8)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}
