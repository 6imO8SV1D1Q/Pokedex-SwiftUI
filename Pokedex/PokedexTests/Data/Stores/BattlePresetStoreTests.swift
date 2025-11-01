//
//  BattlePresetStoreTests.swift
//  PokedexTests
//
//  Created on 2025-11-01.
//

import XCTest
@testable import Pokedex

final class BattlePresetStoreTests: XCTestCase {

    var sut: BattlePresetStore!
    var userDefaults: UserDefaults!

    override func setUp() {
        super.setUp()
        userDefaults = UserDefaults(suiteName: "TestDefaults")
        userDefaults.removePersistentDomain(forName: "TestDefaults")
        sut = BattlePresetStore(userDefaults: userDefaults)
    }

    override func tearDown() {
        userDefaults.removePersistentDomain(forName: "TestDefaults")
        userDefaults = nil
        sut = nil
        super.tearDown()
    }

    // MARK: - List Presets Tests

    func test_listPresets_initiallyEmpty() async {
        let presets = await sut.listPresets()

        XCTAssertTrue(presets.isEmpty)
    }

    func test_listPresets_returnsDecodedPresets() async throws {
        let battleState = BattleState()
        let preset = BattlePreset(name: "Test Preset", battleState: battleState)

        try await sut.savePreset(preset)

        let presets = await sut.listPresets()

        XCTAssertEqual(presets.count, 1)
        XCTAssertEqual(presets.first?.name, "Test Preset")
    }

    func test_listPresets_handlesCorruptedData() async {
        // Save invalid JSON
        userDefaults.set(Data("invalid json".utf8), forKey: "battle_presets_v1")

        let presets = await sut.listPresets()

        XCTAssertTrue(presets.isEmpty)
    }

    // MARK: - Save Preset Tests

    func test_savePreset_savesNewPreset() async throws {
        let battleState = BattleState()
        let preset = BattlePreset(name: "Test Preset", battleState: battleState)

        try await sut.savePreset(preset)

        let presets = await sut.listPresets()
        XCTAssertEqual(presets.count, 1)
        XCTAssertEqual(presets.first?.id, preset.id)
    }

    func test_savePreset_updatesExistingPreset() async throws {
        let battleState = BattleState()
        var preset = BattlePreset(name: "Test Preset", battleState: battleState)

        try await sut.savePreset(preset)

        preset.update(name: "Updated Preset")
        try await sut.savePreset(preset)

        let presets = await sut.listPresets()
        XCTAssertEqual(presets.count, 1)
        XCTAssertEqual(presets.first?.name, "Updated Preset")
    }

    func test_savePreset_limitsTo20Presets() async throws {
        // Save 25 presets
        for i in 1...25 {
            let battleState = BattleState()
            let preset = BattlePreset(name: "Preset \(i)", battleState: battleState)
            try await sut.savePreset(preset)
        }

        let presets = await sut.listPresets()

        XCTAssertEqual(presets.count, 20)
        // Should keep the most recent 20
        XCTAssertEqual(presets.first?.name, "Preset 6")
        XCTAssertEqual(presets.last?.name, "Preset 25")
    }

    // MARK: - Delete Preset Tests

    func test_deletePreset_removesPreset() async throws {
        let battleState = BattleState()
        let preset = BattlePreset(name: "Test Preset", battleState: battleState)

        try await sut.savePreset(preset)
        try await sut.deletePreset(id: preset.id)

        let presets = await sut.listPresets()
        XCTAssertTrue(presets.isEmpty)
    }

    func test_deletePreset_doesNotAffectOtherPresets() async throws {
        let battleState = BattleState()
        let preset1 = BattlePreset(name: "Preset 1", battleState: battleState)
        let preset2 = BattlePreset(name: "Preset 2", battleState: battleState)

        try await sut.savePreset(preset1)
        try await sut.savePreset(preset2)
        try await sut.deletePreset(id: preset1.id)

        let presets = await sut.listPresets()
        XCTAssertEqual(presets.count, 1)
        XCTAssertEqual(presets.first?.name, "Preset 2")
    }

    func test_deletePreset_handlesNonExistentPreset() async throws {
        let randomId = UUID()

        try await sut.deletePreset(id: randomId)

        let presets = await sut.listPresets()
        XCTAssertTrue(presets.isEmpty)
    }

    // MARK: - Get Preset Tests

    func test_getPreset_returnsCorrectPreset() async throws {
        let battleState = BattleState()
        let preset = BattlePreset(name: "Test Preset", battleState: battleState)

        try await sut.savePreset(preset)

        let retrieved = await sut.getPreset(id: preset.id)

        XCTAssertNotNil(retrieved)
        XCTAssertEqual(retrieved?.id, preset.id)
        XCTAssertEqual(retrieved?.name, "Test Preset")
    }

    func test_getPreset_returnsNilForNonExistentId() async {
        let randomId = UUID()

        let retrieved = await sut.getPreset(id: randomId)

        XCTAssertNil(retrieved)
    }

    // MARK: - Delete All Presets Tests

    func test_deleteAllPresets_removesAllPresets() async throws {
        let battleState = BattleState()

        for i in 1...5 {
            let preset = BattlePreset(name: "Preset \(i)", battleState: battleState)
            try await sut.savePreset(preset)
        }

        await sut.deleteAllPresets()

        let presets = await sut.listPresets()
        XCTAssertTrue(presets.isEmpty)
    }

    func test_deleteAllPresets_handlesEmptyStore() async {
        await sut.deleteAllPresets()

        let presets = await sut.listPresets()
        XCTAssertTrue(presets.isEmpty)
    }
}
