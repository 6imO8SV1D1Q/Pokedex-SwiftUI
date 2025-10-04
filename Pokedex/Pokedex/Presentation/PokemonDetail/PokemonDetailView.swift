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

                // ステータス
                PokemonStatsView(stats: viewModel.pokemon.stats)

                // 特性
                abilitiesView
            }
            .padding()
        }
        .navigationTitle(viewModel.pokemon.displayName)
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Header View
    private var headerView: some View {
        VStack(spacing: 16) {
            // ポケモン画像
            AsyncImage(url: URL(string: viewModel.pokemon.sprites.preferredImageURL ?? "")) { phase in
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
}
