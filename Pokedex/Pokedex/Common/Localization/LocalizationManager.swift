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
}
