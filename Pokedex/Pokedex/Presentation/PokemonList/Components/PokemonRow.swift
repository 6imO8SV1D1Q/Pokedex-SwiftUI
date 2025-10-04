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
            AsyncImage(url: URL(string: pokemon.sprites.frontDefault ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } placeholder: {
                ProgressView()
            }
            .frame(width: 60, height: 60)

            // ポケモン情報
            VStack(alignment: .leading, spacing: 4) {
                // 図鑑番号と名前
                HStack(spacing: 8) {
                    Text(pokemon.formattedId)
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text(pokemon.name.capitalized)
                        .font(.headline)
                }

                // タイプバッジ
                HStack(spacing: 4) {
                    ForEach(pokemon.types.sorted(by: { $0.slot < $1.slot })) { type in
                        TypeBadge(typeName: type.name)
                    }
                }
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }
}

// MARK: - TypeBadge
struct TypeBadge: View {
    let typeName: String

    var body: some View {
        Text(typeName.capitalized)
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(typeColor)
            .cornerRadius(4)
    }

    private var typeColor: Color {
        switch typeName.lowercased() {
        case "normal": return Color.gray
        case "fire": return Color.red
        case "water": return Color.blue
        case "grass": return Color.green
        case "electric": return Color.yellow
        case "ice": return Color.cyan
        case "fighting": return Color.orange
        case "poison": return Color.purple
        case "ground": return Color.brown
        case "flying": return Color.indigo
        case "psychic": return Color.pink
        case "bug": return Color.mint
        case "rock": return Color.brown.opacity(0.7)
        case "ghost": return Color.indigo.opacity(0.7)
        case "dragon": return Color.indigo.opacity(0.8)
        case "dark": return Color.black.opacity(0.7)
        case "steel": return Color.gray.opacity(0.7)
        case "fairy": return Color.pink.opacity(0.7)
        default: return Color.gray
        }
    }
}
