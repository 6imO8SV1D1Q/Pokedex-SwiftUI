//
//  PokemonFormSelectorSection.swift
//  Pokedex
//
//  Created on 2025-10-08.
//

import SwiftUI

/// ポケモンのフォーム選択セクション
struct PokemonFormSelectorSection: View {
    let forms: [PokemonForm]
    let selectedForm: PokemonForm?
    let onFormSelect: (PokemonForm) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(L10n.PokemonDetail.form)
                .font(.headline)

            Menu {
                ForEach(forms) { form in
                    Button {
                        onFormSelect(form)
                    } label: {
                        HStack {
                            Text(form.displayFormName)
                            if form.id == selectedForm?.id {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack {
                    Text(selectedForm?.displayFormName ?? "選択してください")
                    Spacer()
                    Image(systemName: "chevron.down")
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    PokemonFormSelectorSection(
        forms: [
            PokemonForm(
                id: 1,
                name: "bulbasaur",
                pokemonId: 1,
                speciesId: 1,
                formName: "normal",
                types: [PokemonType(slot: 1, name: "grass", nameJa: nil)],
                sprites: PokemonSprites(frontDefault: nil, frontShiny: nil, other: nil),
                stats: [],
                abilities: [],
                isDefault: true,
                isMega: false,
                isRegional: false,
                versionGroup: nil
            ),
            PokemonForm(
                id: 2,
                name: "bulbasaur-mega",
                pokemonId: 1,
                speciesId: 1,
                formName: "mega",
                types: [PokemonType(slot: 1, name: "grass", nameJa: nil)],
                sprites: PokemonSprites(frontDefault: nil, frontShiny: nil, other: nil),
                stats: [],
                abilities: [],
                isDefault: false,
                isMega: true,
                isRegional: false,
                versionGroup: "x-y"
            )
        ],
        selectedForm: nil,
        onFormSelect: { _ in }
    )
}
