//
//  EvolutionNode.swift
//  Pokedex
//
//  Created on 2025-10-07.
//

import Foundation

/// 進化ツリーのノード情報を表すEntity
struct EvolutionNode: Equatable, Identifiable {
    /// ノードID
    let id: Int

    /// 種族ID
    let speciesId: Int

    /// ポケモン名
    let name: String

    /// 画像URL
    let imageUrl: String?

    /// タイプ
    let types: [String]

    /// 進化先のエッジ
    let evolvesTo: [EvolutionEdge]

    /// 進化元のエッジ
    let evolvesFrom: EvolutionEdge?

    /// 進化のエッジ（矢印）情報
    struct EvolutionEdge: Equatable {
        /// 進化先の種族ID
        let target: Int

        /// 進化トリガー
        let trigger: EvolutionTrigger

        /// 進化条件のリスト
        let conditions: [EvolutionCondition]
    }

    /// 進化トリガーの種類
    enum EvolutionTrigger: String, Equatable {
        /// レベルアップ
        case levelUp = "level-up"

        /// 通信交換
        case trade = "trade"

        /// アイテム使用
        case useItem = "use-item"

        /// 特殊（脱皮など）
        case shed = "shed"

        /// その他
        case other
    }

    /// 進化条件
    struct EvolutionCondition: Equatable {
        /// 条件の種類
        let type: ConditionType

        /// 条件の値（文字列）
        let value: String?

        /// 条件の種類
        enum ConditionType: String, Equatable {
            case minLevel = "min_level"
            case item = "item"
            case heldItem = "held_item"
            case timeOfDay = "time_of_day"
            case location = "location"
            case minHappiness = "min_happiness"
            case minBeauty = "min_beauty"
            case minAffection = "min_affection"
            case knownMove = "known_move"
            case knownMoveType = "known_move_type"
            case partySpecies = "party_species"
            case partyType = "party_type"
            case relativePhysicalStats = "relative_physical_stats"
            case tradeSpecies = "trade_species"
            case needsOverworldRain = "needs_overworld_rain"
            case turnUpsideDown = "turn_upside_down"
        }

        /// 表示用テキスト
        var displayText: String {
            switch type {
            case .minLevel:
                return "Lv.\(value ?? "?")"
            case .item:
                return value ?? "アイテム"
            case .heldItem:
                return "\(value ?? "持ち物")を持たせて通信交換"
            case .timeOfDay:
                if let value = value {
                    switch value {
                    case "day":
                        return "朝・昼"
                    case "night":
                        return "夜"
                    default:
                        return value
                    }
                }
                return "特定の時間帯"
            case .location:
                return value ?? "特定の場所"
            case .minHappiness:
                return "なつき度\(value ?? "")"
            case .minBeauty:
                return "うつくしさ\(value ?? "")"
            case .minAffection:
                return "なかよし度\(value ?? "")"
            case .knownMove:
                return "\(value ?? "技")習得"
            case .knownMoveType:
                return "\(value ?? "タイプ")技習得"
            case .partySpecies:
                return "\(value ?? "ポケモン")を手持ちに"
            case .partyType:
                return "\(value ?? "タイプ")を手持ちに"
            case .relativePhysicalStats:
                if let value = value {
                    switch value {
                    case "1":
                        return "攻撃>防御"
                    case "-1":
                        return "攻撃<防御"
                    case "0":
                        return "攻撃=防御"
                    default:
                        return value
                    }
                }
                return "攻撃・防御の関係"
            case .tradeSpecies:
                return "\(value ?? "ポケモン")と交換"
            case .needsOverworldRain:
                return "雨が降っている"
            case .turnUpsideDown:
                return "本体を逆さまに"
            }
        }
    }
}

/// 進化チェーン全体を表すEntity
struct EvolutionChainEntity: Equatable {
    /// 進化チェーンID
    let id: Int

    /// ルートノード（進化前のポケモン）
    let rootNode: EvolutionNode

    /// ツリー構造を平坦化したノードリスト（表示用）
    var allNodes: [EvolutionNode] {
        flattenTree(node: rootNode)
    }

    /// ツリーを平坦化してリストに変換
    private func flattenTree(node: EvolutionNode) -> [EvolutionNode] {
        var result = [node]
        // 再帰的に子ノードを追加
        // 注: この実装は簡略化されています。実際の実装時に詳細化が必要です。
        return result
    }
}
