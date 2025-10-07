//
//  PokemonLocationMapper.swift
//  Pokedex
//
//  Created on 2025-10-07.
//

import Foundation
import PokemonAPI

enum PokemonLocationMapper {
    /// PKMLocationAreaEncounterからPokemonLocationにマッピング
    nonisolated static func map(from encounters: [PKMLocationAreaEncounter]) -> [PokemonLocation] {
        // location_areaごとにグループ化
        var locationMap: [String: [PKMLocationAreaEncounter]] = [:]

        for encounter in encounters {
            guard let locationName = encounter.locationArea?.name else { continue }
            locationMap[locationName, default: []].append(encounter)
        }

        return locationMap.map { locationName, encounters in
            let versionDetails = extractVersionDetails(from: encounters)
            return PokemonLocation(
                locationName: locationName,
                versionDetails: versionDetails
            )
        }
    }

    // MARK: - Private Helpers

    nonisolated private static func extractVersionDetails(from encounters: [PKMLocationAreaEncounter]) -> [PokemonLocation.LocationVersionDetail] {
        var versionMap: [String: [Any]] = [:]

        for encounter in encounters {
            guard let versionDetails = encounter.versionDetails else { continue }

            for versionDetail in versionDetails {
                guard let versionName = versionDetail.version?.name else { continue }
                guard let encounterDetails = versionDetail.encounterDetails else { continue }

                versionMap[versionName, default: []].append(contentsOf: encounterDetails)
            }
        }

        return versionMap.map { versionName, encounterDetails in
            let details = encounterDetails.compactMap { detail -> PokemonLocation.EncounterDetail? in
                let detailObj = detail as AnyObject
                guard let minLevel = detailObj.value(forKey: "minLevel") as? Int,
                      let maxLevel = detailObj.value(forKey: "maxLevel") as? Int,
                      let chance = detailObj.value(forKey: "chance") as? Int else {
                    return nil
                }

                let method = (detailObj.value(forKey: "method") as AnyObject).value(forKey: "name") as? String ?? "unknown"

                return PokemonLocation.EncounterDetail(
                    minLevel: minLevel,
                    maxLevel: maxLevel,
                    method: method,
                    chance: chance
                )
            }

            return PokemonLocation.LocationVersionDetail(
                version: versionName,
                encounterDetails: details
            )
        }
    }
}
