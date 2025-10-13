//
//  Pokemon.swift
//  Pokedex
//
//  Created on 2025-10-04.
//

import Foundation
import SwiftUI

/// ポケモンのエンティティ
///
/// ポケモンの基本情報、タイプ、ステータス、特性などを保持します。
/// PokéAPIから取得したデータをアプリ内で扱いやすい形に変換したものです。
struct Pokemon: Identifiable, Codable, Hashable {
    // MARK: - Properties

    /// ポケモンの図鑑番号（一意の識別子）
    let id: Int

    /// ポケモンの種族ID（リージョンフォームなどで共通）
    let speciesId: Int

    /// ポケモンの名前（英語名、小文字）
    let name: String

    /// ポケモンの日本語名（v4.0追加）
    let nameJa: String?

    /// 分類（英語、例: "Mouse Pokémon"）（v4.0追加）
    let genus: String?

    /// 分類（日本語、例: "ねずみポケモン"）（v4.0追加）
    let genusJa: String?

    /// 身長（デシメートル単位）
    let height: Int

    /// 体重（ヘクトグラム単位）
    let weight: Int

    /// ポケモン区分（v4.0追加: normal/legendary/mythical）
    let category: String?

    /// タイプ（最大2つ）
    let types: [PokemonType]

    /// ステータス（種族値）
    let stats: [PokemonStat]

    /// 特性
    let abilities: [PokemonAbility]

    /// 画像URL
    let sprites: PokemonSprites

    /// 習得技
    let moves: [PokemonMove]

    /// このポケモンが登場可能な世代リスト（movesから判定）
    let availableGenerations: [Int]

    /// 全国図鑑番号（v4.0追加）
    let nationalDexNumber: Int?

    /// タマゴグループ（v4.0追加）
    let eggGroups: [String]?

    /// 性別比（v4.0追加: -1=性別なし、0=オスのみ、8=メスのみ）
    let genderRate: Int?

    /// 地方図鑑番号（v4.0追加: {"paldea": 25, "kitakami": 196}）
    let pokedexNumbers: [String: Int]?

    /// 関連フォームID配列（v4.0追加）
    let varieties: [Int]?

    /// 進化情報（v4.0追加）
    let evolutionChain: PokemonEvolution?

    // MARK: - Hashable

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Pokemon, rhs: Pokemon) -> Bool {
        lhs.id == rhs.id
    }

    // MARK: - Computed Properties

    /// 身長をメートル単位で取得
    /// - Returns: 身長（メートル）
    var heightInMeters: Double {
        Double(height) / 10.0
    }

    /// 体重をキログラム単位で取得
    /// - Returns: 体重（キログラム）
    var weightInKilograms: Double {
        Double(weight) / 10.0
    }

    /// 図鑑番号の表示用フォーマット
    /// - Returns: 3桁0埋めされた図鑑番号（例: "#001"）
    var formattedId: String {
        let dexNumber = nationalDexNumber ?? speciesId
        return String(format: "#%03d", dexNumber)
    }

    /// 表示用の名前（日本語優先、なければ英語）
    /// - Returns: 日本語名、または先頭が大文字の英語名
    var displayName: String {
        nameJa ?? name.capitalized
    }

    /// 種族値の合計
    /// - Returns: 全ステータスの種族値の合計
    var totalBaseStat: Int {
        stats.reduce(0) { $0 + $1.baseStat }
    }

    /// 表示用の画像URL（フォールバック処理付き）
    /// 一部のフォームは専用画像がないため、nationalDexNumberを使用してフォールバック
    /// - Returns: 表示に使用する画像URL
    var displayImageURL: String? {
        // 専用画像がないフォーム（nationalDexNumberの画像を使用）
        // 注: rockruff-own-tempoはJSONで正しいスプライトを設定済みのため除外
        let fallbackForms: [String] = []

        if fallbackForms.contains(name), let natDexNum = nationalDexNumber {
            // PokeAPIの公式アートワークURLを使用
            return "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/\(natDexNum).png"
        }

        return sprites.preferredImageURL
    }

    /// このフォルムが登場可能な最後の世代番号（nilの場合は制限なし）
    /// - Returns: 最終登場世代、制限がない場合はnil。バトル専用フォームは0（表示しない）
    var lastAvailableGeneration: Int? {
        // バトル専用・ビジュアル変更のみのフォーム: 表示しない
        // ミミッキュ（ばれたすがた）
        if name.contains("-busted") {
            return 0
        }

        // ぬしポケモン: 表示しない（通常フォームと性能同じ）
        if name.contains("-totem") {
            return 0
        }

        // コライドン・ミライドンのバトルフォーム: 表示しない
        if name.contains("koraidon-") && name != "koraidon" {
            return 0
        }
        if name.contains("miraidon-") && name != "miraidon" {
            return 0
        }

        // 見た目だけが違うフォーム（cosmetic forms）: 表示しない
        // メテノの色違いフォーム
        if name.hasPrefix("minior-") && name != "minior" {
            return 0
        }
        // ビビヨンの模様違い
        if name.hasPrefix("vivillon-") && name != "vivillon" {
            return 0
        }
        // フラベベ/フラエッテ/フラージェスの花の色違い
        if (name.hasPrefix("flabebe-") || name.hasPrefix("floette-") || name.hasPrefix("florges-")) &&
           !name.contains("eternal") {  // フラエッテ-エターナルは特別なので除外しない
            return 0
        }
        // トリミアンのトリミング
        if name.hasPrefix("furfrou-") && name != "furfrou" {
            return 0
        }
        // 相棒ピカチュウ/イーブイ: 第7世代のみ（Let's Go専用）
        if name == "pikachu-starter" || name == "eevee-starter" {
            return 7
        }

        // ピカチュウの特殊フォーム（詳細画面で表示するため一覧には出さない）
        if name.hasPrefix("pikachu-") && name != "pikachu" && name != "pikachu-gmax" {
            return 0
        }

        // 性能差のないマイナーチェンジフォーム
        // マギアナ（500年前の色）
        if name == "magearna-original" {
            return 0
        }
        // ウッウ（うのミサイル/丸のみ）: バトル中の見た目変化
        if name.hasPrefix("cramorant-") && name != "cramorant" {
            return 0
        }
        // ザルード（とうちゃん）
        if name == "zarude-dada" {
            return 0
        }
        // ワッカネズミ/イッカネズミ（3匹/4匹家族）
        if name.hasPrefix("maushold-") {
            return 0
        }
        // シャリタツ（そった/たれた/のびた）
        if name.hasPrefix("tatsugiri-") {
            return 0
        }
        // ノココッチ（2節/3節）
        if name.hasPrefix("dudunsparce-") {
            return 0
        }
        // コレクレー（はこフォルム/とほフォルム）
        if name == "gimmighoul-roaming" {
            return 0
        }

        // キョダイマックス: 詳細画面で表示するため一覧には出さない
        // 種族値も特性も変わらないため
        if name.contains("-gmax") {
            return 0
        }

        // メガシンカ: 第7世代まで（第8世代以降は削除）
        if name.contains("-mega") {
            return 7
        }

        // ゲンシカイキ: 第7世代まで（第8世代以降は削除）
        if name.contains("-primal") {
            return 7
        }

        // その他のフォームは制限なし
        return nil
    }

    /// このフォルムが初登場した世代番号
    /// - Returns: 初登場世代（1-9）、通常フォームの場合はspeciesIdから判定
    var introductionGeneration: Int {
        // リージョンフォームの判定
        if name.contains("-alola") {
            return 7  // 第7世代（サン・ムーン）
        }
        if name.contains("-galar") {
            return 8  // 第8世代（ソード・シールド）
        }
        if name.contains("-hisui") {
            return 8  // 第8世代（レジェンズアルセウス）
        }
        if name.contains("-paldea") {
            return 9  // 第9世代（スカーレット・バイオレット）
        }

        // キョダイマックス: 第8世代専用（第9世代以降は削除された機能）
        if name.contains("-gmax") {
            return 8
        }

        // ピカチュウの特殊フォーム
        // コスプレピカチュウ: 第6世代（ORAS）
        if name.hasPrefix("pikachu-rock-star") || name.hasPrefix("pikachu-belle") ||
           name.hasPrefix("pikachu-pop-star") || name.hasPrefix("pikachu-phd") ||
           name.hasPrefix("pikachu-libre") || name.hasPrefix("pikachu-cosplay") {
            return 6
        }
        // キャップピカチュウ: 第7世代（サン・ムーン）
        if name.contains("-cap") && !name.contains("-gmax") {
            return 7
        }
        // 相棒ピカチュウ/イーブイ: 第7世代（Let's Go）
        if name.hasPrefix("pikachu-starter") || name.hasPrefix("pikachu-partner") ||
           name == "eevee-starter" {
            return 7
        }
        // ワールドキャップピカチュウ: 第8世代
        if name.hasPrefix("pikachu-world-cap") {
            return 8
        }

        // フォルムチェンジの判定（基本フォームと同じ世代）
        // Rotomの各フォーム: 第4世代で追加（プラチナ）
        if name.hasPrefix("rotom-") {
            return 4
        }

        // Deoxysの各フォルム: 第3世代で追加
        if name.hasPrefix("deoxys-") {
            return 3
        }

        // メガシンカ: 第6世代
        if name.contains("-mega") {
            return 6
        }

        // ゲンシカイキ: 第6世代
        if name.contains("-primal") {
            return 6
        }

        // その他の特殊フォームは通常フォームと同じ世代とみなす
        // speciesIdから世代を判定
        switch speciesId {
        case 1...151:
            return 1
        case 152...251:
            return 2
        case 252...386:
            return 3
        case 387...493:
            return 4
        case 494...649:
            return 5
        case 650...721:
            return 6
        case 722...809:
            return 7
        case 810...905:
            return 8
        case 906...1025:
            return 9
        default:
            return 1  // デフォルト
        }
    }

    /// 種族値の表示文字列
    /// - Returns: "HP-攻撃-防御-特攻-特防-素早さ (合計)" 形式の文字列
    var baseStatsDisplay: String {
        let hp = stats.first { $0.name == "hp" }?.baseStat ?? 0
        let attack = stats.first { $0.name == "attack" }?.baseStat ?? 0
        let defense = stats.first { $0.name == "defense" }?.baseStat ?? 0
        let specialAttack = stats.first { $0.name == "special-attack" }?.baseStat ?? 0
        let specialDefense = stats.first { $0.name == "special-defense" }?.baseStat ?? 0
        let speed = stats.first { $0.name == "speed" }?.baseStat ?? 0

        return "\(hp)-\(attack)-\(defense)-\(specialAttack)-\(specialDefense)-\(speed) (\(totalBaseStat))"
    }

    /// 特性の表示文字列
    /// - Returns: 通常特性と隠れ特性を含む表示用文字列
    var abilitiesDisplay: String {
        if abilities.isEmpty {
            return "-"
        }

        let normalAbilities = abilities.filter { !$0.isHidden }
        let hiddenAbilities = abilities.filter { $0.isHidden }

        var parts: [String] = []

        if !normalAbilities.isEmpty {
            parts.append(normalAbilities.map { $0.nameJa ?? $0.name.capitalized }.joined(separator: " "))
        }

        if !hiddenAbilities.isEmpty {
            parts.append(hiddenAbilities.map { $0.nameJa ?? $0.name.capitalized }.joined(separator: " "))
        }

        return parts.isEmpty ? "-" : parts.joined(separator: " ")
    }

    /// 特性の表示文字列（グリッド用、改行区切り）
    /// - Returns: 改行で区切られた特性の文字列
    var abilitiesDisplayMultiline: String {
        if abilities.isEmpty {
            return "-"
        }

        return abilities.map { $0.nameJa ?? $0.name.capitalized }.joined(separator: "\n")
    }
}

// MARK: - PokemonType

/// ポケモンのタイプ
///
/// ポケモンのタイプ情報（ほのお、みず、など）を保持します。
/// タイプカラーと日本語名も提供します。
struct PokemonType: Codable, Identifiable, Hashable {
    let id = UUID()

    /// タイプスロット（1または2）
    let slot: Int

    /// タイプ名（英語、小文字）
    let name: String

    /// タイプ名（日本語）
    let nameJa: String?

    enum CodingKeys: String, CodingKey {
        case slot, name, nameJa
    }

    // Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(slot)
        hasher.combine(name)
    }

    static func == (lhs: PokemonType, rhs: PokemonType) -> Bool {
        lhs.slot == rhs.slot && lhs.name == rhs.name
    }

    /// 言語に応じたタイプ名を取得
    /// - Parameter language: 表示言語
    /// - Returns: タイプ名
    func displayName(language: AppLanguage) -> String {
        switch language {
        case .japanese:
            return nameJa ?? japaneseName
        case .english:
            return name.capitalized
        }
    }

    /// タイプの日本語名（フォールバック用）
    /// - Returns: 日本語のタイプ名（例: "ほのお", "みず"）
    var japaneseName: String {
        switch name.lowercased() {
        case "normal": return "ノーマル"
        case "fire": return "ほのお"
        case "water": return "みず"
        case "grass": return "くさ"
        case "electric": return "でんき"
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
        default: return name.capitalized
        }
    }

    /// ポケモン スカーレット・バイオレット 公式タイプカラー
    /// - Returns: タイプに対応する色
    var color: Color {
        switch name.lowercased() {
        case "normal":
            return Color(red: 159/255, green: 161/255, blue: 159/255)
        case "fire":
            return Color(red: 230/255, green: 40/255, blue: 41/255)
        case "water":
            return Color(red: 53/255, green: 126/255, blue: 199/255)
        case "grass":
            return Color(red: 99/255, green: 187/255, blue: 68/255)
        case "electric":
            return Color(red: 238/255, green: 213/255, blue: 53/255)
        case "ice":
            return Color(red: 116/255, green: 206/255, blue: 192/255)
        case "fighting":
            return Color(red: 206/255, green: 64/255, blue: 86/255)
        case "poison":
            return Color(red: 185/255, green: 127/255, blue: 201/255)
        case "ground":
            return Color(red: 217/255, green: 119/255, blue: 70/255)
        case "flying":
            return Color(red: 139/255, green: 170/255, blue: 229/255)
        case "psychic":
            return Color(red: 243/255, green: 102/255, blue: 185/255)
        case "bug":
            return Color(red: 145/255, green: 193/255, blue: 47/255)
        case "rock":
            return Color(red: 199/255, green: 183/255, blue: 139/255)
        case "ghost":
            return Color(red: 82/255, green: 105/255, blue: 172/255)
        case "dragon":
            return Color(red: 11/255, green: 109/255, blue: 195/255)
        case "dark":
            return Color(red: 90/255, green: 83/255, blue: 102/255)
        case "steel":
            return Color(red: 90/255, green: 142/255, blue: 161/255)
        case "fairy":
            return Color(red: 236/255, green: 143/255, blue: 230/255)
        default:
            return Color.gray
        }
    }

    /// タイプバッジのテキスト色（アクセシビリティ考慮）
    /// - Returns: 背景色に応じて適切なテキスト色（黒または白）
    var textColor: Color {
        switch name.lowercased() {
        case "electric", "ice":
            // 明るい背景色には黒文字
            return Color.black
        default:
            // それ以外は白文字
            return Color.white
        }
    }
}

// MARK: - PokemonStat

/// ポケモンのステータス（種族値）
///
/// HP、こうげき、ぼうぎょなどのステータス情報を保持します。
struct PokemonStat: Codable, Identifiable, Hashable {
    let id = UUID()

    /// ステータス名（英語）
    let name: String

    /// 種族値
    let baseStat: Int

    /// 日本語表示名
    /// - Returns: 日本語のステータス名
    var displayName: String {
        switch name {
        case "hp": return "HP"
        case "attack": return "こうげき"
        case "defense": return "ぼうぎょ"
        case "special-attack": return "とくこう"
        case "special-defense": return "とくぼう"
        case "speed": return "すばやさ"
        default: return name
        }
    }

    enum CodingKeys: String, CodingKey {
        case name
        case baseStat = "base_stat"
    }

    // Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(baseStat)
    }

    static func == (lhs: PokemonStat, rhs: PokemonStat) -> Bool {
        lhs.name == rhs.name && lhs.baseStat == rhs.baseStat
    }
}

// MARK: - PokemonAbility

/// ポケモンの特性
///
/// ポケモンの特性情報（通常特性と隠れ特性）を保持します。
struct PokemonAbility: Codable, Identifiable, Hashable {
    let id = UUID()

    /// 特性名（英語）
    let name: String

    /// 特性名（日本語）
    let nameJa: String?

    /// 隠れ特性かどうか
    let isHidden: Bool

    enum CodingKeys: String, CodingKey {
        case name
        case nameJa
        case isHidden = "is_hidden"
    }

    /// 表示用の名前（隠れ特性の場合は注釈付き）
    /// - Returns: 表示用の特性名
    var displayName: String {
        let baseName = nameJa ?? name.capitalized
        return isHidden ? "\(baseName) (隠れ特性)" : baseName
    }

    // Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(isHidden)
    }

    static func == (lhs: PokemonAbility, rhs: PokemonAbility) -> Bool {
        lhs.name == rhs.name && lhs.isHidden == rhs.isHidden
    }
}

// MARK: - PokemonSprites

/// ポケモンの画像URL
///
/// 通常画像と色違い画像のURLを保持します。
/// 複数のソース（デフォルト、Home）から最適な画像を選択できます。
struct PokemonSprites: Codable, Hashable {
    /// デフォルトの正面画像URL
    let frontDefault: String?

    /// 色違いの正面画像URL
    let frontShiny: String?

    /// その他の画像ソース
    let other: OtherSprites?

    struct OtherSprites: Codable, Hashable {
        let home: HomeSprites?

        struct HomeSprites: Codable, Hashable {
            let frontDefault: String?
            let frontShiny: String?

            enum CodingKeys: String, CodingKey {
                case frontDefault = "front_default"
                case frontShiny = "front_shiny"
            }
        }
    }

    /// 優先順位に基づいた画像URL（Home > デフォルト）
    /// - Returns: 最適な通常画像のURL
    var preferredImageURL: String? {
        other?.home?.frontDefault ?? frontDefault
    }

    /// 色違い画像のURL
    /// - Returns: 最適な色違い画像のURL
    var shinyImageURL: String? {
        other?.home?.frontShiny ?? frontShiny
    }

    enum CodingKeys: String, CodingKey {
        case frontDefault = "front_default"
        case frontShiny = "front_shiny"
        case other
    }
}

// MARK: - PokemonEvolution

/// ポケモンの進化情報
///
/// 進化チェーンID、進化段階、進化先・進化元の情報を保持します。
struct PokemonEvolution: Codable, Hashable {
    /// 進化チェーンID
    let chainId: Int

    /// 進化段階（1=第一段階、2=第二段階、3=最終進化）
    let evolutionStage: Int

    /// 進化元のポケモンID
    let evolvesFrom: Int?

    /// 進化先のポケモンID配列（空なら最終進化）
    let evolvesTo: [Int]

    /// 進化のきせきが使用可能か
    let canUseEviolite: Bool

    /// 最終進化形かどうか
    var isFinalEvolution: Bool {
        evolvesTo.isEmpty
    }
}
