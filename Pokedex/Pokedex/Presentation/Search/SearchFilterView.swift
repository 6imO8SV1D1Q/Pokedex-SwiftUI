//
//  SearchFilterView.swift
//  Pokedex
//
//  Created on 2025-10-04.
//

import SwiftUI

struct SearchFilterView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: PokemonListViewModel
    @State private var allAbilities: [String] = []
    @State private var isLoadingAbilities = false
    @State private var allMoves: [MoveEntity] = []
    @State private var isLoadingMoves = false

    let fetchAllAbilitiesUseCase: FetchAllAbilitiesUseCaseProtocol
    let fetchAllMovesUseCase: FetchAllMovesUseCaseProtocol

    // 全18タイプのリスト
    private let allTypes = [
        "normal", "fire", "water", "grass", "electric", "ice",
        "fighting", "poison", "ground", "flying", "psychic", "bug",
        "rock", "ghost", "dragon", "dark", "steel", "fairy"
    ]

    var body: some View {
        NavigationStack {
            Form {
                typeFilterSection
                abilityFilterSection
                moveFilterSection
            }
            .navigationTitle("フィルター")
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

    private var typeFilterSection: some View {
        Section("タイプ") {
            ForEach(allTypes, id: \.self) { typeName in
                typeSelectionButton(typeName)
            }
        }
    }

    private func typeSelectionButton(_ typeName: String) -> some View {
        Button {
            toggleTypeSelection(typeName)
        } label: {
            HStack {
                Text(typeJapaneseName(typeName))
                Spacer()
                if viewModel.selectedTypes.contains(typeName) {
                    checkmark
                }
            }
        }
        .foregroundColor(.primary)
    }

    private var checkmark: some View {
        Image(systemName: "checkmark")
            .foregroundColor(.blue)
    }

    private var abilityFilterSection: some View {
        Section("特性") {
            if isLoadingAbilities {
                ProgressView()
            } else {
                ForEach(allAbilities, id: \.self) { abilityName in
                    abilitySelectionButton(abilityName)
                }
            }
        }
    }

    private func abilitySelectionButton(_ abilityName: String) -> some View {
        Button {
            toggleAbilitySelection(abilityName)
        } label: {
            HStack {
                Text(abilityName.capitalized)
                Spacer()
                if viewModel.selectedAbilities.contains(abilityName) {
                    checkmark
                }
            }
        }
        .foregroundColor(.primary)
    }

    private var moveFilterSection: some View {
        Section("技") {
            if !isMoveFilterEnabled {
                Text("技フィルターはバージョングループを選択した場合のみ利用可能です。")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else if isLoadingMoves {
                ProgressView()
            } else {
                ForEach(allMoves.prefix(100)) { move in // 最初の100件のみ表示
                    moveSelectionButton(move)
                }
            }
        }
    }

    private func moveSelectionButton(_ move: MoveEntity) -> some View {
        Button {
            toggleMoveSelection(move)
        } label: {
            HStack {
                Text(move.name.capitalized)
                Spacer()
                if viewModel.selectedMoves.contains(where: { $0.id == move.id }) {
                    checkmark
                }
            }
        }
        .foregroundColor(.primary)
        .disabled(viewModel.selectedMoves.count >= 4 && !viewModel.selectedMoves.contains(where: { $0.id == move.id }))
    }

    private var isMoveFilterEnabled: Bool {
        viewModel.selectedVersionGroup.id != "national"
    }

    private var clearButton: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("クリア") {
                viewModel.selectedTypes.removeAll()
                viewModel.selectedAbilities.removeAll()
                viewModel.selectedMoves.removeAll()
                viewModel.searchText = ""
                viewModel.applyFilters()
            }
        }
    }

    private var applyButton: some ToolbarContent {
        ToolbarItem(placement: .confirmationAction) {
            Button("適用") {
                viewModel.applyFilters()
                dismiss()
            }
        }
    }

    private func toggleTypeSelection(_ typeName: String) {
        if viewModel.selectedTypes.contains(typeName) {
            viewModel.selectedTypes.remove(typeName)
        } else {
            viewModel.selectedTypes.insert(typeName)
        }
    }

    private func toggleAbilitySelection(_ abilityName: String) {
        if viewModel.selectedAbilities.contains(abilityName) {
            viewModel.selectedAbilities.remove(abilityName)
        } else {
            viewModel.selectedAbilities.insert(abilityName)
        }
    }

    private func toggleMoveSelection(_ move: MoveEntity) {
        if let index = viewModel.selectedMoves.firstIndex(where: { $0.id == move.id }) {
            viewModel.selectedMoves.remove(at: index)
        } else if viewModel.selectedMoves.count < 4 {
            viewModel.selectedMoves.append(move)
        }
    }

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
        guard isMoveFilterEnabled else { return }

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
        Task {
            do {
                let result = try await fetch()
                onSuccess(result)
            } catch {
                onError()
            }
            isLoading.wrappedValue = false
        }
    }

    private func typeJapaneseName(_ typeName: String) -> String {
        // PokemonType.japaneseNameと同じマッピング
        switch typeName {
        case "normal": return "ノーマル"
        case "fire": return "ほのお"
        case "water": return "みず"
        case "grass": return "くさ"
        case "electric": return "でんき"
        case "ice": return "こおり"
        case "fighting": return "かくとう"
        case "poison": return "どく"
        case "ground": return "じめん"
        case "flying": return "ひこう"
        case "psychic": return "エスパー"
        case "bug": return "むし"
        case "rock": return "いわ"
        case "ghost": return "ゴースト"
        case "dragon": return "ドラゴン"
        case "dark": return "あく"
        case "steel": return "はがね"
        case "fairy": return "フェアリー"
        default: return typeName.capitalized
        }
    }
}
