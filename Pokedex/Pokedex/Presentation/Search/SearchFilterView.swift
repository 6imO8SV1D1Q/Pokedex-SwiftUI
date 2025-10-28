//
//  SearchFilterView.swift
//  Pokedex
//
//  フィルター画面（リファクタリング版）
//

import SwiftUI

struct SearchFilterView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: PokemonListViewModel

    @State private var allAbilities: [AbilityEntity] = []
    @State private var isLoadingAbilities = false
    @State private var allMoves: [MoveEntity] = []
    @State private var isLoadingMoves = false

    let fetchAllAbilitiesUseCase: FetchAllAbilitiesUseCaseProtocol
    let fetchAllMovesUseCase: FetchAllMovesUseCaseProtocol

    var body: some View {
        NavigationStack {
            Form {
                TypeFilterSection(
                    selectedTypes: $viewModel.selectedTypes,
                    filterMode: $viewModel.typeFilterMode
                )

                CategoryFilterSection(
                    selectedCategories: $viewModel.selectedCategories
                )

                EvolutionFilterSection(
                    evolutionFilterMode: $viewModel.evolutionFilterMode
                )

                StatFilterSection(
                    statFilterConditions: $viewModel.statFilterConditions
                )

                AbilityFilterSection(
                    selectedAbilities: $viewModel.selectedAbilities,
                    abilityMetadataFilters: $viewModel.abilityMetadataFilters,
                    filterMode: $viewModel.abilityFilterMode,
                    allAbilities: allAbilities,
                    isLoading: isLoadingAbilities
                )

                MoveFilterSection(
                    selectedMoves: $viewModel.selectedMoves,
                    selectedMoveCategories: $viewModel.selectedMoveCategories,
                    moveMetadataFilters: $viewModel.moveMetadataFilters,
                    filterMode: $viewModel.moveFilterMode,
                    allMoves: allMoves,
                    isLoading: isLoadingMoves
                )
            }
            .navigationTitle(L10n.Filter.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                clearButton
                applyButton
            }
            .onAppear {
                loadAbilities()
                loadMoves()
            }
        }
    }

    // MARK: - Toolbar

    private var clearButton: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button(L10n.Filter.clear) {
                clearAllFilters()
            }
        }
    }

    private var applyButton: some ToolbarContent {
        ToolbarItem(placement: .confirmationAction) {
            Button(L10n.Filter.apply) {
                viewModel.applyFilters()
                dismiss()
            }
        }
    }

    // MARK: - Actions

    private func clearAllFilters() {
        viewModel.selectedTypes.removeAll()
        viewModel.selectedCategories.removeAll()
        viewModel.selectedAbilities.removeAll()
        viewModel.abilityMetadataFilters.removeAll()
        viewModel.selectedMoveCategories.removeAll()
        viewModel.selectedMoves.removeAll()
        viewModel.evolutionFilterMode = .all
        viewModel.statFilterConditions.removeAll()
        viewModel.moveMetadataFilters.removeAll()
        viewModel.searchText = ""
        viewModel.applyFilters()
    }

    // MARK: - Data Loading

    private func loadAbilities() {
        guard allAbilities.isEmpty else { return }

        loadData(
            isLoading: $isLoadingAbilities,
            fetch: { try await fetchAllAbilitiesUseCase.execute() },
            onSuccess: { allAbilities = $0 },
            onError: { allAbilities = [] }
        )
    }

    private func loadMoves() {
        guard allMoves.isEmpty else { return }

        loadData(
            isLoading: $isLoadingMoves,
            fetch: { try await fetchAllMovesUseCase.execute(versionGroup: viewModel.selectedVersionGroup.id) },
            onSuccess: { allMoves = $0 },
            onError: { allMoves = [] }
        )
    }

    private func loadData<T>(
        isLoading: Binding<Bool>,
        fetch: @escaping () async throws -> T,
        onSuccess: @escaping (T) -> Void,
        onError: @escaping () -> Void
    ) {
        isLoading.wrappedValue = true
        Task { @MainActor in
            do {
                let result = try await fetch()
                onSuccess(result)
                print("✅ Loaded data successfully, count: \(result as? Array<Any> != nil ? (result as! Array<Any>).count : 0)")
            } catch {
                print("❌ Failed to load data: \(error)")
                onError()
            }
            isLoading.wrappedValue = false
        }
    }
}
