//
//  PokemonStatsView.swift
//  Pokedex
//
//  Created on 2025-10-04.
//

import SwiftUI

struct PokemonStatsView: View {
    let stats: [PokemonStat]

    var body: some View {
        VStack(spacing: 8) {
            Text("種族値")
                .font(.headline)

            ForEach(stats, id: \.name) { stat in
                HStack {
                    Text(stat.displayName)
                        .frame(width: 80, alignment: .leading)
                        .font(.caption)

                    ProgressView(value: Double(stat.baseStat), total: 255.0)
                        .tint(.blue)

                    Text("\(stat.baseStat)")
                        .font(.caption)
                        .frame(width: 30)
                }
            }
        }
        .padding()
    }
}
