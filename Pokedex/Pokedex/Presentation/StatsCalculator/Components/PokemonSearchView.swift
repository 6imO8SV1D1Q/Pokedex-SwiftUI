//
//  PokemonSearchView.swift
//  Pokedex
//
//  Created on 2025-10-26.
//

import SwiftUI

/// ポケモン検索UI
struct PokemonSearchView: View {
    @Binding var selectedPokemon: Pokemon?
    @Binding var searchText: String
    let filteredPokemon: [Pokemon]
    let onSelect: (Pokemon) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let pokemon = selectedPokemon {
                // 選択済みポケモンの表示
                selectedPokemonCard(pokemon)
            } else {
                // 検索UI
                searchSection
            }
        }
    }

    // MARK: - 選択済みポケモンカード

    private func selectedPokemonCard(_ pokemon: Pokemon) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("選択中のポケモン")
                    .font(.headline)

                Spacer()

                Button("変更") {
                    selectedPokemon = nil
                    searchText = ""
                }
                .buttonStyle(.bordered)
            }

            HStack(spacing: 16) {
                // スプライト画像
                AsyncImage(url: URL(string: pokemon.sprites.frontDefault)) { image in
                    image
                        .resizable()
                        .interpolation(.none)
                        .frame(width: 80, height: 80)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 80, height: 80)
                }

                VStack(alignment: .leading, spacing: 4) {
                    // 名前
                    HStack(spacing: 8) {
                        Text(pokemon.nameJa ?? pokemon.name)
                            .font(.title2)
                            .fontWeight(.bold)

                        Text("#\(pokemon.nationalDexNumber ?? pokemon.id)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    // タイプバッジ
                    HStack(spacing: 4) {
                        ForEach(pokemon.types, id: \.name) { type in
                            Text(LocalizationManager.shared.localizedTypeName(type.name))
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(LocalizationManager.shared.typeColor(for: type.name))
                                .foregroundColor(.white)
                                .cornerRadius(4)
                        }
                    }
                }

                Spacer()
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }

    // MARK: - 検索セクション

    private var searchSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("ポケモンを検索")
                .font(.headline)

            // 検索ボックス
            TextField("名前または図鑑番号で検索", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)

            // 候補リスト
            if !filteredPokemon.isEmpty {
                VStack(spacing: 8) {
                    ForEach(filteredPokemon.prefix(10), id: \.id) { pokemon in
                        Button {
                            onSelect(pokemon)
                        } label: {
                            HStack {
                                // スプライト画像
                                AsyncImage(url: URL(string: pokemon.sprites.frontDefault)) { image in
                                    image
                                        .resizable()
                                        .interpolation(.none)
                                        .frame(width: 40, height: 40)
                                } placeholder: {
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.2))
                                        .frame(width: 40, height: 40)
                                }

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(pokemon.nameJa ?? pokemon.name)
                                        .font(.subheadline)
                                        .fontWeight(.medium)

                                    Text("#\(pokemon.nationalDexNumber ?? pokemon.id)")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }

                                Spacer()

                                // タイプバッジ
                                HStack(spacing: 4) {
                                    ForEach(pokemon.types, id: \.name) { type in
                                        Text(LocalizationManager.shared.localizedTypeName(type.name))
                                            .font(.caption2)
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(LocalizationManager.shared.typeColor(for: type.name))
                                            .foregroundColor(.white)
                                            .cornerRadius(3)
                                    }
                                }
                            }
                            .padding(8)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            } else if !searchText.isEmpty {
                Text("該当するポケモンが見つかりません")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding()
            }
        }
    }
}

#Preview {
    PokemonSearchView(
        selectedPokemon: .constant(nil),
        searchText: .constant(""),
        filteredPokemon: [],
        onSelect: { _ in }
    )
}
