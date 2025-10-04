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

    // 全18タイプのリスト
    private let allTypes = [
        "normal", "fire", "water", "grass", "electric", "ice",
        "fighting", "poison", "ground", "flying", "psychic", "bug",
        "rock", "ghost", "dragon", "dark", "steel", "fairy"
    ]

    var body: some View {
        NavigationStack {
            Form {
                // タイプフィルター
                Section("タイプ") {
                    ForEach(allTypes, id: \.self) { typeName in
                        Button {
                            toggleTypeSelection(typeName)
                        } label: {
                            HStack {
                                Text(typeJapaneseName(typeName))
                                Spacer()
                                if viewModel.selectedTypes.contains(typeName) {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        .foregroundColor(.primary)
                    }
                }

                // 世代フィルター
                Section("世代") {
                    Picker("世代", selection: $viewModel.selectedGeneration) {
                        Text("第1世代").tag(1)
                    }
                    .pickerStyle(.menu)
                }
            }
            .navigationTitle("フィルター")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("クリア") {
                        viewModel.selectedTypes.removeAll()
                        viewModel.searchText = ""
                        viewModel.selectedGeneration = 1
                        viewModel.applyFilters()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("適用") {
                        viewModel.applyFilters()
                        dismiss()
                    }
                }
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
