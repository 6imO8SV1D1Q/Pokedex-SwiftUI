//
//  GenerationSelectorView.swift
//  Pokedex
//
//  Created on 2025-10-05.
//

import SwiftUI

struct GenerationSelectorView: View {
    @ObservedObject var viewModel: PokemonListViewModel

    var body: some View {
        Menu {
            ForEach(viewModel.allGenerations) { generation in
                Button {
                    viewModel.changeGeneration(generation)
                } label: {
                    HStack {
                        Text(generation.displayName)
                        if viewModel.selectedGeneration.id == generation.id {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "globe")
                Text(viewModel.selectedGeneration.displayName)
                    .font(.subheadline)
                Image(systemName: "chevron.down")
                    .font(.caption)
            }
            .foregroundColor(.primary)
        }
    }
}
