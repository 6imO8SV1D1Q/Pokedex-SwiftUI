//
//  VersionGroupSelectorView.swift
//  Pokedex
//
//  Created on 2025-10-05.
//

import SwiftUI

struct VersionGroupSelectorView: View {
    @ObservedObject var viewModel: PokemonListViewModel

    var body: some View {
        Menu {
            ForEach(viewModel.allVersionGroups) { versionGroup in
                Button {
                    viewModel.changeVersionGroup(versionGroup)
                } label: {
                    HStack {
                        Text(versionGroup.displayName)
                        if viewModel.selectedVersionGroup.id == versionGroup.id {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "globe")
                Text(viewModel.selectedVersionGroup.displayName)
                    .font(.subheadline)
                Image(systemName: "chevron.down")
                    .font(.caption)
            }
            .foregroundColor(.primary)
        }
    }
}
