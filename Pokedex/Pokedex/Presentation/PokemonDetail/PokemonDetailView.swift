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
            VStack(spacing: DesignConstants.Spacing.large) {
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
            .padding(DesignConstants.Spacing.medium)
        }
        .navigationTitle(viewModel.pokemon.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadEvolutionChain()
        }
    }

    // MARK: - Header View
    private var headerView: some View {
        VStack(spacing: DesignConstants.Spacing.medium) {
            pokemonImage
            shinyToggle
            pokemonNumber
            pokemonName
            typesBadges
        }
    }

    private var pokemonImage: some View {
        AsyncImage(url: URL(string: viewModel.displayImageURL ?? "")) { phase in
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
        .frame(width: DesignConstants.ImageSize.xLarge, height: DesignConstants.ImageSize.xLarge)
        .background(Color(.tertiarySystemFill))
        .clipShape(Circle())
        .shadow(color: Color(.systemGray).opacity(DesignConstants.Shadow.opacity), radius: DesignConstants.Shadow.medium, x: 0, y: 2)
    }

    private var shinyToggle: some View {
        Toggle("色違い", isOn: $viewModel.isShiny)
            .padding(.horizontal, DesignConstants.Spacing.xLarge * 2)
    }

    private var pokemonNumber: some View {
        Text(viewModel.pokemon.formattedId)
            .font(.caption)
            .foregroundColor(.secondary)
    }

    private var pokemonName: some View {
        Text(viewModel.pokemon.displayName)
            .font(.title)
            .fontWeight(.bold)
    }

    private var typesBadges: some View {
        HStack(spacing: DesignConstants.Spacing.xSmall) {
            ForEach(viewModel.pokemon.types.sorted(by: { $0.slot < $1.slot }), id: \.slot) { type in
                Text(type.japaneseName)
                    .typeBadgeStyle(type)
            }
        }
    }

    // MARK: - Basic Info View
    private var basicInfoView: some View {
        HStack(spacing: DesignConstants.Spacing.xLarge * 2) {
            heightInfo
            Divider().frame(height: 40)
            weightInfo
        }
        .padding(DesignConstants.Spacing.medium)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(DesignConstants.CornerRadius.large)
    }

    private var heightInfo: some View {
        VStack {
            Text("高さ")
                .font(.caption)
                .foregroundColor(.secondary)
            Text(String(format: "%.1f m", viewModel.pokemon.heightInMeters))
                .font(.title3)
                .fontWeight(.semibold)
        }
    }

    private var weightInfo: some View {
        VStack {
            Text("重さ")
                .font(.caption)
                .foregroundColor(.secondary)
            Text(String(format: "%.1f kg", viewModel.pokemon.weightInKilograms))
                .font(.title3)
                .fontWeight(.semibold)
        }
    }

    // MARK: - Evolution Chain View
    private var evolutionChainView: some View {
        VStack(alignment: .leading, spacing: DesignConstants.Spacing.small) {
            Text("進化")
                .font(.headline)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DesignConstants.Spacing.small) {
                    ForEach(Array(viewModel.evolutionChain.enumerated()), id: \.offset) { index, pokemonId in
                        VStack(spacing: DesignConstants.Spacing.xxSmall) {
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
                            .frame(width: DesignConstants.ImageSize.small, height: DesignConstants.ImageSize.small)

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
                .padding(.horizontal, DesignConstants.Spacing.xxSmall)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(DesignConstants.Spacing.medium)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(DesignConstants.CornerRadius.large)
    }

    // MARK: - Abilities View
    private var abilitiesView: some View {
        VStack(alignment: .leading, spacing: DesignConstants.Spacing.xSmall) {
            Text("特性")
                .font(.headline)

            ForEach(viewModel.pokemon.abilities, id: \.name) { ability in
                Text(ability.displayName)
                    .font(.body)
                    .foregroundColor(.primary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(DesignConstants.Spacing.medium)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(DesignConstants.CornerRadius.large)
    }

    // MARK: - Moves View
    private var movesView: some View {
        VStack(alignment: .leading, spacing: DesignConstants.Spacing.small) {
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
                    .padding(.vertical, DesignConstants.Spacing.xSmall)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: DesignConstants.Spacing.xSmall) {
                        ForEach(viewModel.filteredMoves) { move in
                            VStack(alignment: .leading, spacing: DesignConstants.Spacing.xxSmall) {
                                Text(move.displayName)
                                    .font(.caption)
                                    .fontWeight(.medium)

                                if let level = move.level {
                                    Text("Lv.\(level)")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.horizontal, DesignConstants.Spacing.small)
                            .padding(.vertical, DesignConstants.Spacing.xSmall)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(DesignConstants.CornerRadius.medium)
                        }
                    }
                    .padding(.horizontal, DesignConstants.Spacing.xxSmall)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(DesignConstants.Spacing.medium)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(DesignConstants.CornerRadius.large)
    }
}
