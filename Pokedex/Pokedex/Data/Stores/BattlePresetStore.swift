//
//  BattlePresetStore.swift
//  Pokedex
//
//  Created on 2025-11-01.
//

import Foundation

/// バトル設定のプリセット保存/読込
actor BattlePresetStore {

    private let userDefaults: UserDefaults
    private let presetsKey = "battle_presets_v1"
    private let maxPresets = 20

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    /// プリセット一覧を取得
    func listPresets() -> [BattlePreset] {
        guard let data = userDefaults.data(forKey: presetsKey) else {
            return []
        }

        do {
            let presets = try JSONDecoder().decode([BattlePreset].self, from: data)
            return presets
        } catch {
            print("⚠️ Failed to decode presets: \(error)")
            return []
        }
    }

    /// プリセットを保存
    func savePreset(_ preset: BattlePreset) throws {
        var presets = listPresets()

        // 既存のプリセットを更新 or 新規追加
        if let index = presets.firstIndex(where: { $0.id == preset.id }) {
            presets[index] = preset
        } else {
            presets.append(preset)
        }

        // 最大数を超えたら古いものを削除
        if presets.count > maxPresets {
            presets = Array(presets.suffix(maxPresets))
        }

        let data = try JSONEncoder().encode(presets)
        userDefaults.set(data, forKey: presetsKey)
    }

    /// プリセットを削除
    func deletePreset(id: UUID) throws {
        var presets = listPresets()
        presets.removeAll { $0.id == id }

        let data = try JSONEncoder().encode(presets)
        userDefaults.set(data, forKey: presetsKey)
    }

    /// プリセットを取得
    func getPreset(id: UUID) -> BattlePreset? {
        return listPresets().first { $0.id == id }
    }

    /// 全プリセットを削除
    func deleteAllPresets() {
        userDefaults.removeObject(forKey: presetsKey)
    }
}

/// バトル設定のプリセット
struct BattlePreset: Identifiable, Codable, Equatable {
    /// ID
    let id: UUID

    /// プリセット名
    var name: String

    /// バトル設定
    var battleState: BattleState

    /// 作成日時
    let createdAt: Date

    /// 更新日時
    var updatedAt: Date

    /// 新規作成
    init(name: String, battleState: BattleState) {
        self.id = UUID()
        self.name = name
        self.battleState = battleState
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    /// 更新
    mutating func update(name: String? = nil, battleState: BattleState? = nil) {
        if let name = name {
            self.name = name
        }
        if let battleState = battleState {
            self.battleState = battleState
        }
        self.updatedAt = Date()
    }
}
