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

    let fetchAllAbilitiesUseCase: FetchAllAbilitiesUseCaseProtocol

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
                generationFilterSection
            }
            .navigationTitle("フィルター")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                clearButton
                applyButton
            }
            .onAppear {
                loadAbilities()
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

    private var generationFilterSection: some View {
        Section("世代") {
            Picker("世代", selection: $viewModel.selectedGeneration) {
                Text("第1世代").tag(1)
            }
            .pickerStyle(.menu)
        }
    }

    private var clearButton: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("クリア") {
                viewModel.selectedTypes.removeAll()
                viewModel.selectedAbilities.removeAll()
                viewModel.searchText = ""
                viewModel.selectedGeneration = 1
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

    private func loadAbilities() {
        guard allAbilities.isEmpty else { return }

        isLoadingAbilities = true
        Task {
            do {
                allAbilities = try await fetchAllAbilitiesUseCase.execute()
            } catch {
                // エラーが発生しても空のリストを表示
                allAbilities = []
            }
            isLoadingAbilities = false
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
