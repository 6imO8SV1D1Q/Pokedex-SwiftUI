//
//  VersionGroup.swift
//  Pokedex
//
//  Created on 2025-10-05.
//

import Foundation

/// ポケモンのバージョングループを表すエンティティ
/// バージョングループはPokéAPIで定義されているゲームソフトの単位
struct VersionGroup: Identifiable, Equatable {
    /// バージョングループID（例: "red-blue", "sword-shield"）
    let id: String

    /// バージョングループ名（表示用、日本語）
    let name: String

    /// 世代番号（1-9）
    let generation: Int

    /// このバージョングループで使用するPokedex名のリスト
    let pokedexNames: [String]?

    /// バージョングループの表示名（日本語）
    var displayName: String {
        if id == "national" {
            return "全国図鑑"
        }
        return name
    }

    /// 全国図鑑（全ポケモン・全フォーム）
    static let nationalDex = VersionGroup(
        id: "national",
        name: "全国図鑑",
        generation: 9,  // 最新世代扱い
        pokedexNames: nil  // すべて表示
    )

    // MARK: - 第1世代

    /// 赤・緑・青
    static let redBlue = VersionGroup(
        id: "red-blue",
        name: "赤・緑・青",
        generation: 1,
        pokedexNames: ["kanto"]
    )

    /// ピカチュウ
    static let yellow = VersionGroup(
        id: "yellow",
        name: "ピカチュウ",
        generation: 1,
        pokedexNames: ["kanto"]
    )

    // MARK: - 第2世代

    /// 金・銀
    static let goldSilver = VersionGroup(
        id: "gold-silver",
        name: "金・銀",
        generation: 2,
        pokedexNames: ["updated-johto"]
    )

    /// クリスタル
    static let crystal = VersionGroup(
        id: "crystal",
        name: "クリスタル",
        generation: 2,
        pokedexNames: ["updated-johto"]
    )

    // MARK: - 第3世代

    /// ルビー・サファイア
    static let rubySapphire = VersionGroup(
        id: "ruby-sapphire",
        name: "ルビー・サファイア",
        generation: 3,
        pokedexNames: ["hoenn"]
    )

    /// エメラルド
    static let emerald = VersionGroup(
        id: "emerald",
        name: "エメラルド",
        generation: 3,
        pokedexNames: ["hoenn"]
    )

    /// ファイアレッド・リーフグリーン
    static let fireredLeafgreen = VersionGroup(
        id: "firered-leafgreen",
        name: "ファイアレッド・リーフグリーン",
        generation: 3,
        pokedexNames: ["kanto"]
    )

    // MARK: - 第4世代

    /// ダイヤモンド・パール
    static let diamondPearl = VersionGroup(
        id: "diamond-pearl",
        name: "ダイヤモンド・パール",
        generation: 4,
        pokedexNames: ["extended-sinnoh"]
    )

    /// プラチナ
    static let platinum = VersionGroup(
        id: "platinum",
        name: "プラチナ",
        generation: 4,
        pokedexNames: ["extended-sinnoh"]
    )

    /// ハートゴールド・ソウルシルバー
    static let heartgoldSoulsilver = VersionGroup(
        id: "heartgold-soulsilver",
        name: "ハートゴールド・ソウルシルバー",
        generation: 4,
        pokedexNames: ["updated-johto"]
    )

    // MARK: - 第5世代

    /// ブラック・ホワイト
    static let blackWhite = VersionGroup(
        id: "black-white",
        name: "ブラック・ホワイト",
        generation: 5,
        pokedexNames: ["updated-unova"]
    )

    /// ブラック2・ホワイト2
    static let black2White2 = VersionGroup(
        id: "black-2-white-2",
        name: "ブラック2・ホワイト2",
        generation: 5,
        pokedexNames: ["updated-unova"]
    )

    // MARK: - 第6世代

    /// X・Y
    static let xy = VersionGroup(
        id: "x-y",
        name: "X・Y",
        generation: 6,
        pokedexNames: ["kalos-central", "kalos-coastal", "kalos-mountain"]
    )

    /// オメガルビー・アルファサファイア
    static let omegaRubyAlphaSapphire = VersionGroup(
        id: "omega-ruby-alpha-sapphire",
        name: "オメガルビー・アルファサファイア",
        generation: 6,
        pokedexNames: ["hoenn"]
    )

    // MARK: - 第7世代

    /// サン・ムーン
    static let sunMoon = VersionGroup(
        id: "sun-moon",
        name: "サン・ムーン",
        generation: 7,
        pokedexNames: ["updated-alola"]
    )

    /// ウルトラサン・ウルトラムーン
    static let ultraSunUltraMoon = VersionGroup(
        id: "ultra-sun-ultra-moon",
        name: "ウルトラサン・ウルトラムーン",
        generation: 7,
        pokedexNames: ["updated-alola"]
    )

    /// Let's Go! ピカチュウ・イーブイ
    static let letsGoPikachuLetsGoEevee = VersionGroup(
        id: "lets-go-pikachu-lets-go-eevee",
        name: "Let's Go! ピカチュウ・イーブイ",
        generation: 7,
        pokedexNames: ["letsgo-kanto"]
    )

    // MARK: - 第8世代

    /// ソード・シールド
    static let swordShield = VersionGroup(
        id: "sword-shield",
        name: "ソード・シールド",
        generation: 8,
        pokedexNames: ["galar", "isle-of-armor", "crown-tundra"]
    )

    /// ブリリアントダイヤモンド・シャイニングパール
    static let brilliantDiamondShiningPearl = VersionGroup(
        id: "brilliant-diamond-shining-pearl",
        name: "ブリリアントダイヤモンド・シャイニングパール",
        generation: 8,
        pokedexNames: ["extended-sinnoh"]
    )

    /// Pokémon LEGENDS アルセウス
    static let legendsArceus = VersionGroup(
        id: "legends-arceus",
        name: "Pokémon LEGENDS アルセウス",
        generation: 8,
        pokedexNames: ["hisui"]
    )

    // MARK: - 第9世代

    /// スカーレット・バイオレット
    static let scarletViolet = VersionGroup(
        id: "scarlet-violet",
        name: "スカーレット・バイオレット",
        generation: 9,
        pokedexNames: ["paldea", "kitakami", "blueberry"]
    )

    /// 全バージョングループリスト
    static let allVersionGroups: [VersionGroup] = [
        .nationalDex,
        .redBlue,
        .yellow,
        .goldSilver,
        .crystal,
        .rubySapphire,
        .emerald,
        .fireredLeafgreen,
        .diamondPearl,
        .platinum,
        .heartgoldSoulsilver,
        .blackWhite,
        .black2White2,
        .xy,
        .omegaRubyAlphaSapphire,
        .sunMoon,
        .ultraSunUltraMoon,
        .letsGoPikachuLetsGoEevee,
        .swordShield,
        .brilliantDiamondShiningPearl,
        .legendsArceus,
        .scarletViolet
    ]
}
