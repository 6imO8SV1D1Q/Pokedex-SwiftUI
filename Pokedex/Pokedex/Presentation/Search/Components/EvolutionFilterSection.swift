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
            Picker("表示する進化段階", selection: $evolutionFilterMode) {
                ForEach(EvolutionFilterMode.allCases) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(.menu)
        } header: {
            Text("進化")
        } footer: {
            switch evolutionFilterMode {
            case .all:
                Text("全ての進化段階のポケモンを表示します")
            case .finalOnly:
                Text("最終進化形のポケモンのみを表示します")
            case .evioliteOnly:
                Text("進化のきせきが使用可能なポケモン（進化前・進化途中）のみを表示します")
            }
        }
    }
}
