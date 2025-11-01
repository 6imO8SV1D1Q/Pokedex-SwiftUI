//
//  DamageCalculatorViewModel.swift
//  Pokedex
//
//  Created as part of v5 damage calculator scaffolding.
//

import Foundation
import SwiftUI

@MainActor
final class DamageCalculatorViewModel: ObservableObject {
    // MARK: - Nested Types

    struct PokemonOption: Identifiable, Hashable {
        let id: Int
        let name: String
        let nameJa: String?
        let types: [PokemonType]

        init(pokemon: Pokemon) {
            self.id = pokemon.id
            self.name = pokemon.name
            self.nameJa = pokemon.nameJa
            self.types = pokemon.types
        }

        func displayName(for language: AppLanguage) -> String {
            switch language {
            case .japanese:
                return nameJa ?? name.capitalized
            case .english:
                return name.replacingOccurrences(of: "-", with: " ").capitalized
            }
        }
    }

    struct MoveOption: Identifiable, Hashable {
        let id: Int
        let name: String
        let nameJa: String
        let damageClass: String

        init(move: MoveEntity) {
            self.id = move.id
            self.name = move.name
            self.nameJa = move.nameJa
            self.damageClass = move.damageClass
        }

        func displayName(for language: AppLanguage) -> String {
            switch language {
            case .japanese:
                return nameJa
            case .english:
                return name.replacingOccurrences(of: "-", with: " ").capitalized
            }
        }
    }

    struct AbilityOption: Identifiable, Hashable {
        let id: Int
        let name: String
        let nameJa: String

        init(ability: AbilityEntity) {
            self.id = ability.id
            self.name = ability.name
            self.nameJa = ability.nameJa
        }

        func displayName(for language: AppLanguage) -> String {
            switch language {
            case .japanese:
                return nameJa
            case .english:
                return name.replacingOccurrences(of: "-", with: " ").capitalized
            }
        }
    }

    struct ItemOption: Identifiable, Hashable {
        let id: String
        let name: String
        let nameJa: String

        var displayNameEnglish: String {
            name
        }

        func displayName(for language: AppLanguage) -> String {
            switch language {
            case .japanese:
                return nameJa
            case .english:
                return name
            }
        }
    }

    enum BattleMode: String, CaseIterable, Identifiable {
        case single
        case double

        var id: String { rawValue }

        var localizationKey: String {
            switch self {
            case .single:
                return "damage_calc.mode.single"
            case .double:
                return "damage_calc.mode.double"
            }
        }
    }

    enum WeatherCondition: String, CaseIterable, Identifiable {
        case clear
        case sunny
        case rain
        case sandstorm
        case snow
        case strongWinds = "strong_winds"

        var id: String { rawValue }

        var localizationKey: String {
            switch self {
            case .clear:
                return "damage_calc.weather.clear"
            case .sunny:
                return "damage_calc.weather.sunny"
            case .rain:
                return "damage_calc.weather.rain"
            case .sandstorm:
                return "damage_calc.weather.sandstorm"
            case .snow:
                return "damage_calc.weather.snow"
            case .strongWinds:
                return "damage_calc.weather.strong_winds"
            }
        }
    }

    enum TerrainField: String, CaseIterable, Identifiable {
        case none
        case electric
        case grassy
        case misty
        case psychic

        var id: String { rawValue }

        var localizationKey: String {
            switch self {
            case .none:
                return "damage_calc.terrain.none"
            case .electric:
                return "damage_calc.terrain.electric"
            case .grassy:
                return "damage_calc.terrain.grassy"
            case .misty:
                return "damage_calc.terrain.misty"
            case .psychic:
                return "damage_calc.terrain.psychic"
            }
        }
    }

    enum ScreenEffect: String, CaseIterable, Identifiable {
        case none
        case reflect
        case lightScreen = "light_screen"
        case auroraVeil = "aurora_veil"

        var id: String { rawValue }

        var localizationKey: String {
            switch self {
            case .none:
                return "damage_calc.screen.none"
            case .reflect:
                return "damage_calc.screen.reflect"
            case .lightScreen:
                return "damage_calc.screen.light_screen"
            case .auroraVeil:
                return "damage_calc.screen.aurora_veil"
            }
        }
    }

    enum NatureOption: String, CaseIterable, Identifiable {
        case hardy
        case adamant
        case timid

        var id: String { rawValue }

        var localizationKey: String {
            switch self {
            case .hardy:
                return "damage_calc.nature.hardy"
            case .adamant:
                return "damage_calc.nature.adamant"
            case .timid:
                return "damage_calc.nature.timid"
            }
        }
    }

    enum StatKey: String, CaseIterable, Identifiable {
        case hp
        case attack
        case defense
        case specialAttack = "special-attack"
        case specialDefense = "special-defense"
        case speed

        var id: String { rawValue }

        var localizedKey: LocalizedStringKey {
            switch self {
            case .hp:
                return L10n.Stat.hp
            case .attack:
                return L10n.Stat.attack
            case .defense:
                return L10n.Stat.defense
            case .specialAttack:
                return L10n.Stat.specialAttack
            case .specialDefense:
                return L10n.Stat.specialDefense
            case .speed:
                return L10n.Stat.speed
            }
        }
    }

    // MARK: - Published Properties

    @Published var battleMode: BattleMode = .single {
        didSet { recalculateSummary() }
    }

    @Published var attackerPokemon: PokemonOption? {
        didSet { applyPokemonSelection(isAttacker: true) }
    }

    @Published var defenderPokemon: PokemonOption? {
        didSet { applyPokemonSelection(isAttacker: false) }
    }

    @Published var attackerLevel: Int = 50 {
        didSet {
            if attackerLevel < 1 {
                attackerLevel = 1
                return
            }
            if attackerLevel > 100 {
                attackerLevel = 100
                return
            }
            recalculateSummary()
        }
    }

    @Published var defenderLevel: Int = 50 {
        didSet {
            if defenderLevel < 1 {
                defenderLevel = 1
                return
            }
            if defenderLevel > 100 {
                defenderLevel = 100
                return
            }
            recalculateSummary()
        }
    }

    @Published var attackerNature: NatureOption = .hardy {
        didSet { recalculateSummary() }
    }

    @Published var defenderNature: NatureOption = .hardy {
        didSet { recalculateSummary() }
    }

    @Published var attackerSelectedMove: MoveOption? {
        didSet {
            if firstTurnMove == nil {
                firstTurnMove = attackerSelectedMove
            }
            recalculateSummary()
        }
    }

    @Published var defenderSelectedMove: MoveOption? {
        didSet { recalculateSummary() }
    }

    @Published var attackerHeldItem: ItemOption? {
        didSet { recalculateSummary() }
    }

    @Published var defenderHeldItem: ItemOption? {
        didSet { recalculateSummary() }
    }

    @Published var attackerAbility: AbilityOption? {
        didSet { recalculateSummary() }
    }

    @Published var defenderAbility: AbilityOption? {
        didSet { recalculateSummary() }
    }

    @Published var attackerIsTerastallized: Bool = false {
        didSet { recalculateSummary() }
    }

    @Published var defenderIsTerastallized: Bool = false {
        didSet { recalculateSummary() }
    }

    @Published var attackerTeraType: String? {
        didSet { recalculateSummary() }
    }

    @Published var defenderTeraType: String? {
        didSet { recalculateSummary() }
    }

    @Published private(set) var attackerBaseTypes: [PokemonType] = []
    @Published private(set) var defenderBaseTypes: [PokemonType] = []

    @Published var weather: WeatherCondition = .clear {
        didSet { recalculateSummary() }
    }

    @Published var terrain: TerrainField = .none {
        didSet { recalculateSummary() }
    }

    @Published var screen: ScreenEffect = .none {
        didSet { recalculateSummary() }
    }

    @Published var hazardDamage: Double = 0 {
        didSet {
            if hazardDamage < 0 {
                hazardDamage = 0
                return
            }
            if hazardDamage > 100 {
                hazardDamage = 100
                return
            }
            recalculateSummary()
        }
    }

    @Published var firstTurnMove: MoveOption? {
        didSet { recalculateSummary() }
    }

    @Published var secondTurnMove: MoveOption? {
        didSet { recalculateSummary() }
    }

    @Published var applyAccuracy: Bool = true {
        didSet { recalculateSummary() }
    }

    @Published private(set) var summaryText: String
    @Published var isLoadingData = false
    @Published var errorMessage: String?

    @Published var pokemonOptions: [PokemonOption] = []
    @Published var moveOptions: [MoveOption] = []
    @Published var abilityOptions: [AbilityOption] = []

    // MARK: - Private State

    private var attackerEVsStorage: [StatKey: Int]
    private var defenderEVsStorage: [StatKey: Int]
    private var attackerIVsStorage: [StatKey: Int]
    private var defenderIVsStorage: [StatKey: Int]
    private var attackerStatStagesStorage: [StatKey: Int]
    private var defenderStatStagesStorage: [StatKey: Int]

    private var hasLoaded = false
    private var currentLanguage: AppLanguage = .english
    private var bundleCache: [AppLanguage: Bundle] = [:]

    // MARK: - Dependencies

    private let pokemonRepository: PokemonRepositoryProtocol
    private let moveRepository: MoveRepositoryProtocol
    private let abilityRepository: AbilityRepositoryProtocol

    let itemOptions: [ItemOption]
    let typeOptions: [String]

    // MARK: - Initialization

    init(
        pokemonRepository: PokemonRepositoryProtocol,
        moveRepository: MoveRepositoryProtocol,
        abilityRepository: AbilityRepositoryProtocol
    ) {
        self.pokemonRepository = pokemonRepository
        self.moveRepository = moveRepository
        self.abilityRepository = abilityRepository
        self.attackerEVsStorage = Self.initialStatDictionary(defaultValue: 0)
        self.defenderEVsStorage = Self.initialStatDictionary(defaultValue: 0)
        self.attackerIVsStorage = Self.initialStatDictionary(defaultValue: 31)
        self.defenderIVsStorage = Self.initialStatDictionary(defaultValue: 31)
        self.attackerStatStagesStorage = Self.initialStatDictionary(defaultValue: 0)
        self.defenderStatStagesStorage = Self.initialStatDictionary(defaultValue: 0)
        self.summaryText = localizedString("damage_calc.result.placeholder")
        self.itemOptions = [
            ItemOption(id: "leftovers", name: "Leftovers", nameJa: "たべのこし"),
            ItemOption(id: "choice-scarf", name: "Choice Scarf", nameJa: "こだわりスカーフ"),
            ItemOption(id: "focus-sash", name: "Focus Sash", nameJa: "きあいのタスキ"),
            ItemOption(id: "wellspring-mask", name: "Wellspring Mask", nameJa: "いどのめん"),
            ItemOption(id: "hearthflame-mask", name: "Hearthflame Mask", nameJa: "かまどのめん"),
            ItemOption(id: "cornerstone-mask", name: "Cornerstone Mask", nameJa: "いしずえのめん")
        ]
        self.typeOptions = [
            "normal", "fire", "water", "grass", "electric", "ice", "fighting",
            "poison", "ground", "flying", "psychic", "bug", "rock", "ghost",
            "dragon", "dark", "steel", "fairy"
        ]
    }

    // MARK: - Public API

    func loadInitialData(force: Bool = false) {
        if isLoadingData {
            return
        }
        if hasLoaded && !force {
            return
        }

        isLoadingData = true
        errorMessage = nil

        let pokemonRepository = self.pokemonRepository
        let moveRepository = self.moveRepository
        let abilityRepository = self.abilityRepository

        Task {
            do {
                async let pokemonTask = pokemonRepository.fetchPokemonList(limit: 200, offset: 0, progressHandler: nil)
                async let movesTask = moveRepository.fetchAllMoves(versionGroup: nil)
                async let abilitiesTask = abilityRepository.fetchAllAbilities()

                let (pokemonResult, moveResult, abilityResult) = try await (pokemonTask, movesTask, abilitiesTask)

                var pokemonOptions = pokemonResult.map { PokemonOption(pokemon: $0) }
                var moveOptions = moveResult.map { MoveOption(move: $0) }
                var abilityOptions = abilityResult.map { AbilityOption(ability: $0) }

                pokemonOptions.sort { $0.displayName(for: .english) < $1.displayName(for: .english) }

                moveOptions = Self.prepareMoves(moveOptions)
                abilityOptions = Self.prepareAbilities(abilityOptions)

                await MainActor.run { [weak self] in
                    guard let self else { return }
                    self.pokemonOptions = pokemonOptions
                    self.moveOptions = moveOptions
                    self.abilityOptions = abilityOptions
                    self.hasLoaded = true
                    self.isLoadingData = false
                    self.errorMessage = nil
                    self.applyDefaultSelectionsIfNeeded()
                    self.sortOptionsForLanguage()
                    self.recalculateSummary()
                }
            } catch {
                await MainActor.run { [weak self] in
                    guard let self else { return }
                    self.errorMessage = error.localizedDescription
                    self.isLoadingData = false
                    self.hasLoaded = false
                }
            }
        }
    }

    func updateLanguage(_ language: AppLanguage) {
        if currentLanguage == language {
            return
        }
        currentLanguage = language
        sortOptionsForLanguage()
        recalculateSummary()
    }

    func swapParticipants() {
        swap(&attackerPokemon, &defenderPokemon)
        swap(&attackerLevel, &defenderLevel)
        swap(&attackerNature, &defenderNature)
        swap(&attackerSelectedMove, &defenderSelectedMove)
        swap(&attackerHeldItem, &defenderHeldItem)
        swap(&attackerAbility, &defenderAbility)
        swap(&attackerIsTerastallized, &defenderIsTerastallized)
        swap(&attackerTeraType, &defenderTeraType)
        swap(&attackerBaseTypes, &defenderBaseTypes)
        swap(&attackerEVsStorage, &defenderEVsStorage)
        swap(&attackerIVsStorage, &defenderIVsStorage)
        swap(&attackerStatStagesStorage, &defenderStatStagesStorage)
        firstTurnMove = attackerSelectedMove
        recalculateSummary()
    }

    func refreshSummary() {
        recalculateSummary()
    }

    func attackerEV(for stat: StatKey) -> Int {
        attackerEVsStorage[stat] ?? 0
    }

    func defenderEV(for stat: StatKey) -> Int {
        defenderEVsStorage[stat] ?? 0
    }

    func setAttackerEV(_ value: Int, for stat: StatKey) {
        let clamped = max(0, min(252, value))
        attackerEVsStorage[stat] = clamped
        recalculateSummary()
    }

    func setDefenderEV(_ value: Int, for stat: StatKey) {
        let clamped = max(0, min(252, value))
        defenderEVsStorage[stat] = clamped
        recalculateSummary()
    }

    func attackerIV(for stat: StatKey) -> Int {
        attackerIVsStorage[stat] ?? 31
    }

    func defenderIV(for stat: StatKey) -> Int {
        defenderIVsStorage[stat] ?? 31
    }

    func setAttackerIV(_ value: Int, for stat: StatKey) {
        let clamped = max(0, min(31, value))
        attackerIVsStorage[stat] = clamped
        recalculateSummary()
    }

    func setDefenderIV(_ value: Int, for stat: StatKey) {
        let clamped = max(0, min(31, value))
        defenderIVsStorage[stat] = clamped
        recalculateSummary()
    }

    func attackerStatStage(for stat: StatKey) -> Int {
        attackerStatStagesStorage[stat] ?? 0
    }

    func defenderStatStage(for stat: StatKey) -> Int {
        defenderStatStagesStorage[stat] ?? 0
    }

    func setAttackerStatStage(_ value: Int, for stat: StatKey) {
        let clamped = max(-6, min(6, value))
        attackerStatStagesStorage[stat] = clamped
        recalculateSummary()
    }

    func setDefenderStatStage(_ value: Int, for stat: StatKey) {
        let clamped = max(-6, min(6, value))
        defenderStatStagesStorage[stat] = clamped
        recalculateSummary()
    }

    func remainingEVText(forAttacker: Bool) -> String {
        let storage = forAttacker ? attackerEVsStorage : defenderEVsStorage
        let used = storage.values.reduce(0, +)
        let remaining = max(0, 510 - used)
        let format = localizedString(L10n.DamageCalculator.fieldRemainingEVsFormat)
        return String(format: format, locale: Locale(identifier: currentLanguage.rawValue), remaining)
    }

    // MARK: - Private Helpers

    private func applyPokemonSelection(isAttacker: Bool) {
        if isAttacker {
            attackerBaseTypes = attackerPokemon?.types ?? []
            if attackerTeraType == nil, let firstType = attackerPokemon?.types.first?.name {
                attackerTeraType = firstType
            }
        } else {
            defenderBaseTypes = defenderPokemon?.types ?? []
            if defenderTeraType == nil, let firstType = defenderPokemon?.types.first?.name {
                defenderTeraType = firstType
            }
        }
        recalculateSummary()
    }

    private func applyDefaultSelectionsIfNeeded() {
        if attackerPokemon == nil {
            attackerPokemon = pokemonOptions.first
        }
        if defenderPokemon == nil {
            defenderPokemon = pokemonOptions.dropFirst().first ?? pokemonOptions.first
        }
        if attackerSelectedMove == nil {
            attackerSelectedMove = moveOptions.first(where: { $0.name == "ivy-cudgel" }) ?? moveOptions.first
        }
        if firstTurnMove == nil {
            firstTurnMove = attackerSelectedMove
        }
        if defenderSelectedMove == nil {
            defenderSelectedMove = moveOptions.first(where: { $0.name == "protect" }) ?? moveOptions.first
        }
    }

    private func sortOptionsForLanguage() {
        pokemonOptions.sort { $0.displayName(for: currentLanguage) < $1.displayName(for: currentLanguage) }
        moveOptions.sort { $0.displayName(for: currentLanguage) < $1.displayName(for: currentLanguage) }
        abilityOptions.sort { $0.displayName(for: currentLanguage) < $1.displayName(for: currentLanguage) }
    }

    private func recalculateSummary() {
        guard let attackerPokemon, let defenderPokemon, let firstTurnMove else {
            summaryText = localizedString("damage_calc.result.placeholder")
            return
        }

        let modeText = localizedString(battleMode.localizationKey)
        let attackerName = attackerPokemon.displayName(for: currentLanguage)
        let defenderName = defenderPokemon.displayName(for: currentLanguage)
        let moveName = firstTurnMove.displayName(for: currentLanguage)
        let weatherText = localizedName(for: weather)
        let terrainText = localizedName(for: terrain)
        let accuracyText = localizedString(applyAccuracy ? "damage_calc.accuracy.on" : "damage_calc.accuracy.off")
        let template = localizedString("damage_calc.summary.template")

        summaryText = String(
            format: template,
            locale: Locale(identifier: currentLanguage.rawValue),
            modeText,
            attackerName,
            attackerLevel,
            moveName,
            defenderName,
            defenderLevel,
            weatherText,
            terrainText,
            Int(round(hazardDamage)),
            accuracyText
        )
    }

    private func localizedName(for weather: WeatherCondition) -> String {
        localizedString(weather.localizationKey)
    }

    private func localizedName(for terrain: TerrainField) -> String {
        localizedString(terrain.localizationKey)
    }

    private func localizedString(_ key: String) -> String {
        if let bundle = bundle(for: currentLanguage) {
            return NSLocalizedString(key, tableName: nil, bundle: bundle, value: "", comment: "")
        }
        return NSLocalizedString(key, comment: "")
    }

    private func bundle(for language: AppLanguage) -> Bundle? {
        if let cached = bundleCache[language] {
            return cached
        }
        guard let path = Bundle.main.path(forResource: language.rawValue, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            return nil
        }
        bundleCache[language] = bundle
        return bundle
    }

    private static func initialStatDictionary(defaultValue: Int) -> [StatKey: Int] {
        var dict: [StatKey: Int] = [:]
        StatKey.allCases.forEach { dict[$0] = defaultValue }
        return dict
    }

    private static func prepareMoves(_ moves: [MoveOption]) -> [MoveOption] {
        var limited = Array(moves.prefix(150))
        if let ivyCudgel = moves.first(where: { $0.name == "ivy-cudgel" }), !limited.contains(where: { $0.id == ivyCudgel.id }) {
            limited.append(ivyCudgel)
        }
        if let protect = moves.first(where: { $0.name == "protect" }), !limited.contains(where: { $0.id == protect.id }) {
            limited.append(protect)
        }
        limited.sort { $0.name < $1.name }
        return limited
    }

    private static func prepareAbilities(_ abilities: [AbilityOption]) -> [AbilityOption] {
        var limited = Array(abilities.prefix(120))
        if let defiant = abilities.first(where: { $0.name == "defiant" }), !limited.contains(where: { $0.id == defiant.id }) {
            limited.append(defiant)
        }
        limited.sort { $0.name < $1.name }
        return limited
    }
}
