//
//  PokemonStatsView.swift
//  Pokedex
//
//  Created on 2025-10-04.
//

import SwiftUI

struct PokemonStatsView: View {
    let stats: [PokemonStat]

    private var totalStats: Int {
        stats.reduce(0) { $0 + $1.baseStat }
    }

    var body: some View {
        VStack(spacing: 8) {
            ForEach(stats, id: \.name) { stat in
                HStack {
                    Text(FilterHelpers.statName(stat.name))
                        .frame(width: 80, alignment: .leading)
                        .font(.subheadline)

                    ProgressView(value: Double(stat.baseStat), total: 255.0)
                        .tint(.blue)

                    Text("\(stat.baseStat)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .frame(width: 40, alignment: .trailing)
                }
            }

            Divider()
                .padding(.vertical, 4)

            HStack {
                Text(L10n.PokemonDetail.totalStats)
                    .frame(width: 80, alignment: .leading)
                    .font(.subheadline)
                    .fontWeight(.bold)

                Spacer()

                Text("\(totalStats)")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(width: 40, alignment: .trailing)
            }
        }
        .padding()
    }
}
