//
//  BattleState.swift
//  Pokedex
//
//  Created on 2025-11-01.
//

import Foundation

/// バトル全体の状態
struct BattleState: Equatable, Codable {
    /// バトルモード（シングル/ダブル）
    var mode: BattleMode

    /// 攻撃側の状態
    var attacker: BattleParticipantState

    /// 防御側の状態
    var defender: BattleParticipantState

    /// バトル環境の状態
    var environment: BattleEnvironmentState

    /// 使用する技のID（nil = 未選択）
    var selectedMoveId: Int?

    /// 2ターン目に使用する技のID（nil = 1ターン目と同じ）
    var secondMoveId: Int?

    /// 命中率を考慮するか
    var applyAccuracy: Bool

    /// デフォルト値でイニシャライズ
    init(
        mode: BattleMode = .single,
        attacker: BattleParticipantState = .init(),
        defender: BattleParticipantState = .init(),
        environment: BattleEnvironmentState = .init(),
        selectedMoveId: Int? = nil,
        secondMoveId: Int? = nil,
        applyAccuracy: Bool = false
    ) {
        self.mode = mode
        self.attacker = attacker
        self.defender = defender
        self.environment = environment
        self.selectedMoveId = selectedMoveId
        self.secondMoveId = secondMoveId
        self.applyAccuracy = applyAccuracy
    }

    /// 攻撃側と防御側を入れ替える
    mutating func swap() {
        let temp = attacker
        attacker = defender
        defender = temp
    }

    /// リセット（初期状態に戻す）
    mutating func reset() {
        self = BattleState()
    }
}
