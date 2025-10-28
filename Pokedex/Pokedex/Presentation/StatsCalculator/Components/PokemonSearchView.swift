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
    let isLoadingPokemon: Bool
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
                Text(L10n.StatsCalc.pokemonSelected)
                    .font(.headline)

                Spacer()

                Button {
                    selectedPokemon = nil
                    searchText = ""
                } label: {
                    Text(L10n.StatsCalc.pokemonChange)
                }
                .buttonStyle(.bordered)
            }

            HStack(spacing: DesignConstants.Spacing.small) {
                // スプライト画像
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
                            Text(LocalizationManager.shared.displayName(for: type))
                                .typeBadgeStyle(type, fontSize: 10)
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
            Text(L10n.StatsCalc.pokemonSearch)
                .font(.headline)

            // 検索ボックス
            TextField(L10n.StatsCalc.pokemonSearchPlaceholder, text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)

            // 候補リスト
            candidateList
        }
    }

    // MARK: - 候補リスト

    @ViewBuilder
    private var candidateList: some View {
        if isLoadingPokemon {
            HStack {
                ProgressView()
                Text(L10n.StatsCalc.pokemonLoading)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
        } else if !filteredPokemon.isEmpty {
            VStack(spacing: 8) {
                ForEach(filteredPokemon.prefix(10), id: \.id) { pokemon in
                    candidateRow(pokemon: pokemon)
                }
            }
        } else if !searchText.isEmpty {
            Text(L10n.StatsCalc.pokemonNotFound)
                .font(.caption)
                .foregroundColor(.secondary)
                .padding()
        }
    }

    // MARK: - 候補行

    private func candidateRow(pokemon: Pokemon) -> some View {
        Button {
            onSelect(pokemon)
        } label: {
            HStack {
                // スプライト画像
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
                .frame(width: DesignConstants.ImageSize.small, height: DesignConstants.ImageSize.small)
                .background(Color(.tertiarySystemFill))
                .clipShape(Circle())
                .shadow(color: Color(.systemGray).opacity(DesignConstants.Shadow.opacity), radius: DesignConstants.Shadow.small, x: 0, y: 1)

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
                        Text(LocalizationManager.shared.displayName(for: type))
                            .typeBadgeStyle(type, fontSize: 9)
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

#Preview {
    PokemonSearchView(
        selectedPokemon: .constant(nil),
        searchText: .constant(""),
        filteredPokemon: [],
        isLoadingPokemon: false,
        onSelect: { _ in }
    )
}
