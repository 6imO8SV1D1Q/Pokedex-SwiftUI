//
//  PokedexApp.swift
//  Pokedex
//
//  Created by 阿部友祐 on 2025/10/04.
//

import SwiftUI

@main
struct PokedexApp: App {
    @StateObject private var container = DIContainer.shared

    var body: some Scene {
        WindowGroup {
            PokemonListView(
                viewModel: container.makePokemonListViewModel()
            )
            .environmentObject(container)
        }
    }
}
