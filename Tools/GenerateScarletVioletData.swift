#!/usr/bin/env swift

import Foundation

print("🚀 Scarlet/Violet Database Generator")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

// MARK: - Data Structures

struct GameData: Codable {
    let dataVersion: String
    let lastUpdated: String
    let versionGroup: String
    let versionGroupId: Int
    let generation: Int
    var pokemon: [PokemonData]
    var moves: [MoveData]
    var abilities: [AbilityData]
}

struct PokemonData: Codable {
    let id: Int
    let nationalDexNumber: Int
    let name: String
    let nameJa: String
    let genus: String
    let genusJa: String
    let sprites: SpriteData
    let types: [String]
    let abilities: AbilitySet
    let baseStats: BaseStats
    let moves: [LearnedMove]
    let eggGroups: [String]
    let genderRate: Int
    let height: Int
    let weight: Int
    let evolutionChain: EvolutionInfo
    let varieties: [Int]
    let pokedexNumbers: [String: Int]
    let category: String

    struct SpriteData: Codable {
        let normal: String
        let shiny: String
    }

    struct AbilitySet: Codable {
        let primary: [Int]
        let hidden: Int?
    }

    struct BaseStats: Codable {
        let hp: Int
        let attack: Int
        let defense: Int
        let spAttack: Int
        let spDefense: Int
        let speed: Int
        let total: Int
    }

    struct LearnedMove: Codable {
        let moveId: Int
        let learnMethod: String
        let level: Int?
        let machineNumber: String?
    }

    struct EvolutionInfo: Codable {
        let chainId: Int
        let evolutionStage: Int
        let evolvesFrom: Int?
        let evolvesTo: [Int]
        let canUseEviolite: Bool
    }
}

struct MoveData: Codable {
    let id: Int
    let name: String
    let nameJa: String
    let type: String
    let damageClass: String
    let power: Int?
    let accuracy: Int?
    let pp: Int
    let priority: Int
    let effectChance: Int?
    let effect: String
    let effectJa: String
    let meta: MoveMeta

    struct MoveMeta: Codable {
        let ailment: String
        let ailmentChance: Int
        let category: String
        let critRate: Int
        let drain: Int
        let flinchChance: Int
        let healing: Int
        let statChance: Int
        let statChanges: [StatChange]

        struct StatChange: Codable {
            let stat: String
            let change: Int
        }
    }
}

struct AbilityData: Codable {
    let id: Int
    let name: String
    let nameJa: String
    let effect: String
    let effectJa: String
}

// MARK: - Configuration

let VERSION_GROUP = "scarlet-violet"
let VERSION_GROUP_ID = 25
let GENERATION = 9
let OUTPUT_DIR = "/Users/yusuke/Development/Pokedex-SwiftUI/Pokedex/Pokedex/Resources/PreloadedData"
let TOTAL_POKEMON_SPECIES = 1025  // 全ポケモン種族数
let TOTAL_POKEMON_FORMS = 1302  // 全ポケモン数（フォーム含む）

// MARK: - Global Cache

// Cache for machine numbers (moveId -> "TM126")
var globalMachineNumbers: [Int: String] = [:]

// MARK: - Helper Functions

func fetchJSON(from urlString: String) async throws -> [String: Any] {
    let url = URL(string: urlString)!
    let (data, _) = try await URLSession.shared.data(from: url)
    return try JSONSerialization.jsonObject(with: data) as! [String: Any]
}

func delay() async {
    try? await Task.sleep(nanoseconds: 100_000_000) // 100ms
}

// MARK: - Pokedex Data

func fetchPokedexData() async throws -> [String: Set<Int>] {
    var pokedexData: [String: Set<Int>] = [:]
    let pokedexes = [
        (id: 31, name: "paldea"),
        (id: 32, name: "kitakami"),
        (id: 33, name: "blueberry")
    ]

    for pokedex in pokedexes {
        print("📚 Fetching \(pokedex.name) Pokedex...")

        let json = try await fetchJSON(from: "https://pokeapi.co/api/v2/pokedex/\(pokedex.id)")

        guard let entries = json["pokemon_entries"] as? [[String: Any]] else {
            pokedexData[pokedex.name] = Set<Int>()
            continue
        }

        var speciesIds = Set<Int>()
        for entry in entries {
            guard let species = entry["pokemon_species"] as? [String: Any],
                  let url = species["url"] as? String,
                  let idStr = url.split(separator: "/").last,
                  let speciesId = Int(idStr) else {
                continue
            }
            speciesIds.insert(speciesId)
        }

        pokedexData[pokedex.name] = speciesIds
        print("  ✅ \(speciesIds.count) Pokemon in \(pokedex.name)")
        await delay()
    }

    return pokedexData
}

func getPokedexNumbers(from speciesJson: [String: Any]) -> [String: Int] {
    var pokedexNumbers: [String: Int] = [:]

    guard let pokedexNumbersArray = speciesJson["pokedex_numbers"] as? [[String: Any]] else {
        return pokedexNumbers
    }

    for entry in pokedexNumbersArray {
        guard let pokedex = entry["pokedex"] as? [String: Any],
              let pokedexName = pokedex["name"] as? String,
              let entryNumber = entry["entry_number"] as? Int else {
            continue
        }

        // Filter to only include our target pokedexes
        if ["paldea", "kitakami", "blueberry"].contains(pokedexName) {
            pokedexNumbers[pokedexName] = entryNumber
        }
    }

    return pokedexNumbers
}

// Fetch all Pokemon IDs (including forms)
func fetchAllPokemonIds() async throws -> [Int] {
    print("🔍 Fetching complete Pokemon list (including all forms)...")

    // Fetch the complete list with limit=10000 to ensure we get everything
    let json = try await fetchJSON(from: "https://pokeapi.co/api/v2/pokemon?limit=10000")

    guard let results = json["results"] as? [[String: Any]] else {
        return []
    }

    var pokemonIds: [Int] = []
    for result in results {
        guard let url = result["url"] as? String,
              let idStr = url.split(separator: "/").last,
              let id = Int(idStr) else {
            continue
        }
        pokemonIds.append(id)
    }

    print("  ✅ Found \(pokemonIds.count) Pokemon (including all forms)")
    return pokemonIds.sorted()
}

// MARK: - Evolution Chain

struct EvolutionChainData {
    let chainId: Int
    let evolutionStage: Int
    let evolvesFrom: Int?
    let evolvesTo: [Int]
}

func fetchEvolutionChain(evolutionChainUrl: String, targetSpeciesId: Int) async throws -> EvolutionChainData {
    let json = try await fetchJSON(from: evolutionChainUrl)

    guard let chainId = json["id"] as? Int,
          let chain = json["chain"] as? [String: Any] else {
        return EvolutionChainData(chainId: 0, evolutionStage: 1, evolvesFrom: nil, evolvesTo: [])
    }

    // Recursively search for the target species
    func findInChain(_ node: [String: Any], stage: Int, parent: Int?) -> EvolutionChainData? {
        guard let speciesInfo = node["species"] as? [String: Any],
              let speciesUrl = speciesInfo["url"] as? String,
              let speciesIdStr = speciesUrl.split(separator: "/").last,
              let speciesId = Int(speciesIdStr) else {
            return nil
        }

        let evolvesToArray = node["evolves_to"] as? [[String: Any]] ?? []
        let evolvesToIds = evolvesToArray.compactMap { evo -> Int? in
            guard let species = evo["species"] as? [String: Any],
                  let url = species["url"] as? String,
                  let idStr = url.split(separator: "/").last else {
                return nil
            }
            return Int(idStr)
        }

        if speciesId == targetSpeciesId {
            return EvolutionChainData(
                chainId: chainId,
                evolutionStage: stage,
                evolvesFrom: parent,
                evolvesTo: evolvesToIds
            )
        }

        // Search in children
        for evolveNode in evolvesToArray {
            if let result = findInChain(evolveNode, stage: stage + 1, parent: speciesId) {
                return result
            }
        }

        return nil
    }

    if let result = findInChain(chain, stage: 1, parent: nil) {
        return result
    }

    return EvolutionChainData(chainId: chainId, evolutionStage: 1, evolvesFrom: nil, evolvesTo: [])
}

// MARK: - Category Detection

func determineCategory(isLegendary: Bool, isMythical: Bool, baseStatsTotal: Int) -> String {
    if isMythical {
        return "mythical"
    }
    if isLegendary {
        return "legendary"
    }
    if baseStatsTotal >= 600 {
        return "subLegendary"
    }
    return "normal"
}

// MARK: - Pokemon Fetching

func checkPokemonHasScarletVioletMoves(pokemonId: Int) async throws -> Bool {
    let json = try await fetchJSON(from: "https://pokeapi.co/api/v2/pokemon/\(pokemonId)")

    guard let moves = json["moves"] as? [[String: Any]] else {
        return false
    }

    // Check if any move has scarlet-violet version group
    for moveEntry in moves {
        guard let versionDetails = moveEntry["version_group_details"] as? [[String: Any]] else {
            continue
        }

        for versionDetail in versionDetails {
            guard let versionGroup = versionDetail["version_group"] as? [String: Any],
                  let versionName = versionGroup["name"] as? String else {
                continue
            }

            if versionName == VERSION_GROUP {
                return true
            }
        }
    }

    return false
}

func fetchPokemonData(speciesId: Int, pokedexData: [String: Set<Int>]) async throws -> PokemonData? {
    print("  Fetching Pokemon #\(speciesId)...")

    // Fetch pokemon-species
    let speciesJson = try await fetchJSON(from: "https://pokeapi.co/api/v2/pokemon-species/\(speciesId)")
    await delay()

    // Get default variety
    guard let varieties = speciesJson["varieties"] as? [[String: Any]],
          let defaultVariety = varieties.first(where: { ($0["is_default"] as? Bool) == true }),
          let pokemonUrl = (defaultVariety["pokemon"] as? [String: Any])?["url"] as? String,
          let pokemonIdStr = pokemonUrl.split(separator: "/").last,
          let pokemonId = Int(pokemonIdStr) else {
        return nil
    }

    // Fetch pokemon data
    let pokemonJson = try await fetchJSON(from: "https://pokeapi.co/api/v2/pokemon/\(pokemonId)")
    await delay()

    // Extract names
    let names = speciesJson["names"] as? [[String: Any]] ?? []
    let nameJa = names.first(where: { ($0["language"] as? [String: Any])?["name"] as? String == "ja" })?["name"] as? String ?? ""
    let name = speciesJson["name"] as? String ?? ""

    // Extract genus
    let genera = speciesJson["genera"] as? [[String: Any]] ?? []
    let genusJa = genera.first(where: {
        let langName = ($0["language"] as? [String: Any])?["name"] as? String
        return langName == "ja" || langName == "ja-Hrkt"
    })?["genus"] as? String ?? ""
    let genusEn = genera.first(where: { ($0["language"] as? [String: Any])?["name"] as? String == "en" })?["genus"] as? String ?? ""

    // Sprites
    let sprites = PokemonData.SpriteData(
        normal: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/home/\(pokemonId).png",
        shiny: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/home/shiny/\(pokemonId).png"
    )

    // Types
    let typesArray = pokemonJson["types"] as? [[String: Any]] ?? []
    let types = typesArray.map { ($0["type"] as? [String: Any])?["name"] as? String ?? "" }

    // Abilities
    let abilitiesArray = pokemonJson["abilities"] as? [[String: Any]] ?? []
    var primaryAbilities: [Int] = []
    var hiddenAbility: Int? = nil

    for abilityEntry in abilitiesArray {
        guard let abilityInfo = abilityEntry["ability"] as? [String: Any],
              let abilityUrl = abilityInfo["url"] as? String,
              let abilityIdStr = abilityUrl.split(separator: "/").last,
              let abilityId = Int(abilityIdStr) else {
            continue
        }

        let isHidden = abilityEntry["is_hidden"] as? Bool ?? false
        if isHidden {
            hiddenAbility = abilityId
        } else {
            primaryAbilities.append(abilityId)
        }
    }

    let abilities = PokemonData.AbilitySet(primary: primaryAbilities, hidden: hiddenAbility)

    // Base Stats
    let statsArray = pokemonJson["stats"] as? [[String: Any]] ?? []
    var hp = 0, attack = 0, defense = 0, spAttack = 0, spDefense = 0, speed = 0

    for statEntry in statsArray {
        let baseStat = statEntry["base_stat"] as? Int ?? 0
        let statName = (statEntry["stat"] as? [String: Any])?["name"] as? String ?? ""

        switch statName {
        case "hp": hp = baseStat
        case "attack": attack = baseStat
        case "defense": defense = baseStat
        case "special-attack": spAttack = baseStat
        case "special-defense": spDefense = baseStat
        case "speed": speed = baseStat
        default: break
        }
    }

    let baseStats = PokemonData.BaseStats(
        hp: hp,
        attack: attack,
        defense: defense,
        spAttack: spAttack,
        spDefense: spDefense,
        speed: speed,
        total: hp + attack + defense + spAttack + spDefense + speed
    )

    // Moves (scarlet-violet only)
    let movesArray = pokemonJson["moves"] as? [[String: Any]] ?? []
    var learnedMoves: [PokemonData.LearnedMove] = []

    for moveEntry in movesArray {
        guard let moveInfo = moveEntry["move"] as? [String: Any],
              let moveUrl = moveInfo["url"] as? String,
              let moveIdStr = moveUrl.split(separator: "/").last,
              let moveId = Int(moveIdStr),
              let versionDetails = moveEntry["version_group_details"] as? [[String: Any]] else {
            continue
        }

        // Filter by scarlet-violet
        for detail in versionDetails {
            guard let versionGroup = detail["version_group"] as? [String: Any],
                  let vgName = versionGroup["name"] as? String,
                  vgName == VERSION_GROUP else {
                continue
            }

            let learnMethod = (detail["move_learn_method"] as? [String: Any])?["name"] as? String ?? ""
            let level = detail["level_learned_at"] as? Int

            let move = PokemonData.LearnedMove(
                moveId: moveId,
                learnMethod: learnMethod,
                level: level == 0 ? nil : level,
                machineNumber: nil  // TODO: Get machine number
            )
            learnedMoves.append(move)
            break
        }
    }

    // Egg Groups
    let eggGroupsArray = speciesJson["egg_groups"] as? [[String: Any]] ?? []
    let eggGroups = eggGroupsArray.map { ($0["name"] as? String) ?? "" }

    // Gender Rate
    let genderRate = speciesJson["gender_rate"] as? Int ?? -1

    // Height & Weight
    let height = pokemonJson["height"] as? Int ?? 0
    let weight = pokemonJson["weight"] as? Int ?? 0

    // Evolution Chain
    var evolutionChain = PokemonData.EvolutionInfo(
        chainId: 0,
        evolutionStage: 1,
        evolvesFrom: nil,
        evolvesTo: [],
        canUseEviolite: false
    )

    if let evolutionChainInfo = speciesJson["evolution_chain"] as? [String: Any],
       let evolutionChainUrl = evolutionChainInfo["url"] as? String {
        do {
            let chainData = try await fetchEvolutionChain(evolutionChainUrl: evolutionChainUrl, targetSpeciesId: speciesId)
            evolutionChain = PokemonData.EvolutionInfo(
                chainId: chainData.chainId,
                evolutionStage: chainData.evolutionStage,
                evolvesFrom: chainData.evolvesFrom,
                evolvesTo: chainData.evolvesTo,
                canUseEviolite: !chainData.evolvesTo.isEmpty
            )
            await delay()
        } catch {
            // Use default values on error
        }
    }

    // Varieties
    let varietyIds = varieties.compactMap { variety -> Int? in
        guard let pokemonInfo = variety["pokemon"] as? [String: Any],
              let url = pokemonInfo["url"] as? String,
              let idStr = url.split(separator: "/").last else {
            return nil
        }
        return Int(idStr)
    }

    // Pokedex Numbers
    let pokedexNumbers = getPokedexNumbers(from: speciesJson)

    // Category
    let isLegendary = speciesJson["is_legendary"] as? Bool ?? false
    let isMythical = speciesJson["is_mythical"] as? Bool ?? false
    let category = determineCategory(isLegendary: isLegendary, isMythical: isMythical, baseStatsTotal: baseStats.total)

    return PokemonData(
        id: pokemonId,
        nationalDexNumber: speciesId,
        name: name,
        nameJa: nameJa,
        genus: genusEn,
        genusJa: genusJa,
        sprites: sprites,
        types: types,
        abilities: abilities,
        baseStats: baseStats,
        moves: learnedMoves,
        eggGroups: eggGroups,
        genderRate: genderRate,
        height: height,
        weight: weight,
        evolutionChain: evolutionChain,
        varieties: varietyIds,
        pokedexNumbers: pokedexNumbers,
        category: category
    )
}

// Fetch Pokemon data directly from Pokemon ID (for forms)
func fetchPokemonDataByPokemonId(pokemonId: Int, pokedexData: [String: Set<Int>]) async throws -> PokemonData? {
    print("  Fetching Pokemon (ID: \(pokemonId))...")

    // Fetch pokemon data first
    let pokemonJson = try await fetchJSON(from: "https://pokeapi.co/api/v2/pokemon/\(pokemonId)")
    await delay()

    // Get species ID from pokemon data
    guard let speciesInfo = pokemonJson["species"] as? [String: Any],
          let speciesUrl = speciesInfo["url"] as? String,
          let speciesIdStr = speciesUrl.split(separator: "/").last,
          let speciesId = Int(speciesIdStr) else {
        return nil
    }

    // Fetch pokemon-species for names, genus, etc.
    let speciesJson = try await fetchJSON(from: "https://pokeapi.co/api/v2/pokemon-species/\(speciesId)")
    await delay()

    // Extract names
    let names = speciesJson["names"] as? [[String: Any]] ?? []
    let nameJa = names.first(where: { ($0["language"] as? [String: Any])?["name"] as? String == "ja" })?["name"] as? String ?? ""
    let name = pokemonJson["name"] as? String ?? ""

    // Extract genus
    let genera = speciesJson["genera"] as? [[String: Any]] ?? []
    let genusJa = genera.first(where: {
        let langName = ($0["language"] as? [String: Any])?["name"] as? String
        return langName == "ja" || langName == "ja-Hrkt"
    })?["genus"] as? String ?? ""
    let genusEn = genera.first(where: { ($0["language"] as? [String: Any])?["name"] as? String == "en" })?["genus"] as? String ?? ""

    // Sprites
    let sprites = PokemonData.SpriteData(
        normal: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/home/\(pokemonId).png",
        shiny: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/home/shiny/\(pokemonId).png"
    )

    // Types
    let typesArray = pokemonJson["types"] as? [[String: Any]] ?? []
    let types = typesArray.map { ($0["type"] as? [String: Any])?["name"] as? String ?? "" }

    // Abilities
    let abilitiesArray = pokemonJson["abilities"] as? [[String: Any]] ?? []
    var primaryAbilities: [Int] = []
    var hiddenAbility: Int? = nil

    for abilityEntry in abilitiesArray {
        guard let abilityInfo = abilityEntry["ability"] as? [String: Any],
              let abilityUrl = abilityInfo["url"] as? String,
              let abilityIdStr = abilityUrl.split(separator: "/").last,
              let abilityId = Int(abilityIdStr) else {
            continue
        }

        let isHidden = abilityEntry["is_hidden"] as? Bool ?? false
        if isHidden {
            hiddenAbility = abilityId
        } else {
            primaryAbilities.append(abilityId)
        }
    }

    let abilities = PokemonData.AbilitySet(primary: primaryAbilities, hidden: hiddenAbility)

    // Base Stats
    let statsArray = pokemonJson["stats"] as? [[String: Any]] ?? []
    var hp = 0, attack = 0, defense = 0, spAttack = 0, spDefense = 0, speed = 0

    for statEntry in statsArray {
        let baseStat = statEntry["base_stat"] as? Int ?? 0
        let statName = (statEntry["stat"] as? [String: Any])?["name"] as? String ?? ""

        switch statName {
        case "hp": hp = baseStat
        case "attack": attack = baseStat
        case "defense": defense = baseStat
        case "special-attack": spAttack = baseStat
        case "special-defense": spDefense = baseStat
        case "speed": speed = baseStat
        default: break
        }
    }

    let baseStats = PokemonData.BaseStats(
        hp: hp,
        attack: attack,
        defense: defense,
        spAttack: spAttack,
        spDefense: spDefense,
        speed: speed,
        total: hp + attack + defense + spAttack + spDefense + speed
    )

    // Moves (scarlet-violet only)
    let movesArray = pokemonJson["moves"] as? [[String: Any]] ?? []
    var learnedMoves: [PokemonData.LearnedMove] = []

    for moveEntry in movesArray {
        guard let moveInfo = moveEntry["move"] as? [String: Any],
              let moveUrl = moveInfo["url"] as? String,
              let moveIdStr = moveUrl.split(separator: "/").last,
              let moveId = Int(moveIdStr),
              let versionDetails = moveEntry["version_group_details"] as? [[String: Any]] else {
            continue
        }

        // Filter by scarlet-violet - collect ALL learn methods
        for detail in versionDetails {
            guard let versionGroup = detail["version_group"] as? [String: Any],
                  let vgName = versionGroup["name"] as? String,
                  vgName == VERSION_GROUP else {
                continue
            }

            let learnMethod = (detail["move_learn_method"] as? [String: Any])?["name"] as? String ?? ""
            let level = detail["level_learned_at"] as? Int

            // Get machine number from global cache if this is a machine move
            var machineNumber: String? = nil
            if learnMethod == "machine", let tmNumber = globalMachineNumbers[moveId] {
                machineNumber = tmNumber
            }

            let move = PokemonData.LearnedMove(
                moveId: moveId,
                learnMethod: learnMethod,
                level: level == 0 ? nil : level,
                machineNumber: machineNumber
            )
            learnedMoves.append(move)
            // NOTE: Do NOT break here - we want ALL learn methods
        }
    }

    // Egg Groups
    let eggGroupsArray = speciesJson["egg_groups"] as? [[String: Any]] ?? []
    let eggGroups = eggGroupsArray.map { ($0["name"] as? String) ?? "" }

    // Gender Rate
    let genderRate = speciesJson["gender_rate"] as? Int ?? -1

    // Height & Weight
    let height = pokemonJson["height"] as? Int ?? 0
    let weight = pokemonJson["weight"] as? Int ?? 0

    // Evolution Chain
    var evolutionChain = PokemonData.EvolutionInfo(
        chainId: 0,
        evolutionStage: 1,
        evolvesFrom: nil,
        evolvesTo: [],
        canUseEviolite: false
    )

    if let evolutionChainInfo = speciesJson["evolution_chain"] as? [String: Any],
       let evolutionChainUrl = evolutionChainInfo["url"] as? String {
        do {
            let chainData = try await fetchEvolutionChain(evolutionChainUrl: evolutionChainUrl, targetSpeciesId: speciesId)
            evolutionChain = PokemonData.EvolutionInfo(
                chainId: chainData.chainId,
                evolutionStage: chainData.evolutionStage,
                evolvesFrom: chainData.evolvesFrom,
                evolvesTo: chainData.evolvesTo,
                canUseEviolite: !chainData.evolvesTo.isEmpty
            )
            await delay()
        } catch {
            // Use default values on error
        }
    }

    // Varieties
    let varieties = speciesJson["varieties"] as? [[String: Any]] ?? []
    let varietyIds = varieties.compactMap { variety -> Int? in
        guard let pokemonInfo = variety["pokemon"] as? [String: Any],
              let url = pokemonInfo["url"] as? String,
              let idStr = url.split(separator: "/").last else {
            return nil
        }
        return Int(idStr)
    }

    // Pokedex Numbers
    let pokedexNumbers = getPokedexNumbers(from: speciesJson)

    // Category
    let isLegendary = speciesJson["is_legendary"] as? Bool ?? false
    let isMythical = speciesJson["is_mythical"] as? Bool ?? false
    let category = determineCategory(isLegendary: isLegendary, isMythical: isMythical, baseStatsTotal: baseStats.total)

    return PokemonData(
        id: pokemonId,
        nationalDexNumber: speciesId,
        name: name,
        nameJa: nameJa,
        genus: genusEn,
        genusJa: genusJa,
        sprites: sprites,
        types: types,
        abilities: abilities,
        baseStats: baseStats,
        moves: learnedMoves,
        eggGroups: eggGroups,
        genderRate: genderRate,
        height: height,
        weight: weight,
        evolutionChain: evolutionChain,
        varieties: varietyIds,
        pokedexNumbers: pokedexNumbers,
        category: category
    )
}

// MARK: - Move Fetching

func fetchMoveData(moveId: Int) async throws -> MoveData? {
    let json = try await fetchJSON(from: "https://pokeapi.co/api/v2/move/\(moveId)")
    await delay()

    // Names
    let names = json["names"] as? [[String: Any]] ?? []
    let nameJa = names.first(where: { ($0["language"] as? [String: Any])?["name"] as? String == "ja" })?["name"] as? String ?? ""
    let name = json["name"] as? String ?? ""

    // Type
    let type = (json["type"] as? [String: Any])?["name"] as? String ?? ""

    // Damage Class
    let damageClass = (json["damage_class"] as? [String: Any])?["name"] as? String ?? ""

    // Stats
    let power = json["power"] as? Int
    let accuracy = json["accuracy"] as? Int
    let pp = json["pp"] as? Int ?? 0
    let priority = json["priority"] as? Int ?? 0
    let effectChance = json["effect_chance"] as? Int

    // Effect
    let effectEntries = json["effect_entries"] as? [[String: Any]] ?? []
    let effectEn = effectEntries.first(where: { ($0["language"] as? [String: Any])?["name"] as? String == "en" })?["effect"] as? String ?? ""
    let effectJa = translateEffect(effectEn)  // AI translation

    // Meta
    let metaJson = json["meta"] as? [String: Any] ?? [:]
    let ailment = (metaJson["ailment"] as? [String: Any])?["name"] as? String ?? "none"
    let ailmentChance = metaJson["ailment_chance"] as? Int ?? 0
    let category = (metaJson["category"] as? [String: Any])?["name"] as? String ?? ""
    let critRate = metaJson["crit_rate"] as? Int ?? 0
    let drain = metaJson["drain"] as? Int ?? 0
    let flinchChance = metaJson["flinch_chance"] as? Int ?? 0
    let healing = metaJson["healing"] as? Int ?? 0
    let statChance = metaJson["stat_chance"] as? Int ?? 0

    // Stat Changes
    let statChangesArray = metaJson["stat_changes"] as? [[String: Any]] ?? []
    let statChanges = statChangesArray.map { entry -> MoveData.MoveMeta.StatChange in
        let stat = (entry["stat"] as? [String: Any])?["name"] as? String ?? ""
        let change = entry["change"] as? Int ?? 0
        return MoveData.MoveMeta.StatChange(stat: stat, change: change)
    }

    let meta = MoveData.MoveMeta(
        ailment: ailment,
        ailmentChance: ailmentChance,
        category: category,
        critRate: critRate,
        drain: drain,
        flinchChance: flinchChance,
        healing: healing,
        statChance: statChance,
        statChanges: statChanges
    )

    // Machine Number - check if this move is a TM in scarlet-violet
    let machinesArray = json["machines"] as? [[String: Any]] ?? []
    for machineEntry in machinesArray {
        guard let versionGroup = machineEntry["version_group"] as? [String: Any],
              let vgName = versionGroup["name"] as? String,
              vgName == VERSION_GROUP else {
            continue
        }

        // Get machine ID
        guard let machine = machineEntry["machine"] as? [String: Any],
              let machineUrl = machine["url"] as? String,
              let machineIdStr = machineUrl.split(separator: "/").last,
              let machineId = Int(machineIdStr) else {
            continue
        }

        // Fetch machine details to get TM number
        do {
            let machineJson = try await fetchJSON(from: "https://pokeapi.co/api/v2/machine/\(machineId)")
            await delay()

            if let item = machineJson["item"] as? [String: Any],
               let itemName = item["name"] as? String {
                // itemName is like "tm001" or "tm126"
                let machineNumber = itemName.uppercased()  // "TM001" or "TM126"
                globalMachineNumbers[moveId] = machineNumber
            }
        } catch {
            // Continue if machine fetch fails
        }

        break  // Only need one machine entry for this version group
    }

    return MoveData(
        id: moveId,
        name: name,
        nameJa: nameJa,
        type: type,
        damageClass: damageClass,
        power: power,
        accuracy: accuracy,
        pp: pp,
        priority: priority,
        effectChance: effectChance,
        effect: effectEn,
        effectJa: effectJa,
        meta: meta
    )
}

func translateEffect(_ effect: String) -> String {
    // Simple translation mapping for common patterns
    var translated = effect

    // Replace common phrases
    translated = translated.replacingOccurrences(of: "Inflicts regular damage", with: "通常のダメージを与える")
    translated = translated.replacingOccurrences(of: "Has a", with: "")
    translated = translated.replacingOccurrences(of: "chance to", with: "の確率で")
    translated = translated.replacingOccurrences(of: "paralyze the target", with: "相手をまひ状態にする")
    translated = translated.replacingOccurrences(of: "the target", with: "相手")
    translated = translated.replacingOccurrences(of: "Never misses", with: "必ず命中する")
    translated = translated.replacingOccurrences(of: "user", with: "使用者")

    // Remove percentage signs and convert
    translated = translated.replacingOccurrences(of: "%", with: "%")

    return translated.trimmingCharacters(in: .whitespacesAndNewlines)
}

// MARK: - Ability Fetching

func fetchAbilityData(abilityId: Int) async throws -> AbilityData? {
    let json = try await fetchJSON(from: "https://pokeapi.co/api/v2/ability/\(abilityId)")
    await delay()

    // Names
    let names = json["names"] as? [[String: Any]] ?? []
    let nameJa = names.first(where: { ($0["language"] as? [String: Any])?["name"] as? String == "ja" })?["name"] as? String ?? ""
    let name = json["name"] as? String ?? ""

    // Effect
    let effectEntries = json["effect_entries"] as? [[String: Any]] ?? []
    let effectEn = effectEntries.first(where: { ($0["language"] as? [String: Any])?["name"] as? String == "en" })?["effect"] as? String ?? ""
    let effectJa = translateAbilityEffect(effectEn)

    return AbilityData(
        id: abilityId,
        name: name,
        nameJa: nameJa,
        effect: effectEn,
        effectJa: effectJa
    )
}

func translateAbilityEffect(_ effect: String) -> String {
    // Simple translation for abilities
    var translated = effect

    translated = translated.replacingOccurrences(of: "Whenever a move makes contact with this Pokémon", with: "接触技を受けたとき")
    translated = translated.replacingOccurrences(of: "the move's user has a", with: "")
    translated = translated.replacingOccurrences(of: "chance of being paralyzed", with: "の確率で相手をまひ状態にする")
    translated = translated.replacingOccurrences(of: "This Pokémon", with: "このポケモン")
    translated = translated.replacingOccurrences(of: "Raises", with: "上げる")
    translated = translated.replacingOccurrences(of: "Lowers", with: "下げる")

    return translated.trimmingCharacters(in: .whitespacesAndNewlines)
}

// MARK: - Main Process

Task {
    do {
        print("📊 Step 1: Fetching Pokedex data...")
        let pokedexData = try await fetchPokedexData()

        print("")
        print("📊 Step 2: Checking species availability in Scarlet/Violet...")
        var availableSpeciesIds: [Int] = []

        // Check species 1-1025
        for speciesId in 1...TOTAL_POKEMON_SPECIES {
            if speciesId % 50 == 0 {
                print("  Checked \(speciesId)/\(TOTAL_POKEMON_SPECIES) species... Found: \(availableSpeciesIds.count)")
            }

            do {
                if try await checkPokemonHasScarletVioletMoves(pokemonId: speciesId) {
                    availableSpeciesIds.append(speciesId)
                }
                await delay()
            } catch {
                continue
            }
        }

        print("✅ Found \(availableSpeciesIds.count) species available in Scarlet/Violet")

        print("")
        print("📊 Step 3: Fetching varieties for each species...")
        var allPokemonIds: [Int] = []

        for (index, speciesId) in availableSpeciesIds.enumerated() {
            if (index + 1) % 100 == 0 {
                print("  Processed \(index + 1)/\(availableSpeciesIds.count) species... Total Pokemon: \(allPokemonIds.count)")
            }

            do {
                // Fetch species to get varieties
                let speciesJson = try await fetchJSON(from: "https://pokeapi.co/api/v2/pokemon-species/\(speciesId)")
                await delay()

                guard let varieties = speciesJson["varieties"] as? [[String: Any]] else {
                    continue
                }

                // Check each variety for SV moves
                for variety in varieties {
                    guard let pokemonInfo = variety["pokemon"] as? [String: Any],
                          let url = pokemonInfo["url"] as? String,
                          let idStr = url.split(separator: "/").last,
                          let pokemonId = Int(idStr) else {
                        continue
                    }

                    do {
                        if try await checkPokemonHasScarletVioletMoves(pokemonId: pokemonId) {
                            allPokemonIds.append(pokemonId)
                        }
                        await delay()
                    } catch {
                        continue
                    }
                }
            } catch {
                continue
            }
        }

        print("✅ Found \(allPokemonIds.count) Pokemon (including forms) available in Scarlet/Violet")

        print("")
        print("📊 Step 4: Fetching Pokemon Data...")
        var allPokemon: [PokemonData] = []

        for (index, pokemonId) in allPokemonIds.enumerated() {
            if let pokemon = try await fetchPokemonDataByPokemonId(pokemonId: pokemonId, pokedexData: pokedexData) {
                allPokemon.append(pokemon)
                print("✅ [\(index + 1)/\(allPokemonIds.count)] \(pokemon.nameJa) - \(pokemon.moves.count) moves")
            }
            await delay()
        }

        print("")
        print("📊 Step 5: Collecting unique moves and abilities...")

        // Collect unique move IDs
        var uniqueMoveIds = Set<Int>()
        for pokemon in allPokemon {
            for move in pokemon.moves {
                uniqueMoveIds.insert(move.moveId)
            }
        }
        print("  Found \(uniqueMoveIds.count) unique moves")

        // Collect unique ability IDs
        var uniqueAbilityIds = Set<Int>()
        for pokemon in allPokemon {
            uniqueAbilityIds.formUnion(pokemon.abilities.primary)
            if let hidden = pokemon.abilities.hidden {
                uniqueAbilityIds.insert(hidden)
            }
        }
        print("  Found \(uniqueAbilityIds.count) unique abilities")

        print("")
        print("📊 Step 6: Fetching move data...")
        var allMoves: [MoveData] = []

        for (index, moveId) in uniqueMoveIds.sorted().enumerated() {
            if let move = try await fetchMoveData(moveId: moveId) {
                allMoves.append(move)
                if (index + 1) % 10 == 0 || index == uniqueMoveIds.count - 1 {
                    print("  [\(index + 1)/\(uniqueMoveIds.count)] moves fetched")
                }
            }
            await delay()
        }

        print("")
        print("📊 Step 7: Fetching ability data...")
        var allAbilities: [AbilityData] = []

        for (index, abilityId) in uniqueAbilityIds.sorted().enumerated() {
            if let ability = try await fetchAbilityData(abilityId: abilityId) {
                allAbilities.append(ability)
            }
            if (index + 1) % 10 == 0 || index + 1 == uniqueAbilityIds.count {
                print("  [\(index + 1)/\(uniqueAbilityIds.count)] abilities fetched")
            }
            await delay()
        }

        print("")
        print("📊 Step 8: Writing JSON...")

        let gameData = GameData(
            dataVersion: "1.0.0",
            lastUpdated: ISO8601DateFormatter().string(from: Date()).prefix(10).description,
            versionGroup: VERSION_GROUP,
            versionGroupId: VERSION_GROUP_ID,
            generation: GENERATION,
            pokemon: allPokemon,
            moves: allMoves,
            abilities: allAbilities
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let jsonData = try encoder.encode(gameData)

        let outputPath = "\(OUTPUT_DIR)/scarlet_violet.json"
        try jsonData.write(to: URL(fileURLWithPath: outputPath))

        let fileSizeMB = Double(jsonData.count) / 1024 / 1024

        print("")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("✅ Database generation completed!")
        print("📊 Pokemon: \(allPokemon.count)")
        print("📊 Moves: \(allMoves.count)")
        print("📊 Abilities: \(allAbilities.count)")
        print("📦 Output: \(outputPath)")
        print("💾 File size: \(String(format: "%.2f", fileSizeMB)) MB")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

        exit(0)

    } catch {
        print("❌ Error: \(error)")
        exit(1)
    }
}

RunLoop.main.run()
