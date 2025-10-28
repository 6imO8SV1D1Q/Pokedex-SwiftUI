//
//  EvolutionFilterSection.swift
//  Pokedex
//
//  進化フィルターセクション
//

import SwiftUI

struct EvolutionFilterSection: View {
    @Binding var evolutionFilterMode: EvolutionFilterMode

    var body: some View {
        Section {
            Picker(L10n.Filter.evolutionStageLabel, selection: $evolutionFilterMode) {
                ForEach(EvolutionFilterMode.allCases) { mode in
                    Text(mode.displayName).tag(mode)
                }
            }
            .pickerStyle(.menu)
        } header: {
            Text(L10n.Filter.evolution)
        } footer: {
            switch evolutionFilterMode {
            case .all:
                Text(L10n.Filter.evolutionAllDescription)
            case .finalOnly:
                Text(L10n.Filter.evolutionFinalDescription)
            case .evioliteOnly:
                Text(L10n.Filter.evolutionEvioliteDescription)
            }
        }
    }
}
