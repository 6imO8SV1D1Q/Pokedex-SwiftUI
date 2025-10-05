//
//  MoveLearnMethod.swift
//  Pokedex
//
//  Created on 2025-10-05.
//

import Foundation

/// 技習得方法のタイプ
enum MoveLearnMethodType: Equatable {
    /// レベルアップで習得
    case levelUp(level: Int)
    /// わざマシン/わざレコードで習得
    case machine(number: String)  // "TM15", "TR03" など
    /// タマゴ技
    case egg
    /// 教え技
    case tutor
    /// 進化時に習得
    case evolution
    /// フォルムチェンジ時に習得
    case form

    /// 表示用の名前
    var displayName: String {
        switch self {
        case .levelUp(let level):
            return "Lv.\(level)"
        case .machine(let number):
            return number
        case .egg:
            return "タマゴ"
        case .tutor:
            return "教え技"
        case .evolution:
            return "進化時"
        case .form:
            return "フォルム変更"
        }
    }
}

/// 技の習得方法を表すエンティティ
/// 特定のバージョングループにおけるポケモンの技習得情報を保持
struct MoveLearnMethod: Equatable {
    /// 技の情報
    let move: MoveEntity
    /// 習得方法
    let method: MoveLearnMethodType
    /// 対象バージョングループ（例: "scarlet-violet"）
    let versionGroup: String
}
