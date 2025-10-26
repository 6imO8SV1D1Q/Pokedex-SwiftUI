//
//  LocalizationManager.swift
//  Pokedex
//
//  言語設定の管理
//

import Foundation
import SwiftUI
import Combine

/// アプリの表示言語
enum AppLanguage: String, CaseIterable, Identifiable {
    case japanese = "ja"
    case english = "en"

    var id: String { rawValue }

    /// 表示名
    var displayName: String {
        switch self {
        case .japanese: return "日本語"
        case .english: return "English"
        }
    }
}

/// 言語設定を管理するマネージャー
@MainActor
class LocalizationManager: ObservableObject {
    /// 現在の言語設定
    @Published var currentLanguage: AppLanguage {
        didSet {
            UserDefaults.standard.set(currentLanguage.rawValue, forKey: "app_language")
        }
    }

    /// シングルトンインスタンス
    static let shared = LocalizationManager()

    private init() {
        // UserDefaultsから言語設定を読み込む
        if let savedLanguage = UserDefaults.standard.string(forKey: "app_language"),
           let language = AppLanguage(rawValue: savedLanguage) {
            self.currentLanguage = language
        } else {
            // デフォルトは日本語
            self.currentLanguage = .japanese
        }
    }

    /// タイプ名の表示
    func displayName(for type: PokemonType) -> String {
        switch currentLanguage {
        case .japanese:
            return type.nameJa ?? type.japaneseName  // データベース優先、フォールバックはハードコード
        case .english:
            return type.name.capitalized
        }
    }

    /// String型のタイプ名を表示用に変換
    func displayName(forTypeName typeName: String) -> String {
        switch currentLanguage {
        case .japanese:
            // PokemonTypeのjapaneseNameロジックと同じマッピング
            switch typeName.lowercased() {
            case "normal": return "ノーマル"
            case "fire": return "ほのお"
            case "water": return "みず"
            case "electric": return "でんき"
            case "grass": return "くさ"
            case "ice": return "こおり"
            case "fighting": return "かくとう"
            case "poison": return "どく"
            case "ground": return "じめん"
            case "flying": return "ひこう"
            case "psychic": return "エスパー"
            case "bug": return "むし"
            case "rock": return "いわ"
            case "ghost": return "ゴースト"
            case "dragon": return "ドラゴン"
            case "dark": return "あく"
            case "steel": return "はがね"
            case "fairy": return "フェアリー"
            default: return typeName
            }
        case .english:
            return typeName.capitalized
        }
    }

    /// ポケモン名の表示
    func displayName(for pokemon: Pokemon) -> String {
        switch currentLanguage {
        case .japanese:
            return pokemon.nameJa ?? pokemon.name.capitalized
        case .english:
            return pokemon.name.capitalized
        }
    }

    /// 特性名の表示
    func displayName(for ability: PokemonAbility) -> String {
        let baseName: String
        switch currentLanguage {
        case .japanese:
            baseName = ability.nameJa ?? ability.name.capitalized
        case .english:
            baseName = ability.name.capitalized
        }
        return ability.isHidden ? "\(baseName) (隠れ特性)" : baseName
    }

    /// 図鑑名の表示
    func displayName(for pokedex: PokedexType) -> String {
        switch currentLanguage {
        case .japanese:
            return pokedex.nameJa
        case .english:
            return pokedex.nameEn
        }
    }

    // MARK: - Evolution Conditions

    /// 進化条件の表示テキストを取得
    func displayText(for condition: EvolutionNode.EvolutionCondition) -> String {
        switch condition.type {
        case .minLevel:
            return "Lv.\(condition.value ?? "?")"
        case .item:
            return localizedItemName(condition.value)
        case .heldItem:
            let itemName = localizedItemName(condition.value)
            switch currentLanguage {
            case .japanese:
                return "\(itemName)を持たせて通信交換"
            case .english:
                return "Trade holding \(itemName)"
            }
        case .timeOfDay:
            return localizedTimeOfDay(condition.value)
        case .location:
            return localizedLocation(condition.value)
        case .minHappiness:
            switch currentLanguage {
            case .japanese:
                return "なつき度\(condition.value ?? "")"
            case .english:
                return "Happiness \(condition.value ?? "")"
            }
        case .minBeauty:
            switch currentLanguage {
            case .japanese:
                return "うつくしさ\(condition.value ?? "")"
            case .english:
                return "Beauty \(condition.value ?? "")"
            }
        case .minAffection:
            switch currentLanguage {
            case .japanese:
                return "なかよし度\(condition.value ?? "")"
            case .english:
                return "Affection \(condition.value ?? "")"
            }
        case .knownMove:
            switch currentLanguage {
            case .japanese:
                return "\(condition.value ?? "技")習得"
            case .english:
                return "Learn \(condition.value ?? "move")"
            }
        case .knownMoveType:
            let typeName = condition.value ?? ""
            let localizedType = displayName(forTypeName: typeName)
            switch currentLanguage {
            case .japanese:
                return "\(localizedType)技習得"
            case .english:
                return "Learn \(localizedType) move"
            }
        case .partySpecies:
            switch currentLanguage {
            case .japanese:
                return "\(condition.value ?? "ポケモン")を手持ちに"
            case .english:
                return "\(condition.value ?? "Pokémon") in party"
            }
        case .partyType:
            let typeName = condition.value ?? ""
            let localizedType = displayName(forTypeName: typeName)
            switch currentLanguage {
            case .japanese:
                return "\(localizedType)を手持ちに"
            case .english:
                return "\(localizedType) in party"
            }
        case .relativePhysicalStats:
            if let value = condition.value {
                switch value {
                case "1":
                    switch currentLanguage {
                    case .japanese: return "攻撃>防御"
                    case .english: return "Atk > Def"
                    }
                case "-1":
                    switch currentLanguage {
                    case .japanese: return "攻撃<防御"
                    case .english: return "Atk < Def"
                    }
                case "0":
                    switch currentLanguage {
                    case .japanese: return "攻撃=防御"
                    case .english: return "Atk = Def"
                    }
                default:
                    return value
                }
            }
            switch currentLanguage {
            case .japanese: return "攻撃・防御の関係"
            case .english: return "Atk/Def relation"
            }
        case .tradeSpecies:
            switch currentLanguage {
            case .japanese:
                return "\(condition.value ?? "ポケモン")と交換"
            case .english:
                return "Trade for \(condition.value ?? "Pokémon")"
            }
        case .needsOverworldRain:
            switch currentLanguage {
            case .japanese: return "雨が降っている"
            case .english: return "Raining"
            }
        case .turnUpsideDown:
            switch currentLanguage {
            case .japanese: return "本体を逆さまに"
            case .english: return "Turn upside down"
            }
        }
    }

    /// 進化トリガーの表示テキストを取得
    func displayText(for trigger: EvolutionNode.EvolutionTrigger) -> String? {
        switch trigger {
        case .levelUp:
            return nil // レベルアップは表示しない（条件にLv.が含まれるため）
        case .trade:
            switch currentLanguage {
            case .japanese: return "通信交換"
            case .english: return "Trade"
            }
        case .useItem:
            switch currentLanguage {
            case .japanese: return "アイテム"
            case .english: return "Item"
            }
        case .shed:
            switch currentLanguage {
            case .japanese: return "脱皮"
            case .english: return "Shed"
            }
        case .other:
            switch currentLanguage {
            case .japanese: return "特殊"
            case .english: return "Other"
            }
        }
    }

    // MARK: - Private Helpers

    /// アイテム名のローカライズ
    private func localizedItemName(_ itemName: String?) -> String {
        guard let itemName = itemName else {
            switch currentLanguage {
            case .japanese: return "アイテム"
            case .english: return "Item"
            }
        }

        switch currentLanguage {
        case .japanese:
            let itemMapping: [String: String] = [
                // 進化石
                "fire-stone": "ほのおのいし",
                "water-stone": "みずのいし",
                "thunder-stone": "かみなりのいし",
                "leaf-stone": "リーフのいし",
                "moon-stone": "つきのいし",
                "sun-stone": "たいようのいし",
                "shiny-stone": "ひかりのいし",
                "dusk-stone": "やみのいし",
                "dawn-stone": "めざめのいし",
                "ice-stone": "こおりのいし",
                "oval-stone": "まんまるいし",
                // その他の進化アイテム
                "kings-rock": "おうじゃのしるし",
                "metal-coat": "メタルコート",
                "dragon-scale": "りゅうのウロコ",
                "up-grade": "アップグレード",
                "dubious-disc": "あやしいパッチ",
                "protector": "プロテクター",
                "electirizer": "エレキブースター",
                "magmarizer": "マグマブースター",
                "razor-fang": "するどいキバ",
                "razor-claw": "するどいツメ",
                "prism-scale": "きれいなウロコ",
                "reaper-cloth": "れいかいのぬの",
                "deep-sea-tooth": "しんかいのキバ",
                "deep-sea-scale": "しんかいのウロコ",
                "sachet": "においぶくろ",
                "whipped-dream": "ホイップポップ",
                "tart-apple": "すっぱいりんご",
                "sweet-apple": "あまーいりんご",
                "cracked-pot": "われたポット",
                "chipped-pot": "かけたポット",
                "galarica-cuff": "ガラナツのえだ",
                "galarica-wreath": "ガラナツのリース",
                "black-augurite": "くろいかけら",
                "peat-block": "ピートブロック",
                "linking-cord": "つながりのヒモ",
                "malicious-armor": "のろいのよろい",
                "auspicious-armor": "いわいのよろい"
            ]
            return itemMapping[itemName] ?? itemName.capitalized
        case .english:
            let itemMapping: [String: String] = [
                "fire-stone": "Fire Stone",
                "water-stone": "Water Stone",
                "thunder-stone": "Thunder Stone",
                "leaf-stone": "Leaf Stone",
                "moon-stone": "Moon Stone",
                "sun-stone": "Sun Stone",
                "shiny-stone": "Shiny Stone",
                "dusk-stone": "Dusk Stone",
                "dawn-stone": "Dawn Stone",
                "ice-stone": "Ice Stone",
                "oval-stone": "Oval Stone",
                "kings-rock": "King's Rock",
                "metal-coat": "Metal Coat",
                "dragon-scale": "Dragon Scale",
                "up-grade": "Up-Grade",
                "dubious-disc": "Dubious Disc",
                "protector": "Protector",
                "electirizer": "Electirizer",
                "magmarizer": "Magmarizer",
                "razor-fang": "Razor Fang",
                "razor-claw": "Razor Claw",
                "prism-scale": "Prism Scale",
                "reaper-cloth": "Reaper Cloth",
                "deep-sea-tooth": "Deep Sea Tooth",
                "deep-sea-scale": "Deep Sea Scale",
                "sachet": "Sachet",
                "whipped-dream": "Whipped Dream",
                "tart-apple": "Tart Apple",
                "sweet-apple": "Sweet Apple",
                "cracked-pot": "Cracked Pot",
                "chipped-pot": "Chipped Pot",
                "galarica-cuff": "Galarica Cuff",
                "galarica-wreath": "Galarica Wreath",
                "black-augurite": "Black Augurite",
                "peat-block": "Peat Block",
                "linking-cord": "Linking Cord",
                "malicious-armor": "Malicious Armor",
                "auspicious-armor": "Auspicious Armor"
            ]
            return itemMapping[itemName] ?? itemName.capitalized
        }
    }

    /// 時間帯のローカライズ
    private func localizedTimeOfDay(_ timeOfDay: String?) -> String {
        guard let timeOfDay = timeOfDay else {
            switch currentLanguage {
            case .japanese: return "特定の時間帯"
            case .english: return "Specific time"
            }
        }

        switch timeOfDay {
        case "day":
            switch currentLanguage {
            case .japanese: return "朝・昼"
            case .english: return "Day"
            }
        case "night":
            switch currentLanguage {
            case .japanese: return "夜"
            case .english: return "Night"
            }
        default:
            return timeOfDay
        }
    }

    /// 場所のローカライズ
    private func localizedLocation(_ location: String?) -> String {
        guard let location = location else {
            switch currentLanguage {
            case .japanese: return "特定の場所"
            case .english: return "Specific location"
            }
        }
        // TODO: 場所名のマッピングを追加
        return location.capitalized
    }
}
