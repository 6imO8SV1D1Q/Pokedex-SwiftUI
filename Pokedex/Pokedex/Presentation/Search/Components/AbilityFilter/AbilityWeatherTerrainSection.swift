//
//  AbilityWeatherTerrainSection.swift
//  Pokedex
//
//  特性の天候・フィールド条件選択セクション
//

import SwiftUI

struct AbilityWeatherTerrainSection: View {
    @Binding var selectedWeathers: Set<String>
    @Binding var selectedTerrains: Set<String>

    private let gridColumns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    private let allWeathers: [Weather] = [.sun, .rain, .sandstorm, .snow]
    private let allTerrains: [Terrain] = [.electric, .grassy, .misty, .psychic]

    var body: some View {
        Section {
            VStack(alignment: .leading, spacing: 16) {
                // 天候
                VStack(alignment: .leading, spacing: 8) {
                    Text(L10n.Weather.header)
                        .font(.subheadline)
                        .fontWeight(.semibold)

                    LazyVGrid(columns: gridColumns, spacing: 10) {
                        ForEach(allWeathers, id: \.rawValue) { weather in
                            GridButtonView(
                                text: weather.displayName,
                                isSelected: selectedWeathers.contains(weather.rawValue),
                                action: { toggleWeather(weather.rawValue) },
                                selectedColor: .cyan
                            )
                        }
                    }
                }

                Divider()
                    .padding(.vertical, 8)

                // フィールド
                VStack(alignment: .leading, spacing: 8) {
                    Text(L10n.Terrain.header)
                        .font(.subheadline)
                        .fontWeight(.semibold)

                    LazyVGrid(columns: gridColumns, spacing: 10) {
                        ForEach(allTerrains, id: \.rawValue) { terrain in
                            GridButtonView(
                                text: terrain.displayName,
                                isSelected: selectedTerrains.contains(terrain.rawValue),
                                action: { toggleTerrain(terrain.rawValue) },
                                selectedColor: .purple
                            )
                        }
                    }
                }
            }
        } header: {
            Text(L10n.Filter.weatherTerrain)
        } footer: {
            let count = selectedWeathers.count + selectedTerrains.count
            if count == 0 {
                Text(L10n.Filter.weatherTerrainDescriptionEmpty)
            } else {
                Text(L10n.Filter.weatherTerrainDescription)
            }
        }
    }

    private func toggleWeather(_ weatherId: String) {
        if selectedWeathers.contains(weatherId) {
            selectedWeathers.remove(weatherId)
        } else {
            selectedWeathers.insert(weatherId)
        }
    }

    private func toggleTerrain(_ terrainId: String) {
        if selectedTerrains.contains(terrainId) {
            selectedTerrains.remove(terrainId)
        } else {
            selectedTerrains.insert(terrainId)
        }
    }
}
