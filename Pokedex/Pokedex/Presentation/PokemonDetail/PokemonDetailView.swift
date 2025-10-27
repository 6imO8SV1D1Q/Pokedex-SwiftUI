//
//  PokemonDetailView.swift
//  Pokedex
//
//  Created on 2025-10-04.
//

import SwiftUI

struct PokemonDetailView: View {
    @ObservedObject var viewModel: PokemonDetailViewModel
    @EnvironmentObject private var localizationManager: LocalizationManager
    @State private var selectedTab: DetailTab = .ecology

    enum DetailTab {
        case ecology   // 生態タブ
        case battle    // バトルタブ
    }

    var body: some View {
        VStack(spacing: 0) {
            // スプライト＋基本情報（タブの上に固定表示）
            ScrollView {
                VStack(spacing: DesignConstants.Spacing.medium) {
                    spriteAndBasicInfo

                    // カスタムセグメントコントロール
                    segmentedControl

                    // タブコンテンツ
                    tabContent
                }
            }
        }
        .navigationDestination(for: Int.self) { pokemonId in
            // 進化チェーンからのナビゲーション
            PokemonLoadingView(pokemonId: pokemonId) { _ in }
        }
        .navigationTitle(localizationManager.displayName(for: viewModel.pokemon))
        .navigationBarTitleDisplayMode(.inline)
        .alert("エラー", isPresented: $viewModel.showError) {
            Button("OK") {
                viewModel.showError = false
            }
            Button("再試行") {
                Task {
                    await viewModel.loadPokemonDetail(id: viewModel.pokemon.id)
                }
            }
        } message: {
            Text(viewModel.errorMessage ?? "不明なエラーが発生しました")
        }
        .task {
            // v3.0データ読み込み（進化チェーンも含む）
            await viewModel.loadPokemonDetail(id: viewModel.pokemon.id)
        }
    }

    // MARK: - Sprite and Basic Info

    private var spriteAndBasicInfo: some View {
        HStack(alignment: .top, spacing: DesignConstants.Spacing.medium) {
            // 左側: スプライト
            VStack(spacing: DesignConstants.Spacing.small) {
                pokemonImage
                shinyToggle
            }

            // 右側: 基本情報
            VStack(alignment: .leading, spacing: DesignConstants.Spacing.xSmall) {
                Text(viewModel.pokemon.formattedId)
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text(localizationManager.displayName(for: viewModel.pokemon))
                    .font(.title2)
                    .fontWeight(.bold)

                typesBadges

                Divider()
                    .padding(.vertical, 2)

                HStack(spacing: DesignConstants.Spacing.large) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(L10n.PokemonDetail.heightLabel)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(String(format: "%.1f m", viewModel.pokemon.heightInMeters))
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(L10n.PokemonDetail.weightLabel)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(String(format: "%.1f kg", viewModel.pokemon.weightInKilograms))
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                }
            }

            Spacer()
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(DesignConstants.CornerRadius.large)
        .padding(.horizontal, DesignConstants.Spacing.medium)
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
        .frame(width: 120, height: 120)
        .background(Color(.tertiarySystemFill))
        .clipShape(Circle())
        .shadow(color: Color(.systemGray).opacity(DesignConstants.Shadow.opacity), radius: DesignConstants.Shadow.medium, x: 0, y: 2)
    }

    private var shinyToggle: some View {
        Button {
            viewModel.isShiny.toggle()
        } label: {
            HStack(spacing: 4) {
                Image(systemName: viewModel.isShiny ? "arrow.uturn.backward.circle.fill" : "sparkles")
                Text(viewModel.isShiny ? L10n.PokemonDetail.normal : L10n.PokemonDetail.shiny)
            }
            .font(.caption)
        }
        .buttonStyle(.bordered)
    }

    private var typesBadges: some View {
        HStack(spacing: DesignConstants.Spacing.xSmall) {
            ForEach(viewModel.displayTypes.sorted(by: { $0.slot < $1.slot }), id: \.slot) { type in
                Text(localizationManager.displayName(for: type))
                    .typeBadgeStyle(type)
            }
        }
    }

    // MARK: - Segmented Control

    private var segmentedControl: some View {
        Picker("タブ", selection: $selectedTab) {
            Label(L10n.Section.ecology, systemImage: "book.fill")
                .tag(DetailTab.ecology)
            Label(L10n.Section.battle, systemImage: "bolt.fill")
                .tag(DetailTab.battle)
        }
        .pickerStyle(.segmented)
        .padding(.horizontal, DesignConstants.Spacing.medium)
    }

    // MARK: - Tab Content

    @ViewBuilder
    private var tabContent: some View {
        switch selectedTab {
        case .ecology:
            EcologyTabView(viewModel: viewModel)
        case .battle:
            BattleTabView(viewModel: viewModel)
        }
    }

}
