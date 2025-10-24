//
//  EvolutionChainMapper.swift
//  Pokedex
//
//  Created on 2025-10-04.
//

import Foundation
import PokemonAPI

struct EvolutionChainMapper {
    nonisolated static func map(from pkmChain: PKMEvolutionChain) -> EvolutionChain {
        EvolutionChain(
            chain: mapChainLink(from: pkmChain.chain)
        )
    }

    private nonisolated static func mapChainLink(from pkmLink: PKMChainLink?) -> EvolutionChain.ChainLink {
        guard let pkmLink = pkmLink else {
            return EvolutionChain.ChainLink(
                species: EvolutionChain.ChainLink.Species(name: "", url: ""),
                evolvesTo: []
            )
        }

        return EvolutionChain.ChainLink(
            species: EvolutionChain.ChainLink.Species(
                name: pkmLink.species?.name ?? "",
                url: pkmLink.species?.url ?? ""
            ),
            evolvesTo: pkmLink.evolvesTo?.map { mapChainLink(from: $0) } ?? []
        )
    }

    // MARK: - v3.0 EvolutionChainEntity Mapping

    /// PKMEvolutionChainからEvolutionChainEntityに変換
    nonisolated static func mapToEntity(
        from pkmChain: PKMEvolutionChain,
        pokemonCache: [Int: (name: String, nameJa: String?, imageUrl: String?, types: [String])]
    ) -> EvolutionChainEntity {
        var nodeCache: [Int: EvolutionNode] = [:]
        let rootNode = mapToEvolutionNode(from: pkmChain.chain, pokemonCache: pokemonCache, nodeCache: &nodeCache)
        return EvolutionChainEntity(
            id: pkmChain.id ?? 0,
            rootNode: rootNode,
            nodeMap: nodeCache
        )
    }

    /// PKMChainLinkからEvolutionNodeに変換（再帰的）
    private nonisolated static func mapToEvolutionNode(
        from pkmLink: PKMChainLink?,
        pokemonCache: [Int: (name: String, nameJa: String?, imageUrl: String?, types: [String])],
        nodeCache: inout [Int: EvolutionNode]
    ) -> EvolutionNode {
        guard let pkmLink = pkmLink,
              let speciesUrl = pkmLink.species?.url,
              let speciesId = extractIdFromUrl(speciesUrl) else {
            // フォールバック
            return EvolutionNode(
                id: 0,
                speciesId: 0,
                name: "Unknown",
                nameJa: nil,
                imageUrl: nil,
                types: [],
                evolvesTo: [],
                evolvesFrom: nil
            )
        }

        // キャッシュからポケモン情報を取得
        let cachedInfo = pokemonCache[speciesId]
        let name = cachedInfo?.name ?? pkmLink.species?.name ?? "Unknown"
        let nameJa = cachedInfo?.nameJa
        let imageUrl = cachedInfo?.imageUrl
        let types = cachedInfo?.types ?? []

        // 進化先のノードを再帰的に構築
        var childNodes: [EvolutionNode] = []
        for nextLink in pkmLink.evolvesTo ?? [] {
            let childNode = mapToEvolutionNode(from: nextLink, pokemonCache: pokemonCache, nodeCache: &nodeCache)
            childNodes.append(childNode)
            nodeCache[childNode.speciesId] = childNode
        }

        // 進化先をマッピング
        let evolvesTo: [EvolutionNode.EvolutionEdge] = zip(pkmLink.evolvesTo ?? [], childNodes).compactMap { (nextLink, childNode) in
            guard let evolutionDetails = nextLink.evolutionDetails?.first else {
                return nil
            }

            let trigger = mapEvolutionTrigger(from: evolutionDetails.trigger?.name)
            let conditions = mapEvolutionConditions(from: evolutionDetails)

            return EvolutionNode.EvolutionEdge(
                target: childNode.speciesId,
                trigger: trigger,
                conditions: conditions
            )
        }

        let node = EvolutionNode(
            id: speciesId,
            speciesId: speciesId,
            name: name,
            nameJa: nameJa,
            imageUrl: imageUrl,
            types: types,
            evolvesTo: evolvesTo,
            evolvesFrom: nil
        )

        nodeCache[speciesId] = node
        return node
    }

    /// 進化トリガーをマッピング
    private nonisolated static func mapEvolutionTrigger(from triggerName: String?) -> EvolutionNode.EvolutionTrigger {
        guard let triggerName = triggerName else { return .other }

        switch triggerName {
        case "level-up": return .levelUp
        case "trade": return .trade
        case "use-item": return .useItem
        case "shed": return .shed
        default: return .other
        }
    }

    /// 進化条件をマッピング
    private nonisolated static func mapEvolutionConditions(from details: PKMEvolutionDetail) -> [EvolutionNode.EvolutionCondition] {
        var conditions: [EvolutionNode.EvolutionCondition] = []

        if let minLevel = details.minLevel {
            conditions.append(EvolutionNode.EvolutionCondition(
                type: .minLevel,
                value: String(minLevel)
            ))
        }

        if let item = details.item?.name {
            conditions.append(EvolutionNode.EvolutionCondition(
                type: .item,
                value: item
            ))
        }

        if let heldItem = details.heldItem?.name {
            conditions.append(EvolutionNode.EvolutionCondition(
                type: .heldItem,
                value: heldItem
            ))
        }

        if let timeOfDay = details.timeOfDay, !timeOfDay.isEmpty {
            conditions.append(EvolutionNode.EvolutionCondition(
                type: .timeOfDay,
                value: timeOfDay
            ))
        }

        if let location = details.location?.name {
            conditions.append(EvolutionNode.EvolutionCondition(
                type: .location,
                value: location
            ))
        }

        if let minHappiness = details.minHappiness {
            conditions.append(EvolutionNode.EvolutionCondition(
                type: .minHappiness,
                value: String(minHappiness)
            ))
        }

        if let minBeauty = details.minBeauty {
            conditions.append(EvolutionNode.EvolutionCondition(
                type: .minBeauty,
                value: String(minBeauty)
            ))
        }

        if let minAffection = details.minAffection {
            conditions.append(EvolutionNode.EvolutionCondition(
                type: .minAffection,
                value: String(minAffection)
            ))
        }

        if let knownMove = details.knownMove?.name {
            conditions.append(EvolutionNode.EvolutionCondition(
                type: .knownMove,
                value: knownMove
            ))
        }

        if let knownMoveType = details.knownMoveType?.name {
            conditions.append(EvolutionNode.EvolutionCondition(
                type: .knownMoveType,
                value: knownMoveType
            ))
        }

        if let partySpecies = details.partySpecies?.name {
            conditions.append(EvolutionNode.EvolutionCondition(
                type: .partySpecies,
                value: partySpecies
            ))
        }

        if let partyType = details.partyType?.name {
            conditions.append(EvolutionNode.EvolutionCondition(
                type: .partyType,
                value: partyType
            ))
        }

        if let relativePhysicalStats = details.relativePhysicalStats {
            conditions.append(EvolutionNode.EvolutionCondition(
                type: .relativePhysicalStats,
                value: String(relativePhysicalStats)
            ))
        }

        if let tradeSpecies = details.tradeSpecies?.name {
            conditions.append(EvolutionNode.EvolutionCondition(
                type: .tradeSpecies,
                value: tradeSpecies
            ))
        }

        if let needsOverworldRain = details.needsOverworldRain, needsOverworldRain {
            conditions.append(EvolutionNode.EvolutionCondition(
                type: .needsOverworldRain,
                value: "true"
            ))
        }

        if let turnUpsideDown = details.turnUpsideDown, turnUpsideDown {
            conditions.append(EvolutionNode.EvolutionCondition(
                type: .turnUpsideDown,
                value: "true"
            ))
        }

        return conditions
    }

    /// URLからIDを抽出
    private nonisolated static func extractIdFromUrl(_ url: String) -> Int? {
        let components = url.split(separator: "/")
        guard let lastComponent = components.last else { return nil }
        return Int(lastComponent)
    }

    /// 進化チェーンから全てのspecies IDを抽出
    nonisolated static func extractAllSpeciesIds(from pkmChain: PKMEvolutionChain) -> [Int] {
        var ids: [Int] = []
        extractSpeciesIds(from: pkmChain.chain, into: &ids)
        return ids
    }

    private nonisolated static func extractSpeciesIds(from pkmLink: PKMChainLink?, into ids: inout [Int]) {
        guard let pkmLink = pkmLink,
              let speciesUrl = pkmLink.species?.url,
              let speciesId = extractIdFromUrl(speciesUrl) else {
            return
        }

        ids.append(speciesId)

        for nextLink in pkmLink.evolvesTo ?? [] {
            extractSpeciesIds(from: nextLink, into: &ids)
        }
    }
}
