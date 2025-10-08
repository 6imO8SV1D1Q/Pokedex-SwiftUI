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

                // 性別比・たまごグループ（v3.0新機能）
                if let species = viewModel.pokemonSpecies {
                    breedingInfoView(species: species)
                }

                // 図鑑テキスト（v3.0新機能）
                if let flavorText = viewModel.flavorText {
                    flavorTextView(flavorText: flavorText)
                }

                // フォーム選択（v3.0新機能）
                if !viewModel.availableForms.isEmpty {
                    PokemonFormSelectorSection(
                        forms: viewModel.availableForms,
                        selectedForm: viewModel.selectedForm,
                        onFormSelect: { form in
                            Task {
                                await viewModel.selectForm(form)
                            }
                        }
                    )
                }

                // タイプ相性（v3.0新機能）
                if let matchup = viewModel.typeMatchup {
                    ExpandableSection(
                        title: "タイプ相性",
                        systemImage: "shield.fill",
                        isExpanded: sectionBinding("typeMatchup")
                    ) {
                        TypeMatchupView(matchup: matchup)
                    }
                }

                // 種族値・実数値（v3.0更新）
                ExpandableSection(
                    title: viewModel.calculatedStats != nil ? "種族値・実数値" : "種族値",
                    systemImage: "chart.bar.fill",
                    isExpanded: sectionBinding("stats")
                ) {
                    if let calculatedStats = viewModel.calculatedStats {
                        CalculatedStatsView(
                            stats: calculatedStats,
                            baseStats: viewModel.pokemon.stats
                        )
                    } else {
                        PokemonStatsView(stats: viewModel.pokemon.stats)
                            .padding()
                    }
                }

                // 特性（v3.0更新）
                ExpandableSection(
                    title: "特性",
                    systemImage: "star.fill",
                    isExpanded: sectionBinding("abilities")
                ) {
                    if !viewModel.abilityDetails.isEmpty {
                        AbilitiesView(
                            abilities: viewModel.pokemon.abilities,
                            abilityDetails: viewModel.abilityDetails
                        )
                    } else {
                        abilitiesViewLegacy
                    }
                }

                // 出現場所（v3.0新機能）
                if !viewModel.locations.isEmpty {
                    ExpandableSection(
                        title: "出現場所",
                        systemImage: "map.fill",
                        isExpanded: sectionBinding("locations")
                    ) {
                        locationsView
                    }
                }

                // 覚える技（v3.0更新）
                ExpandableSection(
                    title: "覚える技",
                    systemImage: "bolt.fill",
                    isExpanded: sectionBinding("moves")
                ) {
                    MovesView(
                        moves: viewModel.pokemon.moves,
                        moveDetails: viewModel.moveDetails,
                        selectedLearnMethod: $viewModel.selectedLearnMethod
                    )
                }

                // 進化チェーン
                if let evolutionChainEntity = viewModel.evolutionChainEntity {
                    // v3.0: ツリー構造の進化チェーン
                    ExpandableSection(
                        title: "進化",
                        systemImage: "arrow.triangle.branch",
                        isExpanded: sectionBinding("evolution")
                    ) {
                        EvolutionChainView(chain: evolutionChainEntity)
                    }
                } else if !viewModel.evolutionChain.isEmpty {
                    // v2互換: 単純なIDリストの進化チェーン
                    ExpandableSection(
                        title: "進化",
                        systemImage: "arrow.triangle.branch",
                        isExpanded: sectionBinding("evolution")
                    ) {
                        evolutionChainViewLegacy
                    }
                }
            }
            .padding(DesignConstants.Spacing.medium)
        }
        .navigationDestination(for: Int.self) { pokemonId in
            // 進化チェーンからのナビゲーション
            PokemonLoadingView(pokemonId: pokemonId) { _ in }
        }
        .navigationTitle(viewModel.pokemon.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .alert("エラー", isPresented: $viewModel.showError) {
            Button("OK") {
                viewModel.showError = false
            }
            Button("再試行") {
                Task {
                    await viewModel.loadPokemonDetail(id: viewModel.pokemon.id)
                    await viewModel.loadEvolutionChain()
                }
            }
        } message: {
            Text(viewModel.errorMessage ?? "不明なエラーが発生しました")
        }
        .task {
            // v3.0データ読み込み
            await viewModel.loadPokemonDetail(id: viewModel.pokemon.id)
            // v2互換: 進化チェーン読み込み
            await viewModel.loadEvolutionChain()
        }
    }

    // MARK: - Section Binding Helper

    /// セクションの展開状態Bindingを生成
    private func sectionBinding(_ sectionId: String) -> Binding<Bool> {
        Binding(
            get: { viewModel.isSectionExpanded[sectionId, default: true] },
            set: { _ in viewModel.toggleSection(sectionId) }
        )
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

    // MARK: - v3.0 New Views

    /// 性別比・たまごグループ表示
    private func breedingInfoView(species: PokemonSpecies) -> some View {
        VStack(spacing: DesignConstants.Spacing.small) {
            // 性別比
            HStack {
                Text("性別比")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text(species.genderRatioDisplay)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, DesignConstants.Spacing.medium)

            Divider()

            // たまごグループ
            HStack {
                Text("たまごグループ")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text(species.eggGroupsDisplay)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, DesignConstants.Spacing.medium)
        }
        .padding(.vertical, DesignConstants.Spacing.medium)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(DesignConstants.CornerRadius.large)
    }

    /// 図鑑テキスト表示
    private func flavorTextView(flavorText: PokemonFlavorText) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(flavorText.text)
                .font(.body)
                .foregroundColor(.primary)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)

            Text("出典: \(flavorText.versionGroup)")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(DesignConstants.CornerRadius.large)
    }

    /// 出現場所表示
    private var locationsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(viewModel.locations, id: \.locationName) { location in
                VStack(alignment: .leading, spacing: 8) {
                    Text(location.locationName)
                        .font(.subheadline)
                        .fontWeight(.semibold)

                    ForEach(location.versionDetails, id: \.version) { detail in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(detail.version)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .fontWeight(.medium)

                            if !detail.encounterDetails.isEmpty {
                                ForEach(Array(detail.encounterDetails.enumerated()), id: \.offset) { _, encounter in
                                    HStack {
                                        Text("・\(encounter.displayMethod)")
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                        Text("Lv.\(encounter.minLevel)-\(encounter.maxLevel)")
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                        Text("\(encounter.chance)%")
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }
        }
        .padding()
    }

    // MARK: - Legacy v2 Views

    /// v2互換: シンプルな特性リスト
    private var abilitiesViewLegacy: some View {
        VStack(alignment: .leading, spacing: DesignConstants.Spacing.xSmall) {
            ForEach(viewModel.pokemon.abilities, id: \.name) { ability in
                Text(ability.displayName)
                    .font(.body)
                    .foregroundColor(.primary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
    }

    /// v2互換: IDベースの進化チェーン表示
    private var evolutionChainViewLegacy: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DesignConstants.Spacing.small) {
                ForEach(Array(viewModel.evolutionChain.enumerated()), id: \.offset) { index, pokemonId in
                    NavigationLink(value: pokemonId) {
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
                    }
                    .buttonStyle(PlainButtonStyle())

                    if index < viewModel.evolutionChain.count - 1 {
                        Image(systemName: "arrow.right")
                            .foregroundColor(.gray)
                            .font(.body)
                    }
                }
            }
            .padding()
        }
    }
}
