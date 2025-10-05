//
//  MoveLearnMethod.swift
//  Pokedex
//
//  Created on 2025-10-05.
//

import Foundation

/// 技習得方法のタイプ
enum MoveLearnMethodType: Equatable {
    case levelUp(level: Int)
    case machine(number: String)  // "TM15", "TR03" など
    case egg
    case tutor
    case evolution
    case form  // フォルムチェンジ時

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

/// 技の習得方法
struct MoveLearnMethod: Equatable {
    let move: MoveEntity
    let method: MoveLearnMethodType
    let versionGroup: String
}
