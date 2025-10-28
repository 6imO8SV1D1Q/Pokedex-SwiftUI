//
//  EcologyTabView.swift
//  Pokedex
//
//  Created on 2025-10-21.
//

import SwiftUI

/// 生態タブ: 図鑑情報を表示
struct EcologyTabView: View {
    @ObservedObject var viewModel: PokemonDetailViewModel
    @EnvironmentObject private var localizationManager: LocalizationManager

    var body: some View {
        VStack(spacing: DesignConstants.Spacing.large) {
            // 繁殖情報
                if let species = viewModel.pokemonSpecies {
                    breedingInfoView(species: species)
                }

                // 図鑑説明
                if let flavorText = viewModel.flavorText {
                    flavorTextView(flavorText: flavorText)
                }

                // フォーム選択（複数フォームがある場合のみ）
                if viewModel.availableForms.count > 1 {
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

                // 進化チェーン
                if let evolutionChainEntity = viewModel.evolutionChainEntity {
                    evolutionChainView(evolutionChainEntity)
                }
        }
        .padding(DesignConstants.Spacing.medium)
    }

    // MARK: - Helpers

    /// たまごグループの表示テキストを生成
    private func eggGroupsDisplayText(species: PokemonSpecies) -> String {
        if species.eggGroups.isEmpty {
            return FilterHelpers.eggGroupName("undiscovered")
        }
        return species.eggGroups
            .map { FilterHelpers.eggGroupName($0.name) }
            .joined(separator: localizationManager.currentLanguage == .japanese ? "、" : ", ")
    }

    // MARK: - Breeding Info

    private func breedingInfoView(species: PokemonSpecies) -> some View {
        VStack(spacing: DesignConstants.Spacing.small) {
            // 性別比
            HStack {
                Text(L10n.PokemonDetail.genderRatio)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text(FilterHelpers.genderRatioText(genderRate: species.genderRate))
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, DesignConstants.Spacing.medium)

            Divider()

            // たまごグループ
            HStack {
                Text(L10n.PokemonDetail.eggGroups)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text(eggGroupsDisplayText(species: species))
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, DesignConstants.Spacing.medium)
        }
        .padding(.vertical, DesignConstants.Spacing.medium)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(DesignConstants.CornerRadius.large)
    }

    // MARK: - Flavor Text

    private func flavorTextView(flavorText: PokemonFlavorText) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(flavorText.text)
                .font(.body)
                .foregroundColor(.primary)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)

            Text(L10n.PokemonDetail.flavorTextSource(flavorText.versionGroup))
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(DesignConstants.CornerRadius.large)
    }

    // MARK: - Evolution Chain

    private func evolutionChainView(_ chain: EvolutionChainEntity) -> some View {
        VStack(alignment: .leading, spacing: DesignConstants.Spacing.small) {
            Text(L10n.PokemonDetail.evolution)
                .font(.headline)

            EvolutionChainView(
                chain: chain,
                regionalForms: viewModel.evolutionFormVariants
            )
        }
    }
}
