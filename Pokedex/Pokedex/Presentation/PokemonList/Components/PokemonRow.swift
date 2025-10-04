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
        HStack(spacing: 12) {
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
            .frame(width: 80, height: 80)
            .background(Color.gray.opacity(0.1))
            .clipShape(Circle())
            .shadow(color: .black.opacity(0.5), radius: 4, x: 0, y: 2)

            // ポケモン情報
            VStack(alignment: .leading, spacing: 4) {
                // 図鑑番号と名前
                HStack(spacing: 8) {
                    Text(pokemon.formattedId)
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text(pokemon.displayName)
                        .font(.headline)
                }

                // タイプバッジ
                HStack(spacing: 4) {
                    ForEach(pokemon.types.sorted(by: { $0.slot < $1.slot })) { type in
                        Text(type.japaneseName)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(type.color)
                            .foregroundColor(.white)
                            .cornerRadius(4)
                    }
                }
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }
}
