//
//  PokemonDetailView.swift
//  Pokedex
//
//  Created on 2025-10-04.
//

import SwiftUI

struct PokemonDetailView: View {
    @ObservedObject var viewModel: PokemonDetailViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // ヘッダー(画像、番号、名前、タイプ)
                headerView

                // 基本情報(身長、体重)
                basicInfoView

                // 進化チェーン
                if !viewModel.evolutionChain.isEmpty {
                    evolutionChainView
                }

                // ステータス
                PokemonStatsView(stats: viewModel.pokemon.stats)

                // 特性
                abilitiesView

                // 覚える技
                movesView
            }
            .padding()
        }
        .navigationTitle(viewModel.pokemon.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadEvolutionChain()
        }
    }

    // MARK: - Header View
    private var headerView: some View {
        VStack(spacing: 16) {
            // ポケモン画像
            AsyncImage(url: URL(string: viewModel.displayImageURL ?? "")) { phase in
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
            .frame(width: 120, height: 120)
            .background(Color.gray.opacity(0.1))
            .clipShape(Circle())
            .shadow(color: .black.opacity(0.5), radius: 4, x: 0, y: 2)

            // 色違い切り替え
            Toggle("色違い", isOn: $viewModel.isShiny)
                .padding(.horizontal, 40)

            // 図鑑番号
            Text(viewModel.pokemon.formattedId)
                .font(.caption)
                .foregroundColor(.secondary)

            // 名前
            Text(viewModel.pokemon.displayName)
                .font(.title)
                .fontWeight(.bold)

            // タイプバッジ
            HStack(spacing: 8) {
                ForEach(viewModel.pokemon.types.sorted(by: { $0.slot < $1.slot }), id: \.slot) { type in
                    Text(type.japaneseName)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(type.color)
                        .foregroundColor(.white)
                        .cornerRadius(16)
                }
            }
        }
    }

    // MARK: - Basic Info View
    private var basicInfoView: some View {
        HStack(spacing: 40) {
            VStack {
                Text("高さ")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(String(format: "%.1f m", viewModel.pokemon.heightInMeters))
                    .font(.title3)
                    .fontWeight(.semibold)
            }

            Divider()
                .frame(height: 40)

            VStack {
                Text("重さ")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(String(format: "%.1f kg", viewModel.pokemon.weightInKilograms))
                    .font(.title3)
                    .fontWeight(.semibold)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }

    // MARK: - Evolution Chain View
    private var evolutionChainView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("進化")
                .font(.headline)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Array(viewModel.evolutionChain.enumerated()), id: \.offset) { index, pokemonId in
                        VStack(spacing: 4) {
                            AsyncImage(url: URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/home/\(pokemonId).png")) { phase in
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
                            .frame(width: 60, height: 60)

                            Text(String(format: "#%03d", pokemonId))
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }

                        if index < viewModel.evolutionChain.count - 1 {
                            Image(systemName: "arrow.right")
                                .foregroundColor(.gray)
                                .font(.body)
                        }
                    }
                }
                .padding(.horizontal, 4)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }

    // MARK: - Abilities View
    private var abilitiesView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("特性")
                .font(.headline)

            ForEach(viewModel.pokemon.abilities, id: \.name) { ability in
                Text(ability.displayName)
                    .font(.body)
                    .foregroundColor(.primary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }

    // MARK: - Moves View
    private var movesView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("覚える技")
                    .font(.headline)

                Spacer()

                Picker("習得方法", selection: $viewModel.selectedLearnMethod) {
                    Text("レベル").tag("level-up")
                    Text("マシン").tag("machine")
                    Text("タマゴ").tag("egg")
                    Text("教え技").tag("tutor")
                }
                .pickerStyle(.menu)
            }

            if viewModel.filteredMoves.isEmpty {
                Text("この方法で覚える技はありません")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.vertical, 8)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 8) {
                        ForEach(viewModel.filteredMoves) { move in
                            VStack(alignment: .leading, spacing: 2) {
                                Text(move.displayName)
                                    .font(.caption)
                                    .fontWeight(.medium)

                                if let level = move.level {
                                    Text("Lv.\(level)")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal, 4)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}
