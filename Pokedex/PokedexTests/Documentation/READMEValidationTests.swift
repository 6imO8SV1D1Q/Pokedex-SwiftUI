//
//  READMEValidationTests.swift
//  PokedexTests
//
//  Created on 2025-11-01.
//  Tests for validating README.md structure, links, and content
//

import XCTest

final class READMEValidationTests: XCTestCase {
    var readmeContent: String!
    var readmeURL: URL!
    
    override func setUp() {
        super.setUp()
        
        // Navigate up from test bundle to project root
        let testBundle = Bundle(for: type(of: self))
        let projectRoot = testBundle.bundleURL
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        
        readmeURL = projectRoot.appendingPathComponent("README.md")
        
        do {
            readmeContent = try String(contentsOf: readmeURL, encoding: .utf8)
        } catch {
            XCTFail("Failed to load README.md: \(error)")
        }
    }
    
    override func tearDown() {
        readmeContent = nil
        readmeURL = nil
        super.tearDown()
    }
    
    // MARK: - Structure Tests
    
    func test_readme_containsMainTitle() {
        XCTAssertTrue(
            readmeContent.contains("# Pokedex-SwiftUI"),
            "README should contain main title 'Pokedex-SwiftUI'"
        )
    }
    
    func test_readme_containsProjectDescription() {
        XCTAssertTrue(
            readmeContent.contains("SwiftUIで実装したポケモン図鑑アプリケーション"),
            "README should contain project description"
        )
        XCTAssertTrue(
            readmeContent.contains("PokéAPI v2"),
            "README should mention PokéAPI v2"
        )
    }
    
    func test_readme_containsRequiredSections() {
        let requiredSections = [
            "## 🌟 主な機能",
            "## 🏛 アーキテクチャ",
            "## 🛠 技術スタック",
            "## ⚙️ セットアップ",
            "## 📱 使い方",
            "## 🧪 テスト",
            "## 📄 ライセンス"
        ]
        
        for section in requiredSections {
            XCTAssertTrue(
                readmeContent.contains(section),
                "README should contain section: \(section)"
            )
        }
    }
    
    func test_readme_containsVersionSections() {
        let versionSections = [
            "### v4.0の新機能（開発中）",
            "### v3.0の機能（完了）",
            "### v2.0の機能（完了）",
            "### v1.0の機能（完了）"
        ]
        
        for section in versionSections {
            XCTAssertTrue(
                readmeContent.contains(section),
                "README should contain version section: \(section)"
            )
        }
    }
    
    // MARK: - Content Tests - v4.0 Features
    
    func test_readme_containsV4Features() {
        let v4Features = [
            "SwiftDataによる永続化キャッシュ",
            "プリロードデータ",
            "初回起動1秒以内",
            "図鑑選択機能",
            "実数値計算機"
        ]
        
        for feature in v4Features {
            XCTAssertTrue(
                readmeContent.contains(feature),
                "README should mention v4.0 feature: \(feature)"
            )
        }
    }
    
    func test_readme_containsPokedexTypes() {
        let pokedexTypes = [
            "全国図鑑",
            "パルデア図鑑",
            "キタカミ図鑑",
            "ブルーベリー図鑑"
        ]
        
        for pokedex in pokedexTypes {
            XCTAssertTrue(
                readmeContent.contains(pokedex),
                "README should mention Pokedex type: \(pokedex)"
            )
        }
    }
    
    func test_readme_containsStatsCalculatorFeatures() {
        let calculatorFeatures = [
            "個体値",
            "努力値",
            "性格補正",
            "レベル（1-100）",
            "個体値（0-31）",
            "努力値（0-252、合計510まで）"
        ]
        
        for feature in calculatorFeatures {
            XCTAssertTrue(
                readmeContent.contains(feature),
                "README should mention stats calculator feature: \(feature)"
            )
        }
    }
    
    func test_readme_containsPerformanceMetrics() {
        let performanceMetrics = [
            "60-90秒",
            "1秒以内",
            "3秒以内"
        ]
        
        for metric in performanceMetrics {
            XCTAssertTrue(
                readmeContent.contains(metric),
                "README should mention performance metric: \(metric)"
            )
        }
    }
    
    // MARK: - Content Tests - v3.0 Features
    
    func test_readme_containsV3Features() {
        let v3Features = [
            "フォルム切り替え",
            "タイプ相性表示",
            "進化ルート表示",
            "特性フィルター",
            "技フィルター"
        ]
        
        for feature in v3Features {
            XCTAssertTrue(
                readmeContent.contains(feature),
                "README should mention v3.0 feature: \(feature)"
            )
        }
    }
    
    func test_readme_containsFormTypes() {
        let formTypes = [
            "リージョンフォーム",
            "メガシンカ",
            "フォルムチェンジ",
            "アローラ",
            "ガラル",
            "ヒスイ",
            "パルデア"
        ]
        
        for formType in formTypes {
            XCTAssertTrue(
                readmeContent.contains(formType),
                "README should mention form type: \(formType)"
            )
        }
    }
    
    func test_readme_containsTypeMatchupDetails() {
        let matchupDetails = [
            "攻撃面",
            "防御面",
            "効果ばつぐん",
            "いまひとつ",
            "効果なし"
        ]
        
        for detail in matchupDetails {
            XCTAssertTrue(
                readmeContent.contains(detail),
                "README should mention type matchup detail: \(detail)"
            )
        }
    }
    
    // MARK: - Architecture Tests
    
    func test_readme_containsArchitectureDescription() {
        XCTAssertTrue(
            readmeContent.contains("Clean Architecture"),
            "README should mention Clean Architecture"
        )
        XCTAssertTrue(
            readmeContent.contains("MVVM"),
            "README should mention MVVM pattern"
        )
    }
    
    func test_readme_containsLayerDescriptions() {
        let layers = [
            "Domain/",
            "Data/",
            "Presentation/",
            "Application/",
            "Common/",
            "Resources/"
        ]
        
        for layer in layers {
            XCTAssertTrue(
                readmeContent.contains(layer),
                "README should mention layer: \(layer)"
            )
        }
    }
    
    func test_readme_containsKeyEntities() {
        let entities = [
            "Pokemon",
            "PokemonListItem",
            "VersionGroup",
            "MoveEntity",
            "PokemonForm",
            "TypeMatchup",
            "CalculatedStats",
            "AbilityMetadata"
        ]
        
        for entity in entities {
            XCTAssertTrue(
                readmeContent.contains(entity),
                "README should mention entity: \(entity)"
            )
        }
    }
    
    func test_readme_containsUseCases() {
        let useCases = [
            "FetchPokemonListUseCase",
            "FilterPokemonByMovesUseCase",
            "FilterPokemonByAbilityUseCase",
            "SortPokemonUseCase",
            "FetchPokemonFormsUseCase",
            "FetchTypeMatchupUseCase",
            "CalculateStatsUseCase"
        ]
        
        for useCase in useCases {
            XCTAssertTrue(
                readmeContent.contains(useCase),
                "README should mention use case: \(useCase)"
            )
        }
    }
    
    func test_readme_containsRepositories() {
        let repositories = [
            "PokemonRepository",
            "MoveRepository",
            "AbilityRepository",
            "TypeRepository"
        ]
        
        for repository in repositories {
            XCTAssertTrue(
                readmeContent.contains(repository),
                "README should mention repository: \(repository)"
            )
        }
    }
    
    func test_readme_containsCacheActors() {
        let caches = [
            "MoveCache",
            "TypeCache",
            "FormCache",
            "AbilityCache",
            "LocationCache"
        ]
        
        for cache in caches {
            XCTAssertTrue(
                readmeContent.contains(cache),
                "README should mention cache: \(cache)"
            )
        }
    }
    
    func test_readme_containsPersistenceModels() {
        let models = [
            "PokemonModel",
            "MoveModel",
            "AbilityModel",
            "PokedexModel",
            "PreloadedDataLoader"
        ]
        
        for model in models {
            XCTAssertTrue(
                readmeContent.contains(model),
                "README should mention persistence model: \(model)"
            )
        }
    }
    
    // MARK: - Technology Stack Tests
    
    func test_readme_containsTechnologyStack() {
        XCTAssertTrue(
            readmeContent.contains("Swift 6.0"),
            "README should mention Swift 6.0"
        )
        XCTAssertTrue(
            readmeContent.contains("SwiftUI"),
            "README should mention SwiftUI"
        )
        XCTAssertTrue(
            readmeContent.contains("SwiftData"),
            "README should mention SwiftData"
        )
        XCTAssertTrue(
            readmeContent.contains("iOS 17.0"),
            "README should mention iOS 17.0"
        )
    }
    
    func test_readme_containsDependencies() {
        let dependencies = [
            ("Kingfisher", "8.6.0"),
            ("PokemonAPI", "7.0.3")
        ]
        
        for (name, version) in dependencies {
            XCTAssertTrue(
                readmeContent.contains(name),
                "README should mention dependency: \(name)"
            )
            XCTAssertTrue(
                readmeContent.contains(version),
                "README should mention version: \(version)"
            )
        }
    }
    
    // MARK: - Setup Tests
    
    func test_readme_containsSetupInstructions() {
        let setupSteps = [
            "git clone",
            "cd Pokedex-SwiftUI",
            "open Pokedex/Pokedex.xcodeproj"
        ]
        
        for step in setupSteps {
            XCTAssertTrue(
                readmeContent.contains(step),
                "README should contain setup step: \(step)"
            )
        }
    }
    
    func test_readme_containsRequirements() {
        let requirements = [
            "Xcode 15.0+",
            "iOS 17.0+",
            "Swift 6.0+"
        ]
        
        for requirement in requirements {
            XCTAssertTrue(
                readmeContent.contains(requirement),
                "README should mention requirement: \(requirement)"
            )
        }
    }
    
    // MARK: - Usage Tests
    
    func test_readme_containsUsageInstructions() {
        let usageTopics = [
            "図鑑タブ",
            "実数値計算機タブ",
            "図鑑選択",
            "フィルター機能",
            "ソート機能"
        ]
        
        for topic in usageTopics {
            XCTAssertTrue(
                readmeContent.contains(topic),
                "README should mention usage topic: \(topic)"
            )
        }
    }
    
    func test_readme_containsTabConfiguration() {
        let tabs = [
            "ポケモン図鑑タブ",
            "実数値計算機タブ"
        ]
        
        for tab in tabs {
            XCTAssertTrue(
                readmeContent.contains(tab),
                "README should mention tab: \(tab)"
            )
        }
    }
    
    // MARK: - Testing Section Tests
    
    func test_readme_containsTestingInformation() {
        XCTAssertTrue(
            readmeContent.contains("xcodebuild test"),
            "README should mention xcodebuild test command"
        )
    }
    
    func test_readme_mentionsTestCategories() {
        let testCategories = [
            "ユニットテスト",
            "統合テスト",
            "パフォーマンステスト"
        ]
        
        for category in testCategories {
            XCTAssertTrue(
                readmeContent.contains(category),
                "README should mention test category: \(category)"
            )
        }
    }
    
    func test_readme_containsTestCoverage() {
        let coverageInfo = [
            "Domain",
            "Data",
            "Presentation"
        ]
        
        for info in coverageInfo {
            XCTAssertTrue(
                readmeContent.contains(info),
                "README should mention coverage info: \(info)"
            )
        }
    }
    
    // MARK: - Link Validation Tests
    
    func test_readme_containsExternalLinks() {
        let externalLinks = [
            "https://pokeapi.co/",
            "https://github.com/onevcat/Kingfisher",
            "https://github.com/kinkofer/PokemonAPI"
        ]
        
        for link in externalLinks {
            XCTAssertTrue(
                readmeContent.contains(link),
                "README should contain external link: \(link)"
            )
        }
    }
    
    func test_readme_internalLinksPointToExistingFiles() {
        let internalLinks = [
            "docs/implementation_status.md",
            "docs/future_improvements.md",
            "docs/v4/requirements.md",
            "docs/v4/design.md",
            "docs/v4/prompts.md",
            "docs/v3/requirements.md",
            "docs/v3/design.md",
            "docs/v3/prompts.md",
            "docs/v2/requirements.md",
            "docs/v2/design.md",
            "CLAUDE.md"
        ]
        
        let projectRoot = readmeURL.deletingLastPathComponent()
        
        for linkPath in internalLinks {
            let fileURL = projectRoot.appendingPathComponent(linkPath)
            XCTAssertTrue(
                FileManager.default.fileExists(atPath: fileURL.path),
                "Linked file should exist: \(linkPath)"
            )
        }
    }
    
    func test_readme_containsDocumentationLinks() {
        XCTAssertTrue(
            readmeContent.contains("[実装状況]"),
            "README should contain link to implementation status"
        )
        XCTAssertTrue(
            readmeContent.contains("[今後の改善予定]"),
            "README should contain link to future improvements"
        )
        XCTAssertTrue(
            readmeContent.contains("[Claude Code開発ガイド]"),
            "README should contain link to Claude Code guide"
        )
    }
    
    // MARK: - Markdown Syntax Tests
    
    func test_readme_codeBlocksAreProperlyFormatted() {
        let codeBlockMarkers = readmeContent.components(separatedBy: "```")
        // Code blocks come in pairs (opening and closing)
        XCTAssertTrue(
            codeBlockMarkers.count % 2 == 1,
            "Code blocks should be properly closed (odd number of ``` markers)"
        )
    }
    
    func test_readme_containsProperHeadingHierarchy() {
        let lines = readmeContent.components(separatedBy: .newlines)
        var hasH1 = false
        var hasH2 = false
        var hasH3 = false
        
        for line in lines {
            if line.hasPrefix("# ") && !line.hasPrefix("## ") {
                hasH1 = true
            } else if line.hasPrefix("## ") && !line.hasPrefix("### ") {
                hasH2 = true
            } else if line.hasPrefix("### ") && !line.hasPrefix("#### ") {
                hasH3 = true
            }
        }
        
        XCTAssertTrue(hasH1, "README should have H1 headings")
        XCTAssertTrue(hasH2, "README should have H2 headings")
        XCTAssertTrue(hasH3, "README should have H3 headings")
    }
    
    func test_readme_listItemsAreProperlyFormatted() {
        let lines = readmeContent.components(separatedBy: .newlines)
        var hasUnorderedLists = false
        var hasOrderedLists = false
        
        for line in lines {
            if line.hasPrefix("- ") || line.hasPrefix("* ") {
                hasUnorderedLists = true
            }
            if line.range(of: "^\\d+\\. ", options: .regularExpression) != nil {
                hasOrderedLists = true
            }
        }
        
        XCTAssertTrue(hasUnorderedLists, "README should contain unordered lists")
        XCTAssertTrue(hasOrderedLists, "README should contain ordered lists")
    }
    
    // MARK: - Version Consistency Tests
    
    func test_readme_versionNumbersAreConsistent() {
        let versionPattern = "v(\\d+\\.\\d+(?:\\.\\d+)?)"
        guard let regex = try? NSRegularExpression(pattern: versionPattern) else {
            XCTFail("Invalid regex pattern")
            return
        }
        let matches = regex.matches(
            in: readmeContent,
            range: NSRange(readmeContent.startIndex..., in: readmeContent)
        )
        
        var versions = Set<String>()
        for match in matches {
            if let range = Range(match.range(at: 1), in: readmeContent) {
                versions.insert(String(readmeContent[range]))
            }
        }
        
        let expectedVersions: Set<String> = ["1.0", "2.0", "3.0", "4.0", "5.0"]
        XCTAssertTrue(
            versions.isSuperset(of: expectedVersions),
            "README should mention all expected versions: \(expectedVersions)"
        )
    }
    
    func test_readme_containsVersionHistory() {
        XCTAssertTrue(
            readmeContent.contains("v4.0（開発中）"),
            "README should indicate v4.0 is in development"
        )
        XCTAssertTrue(
            readmeContent.contains("v3.0（完了）") || readmeContent.contains("v3.0の機能（完了）"),
            "README should indicate v3.0 is completed"
        )
        XCTAssertTrue(
            readmeContent.contains("v2.0（完了）") || readmeContent.contains("v2.0の機能（完了）"),
            "README should indicate v2.0 is completed"
        )
    }
    
    // MARK: - Credits and License Tests
    
    func test_readme_containsCredits() {
        let credits = [
            "PokéAPI",
            "Kingfisher",
            "PokemonAPI",
            "任天堂",
            "クリーチャーズ",
            "ゲームフリーク"
        ]
        
        for credit in credits {
            XCTAssertTrue(
                readmeContent.contains(credit),
                "README should credit: \(credit)"
            )
        }
    }
    
    func test_readme_containsLicenseInformation() {
        XCTAssertTrue(
            readmeContent.contains("MIT License"),
            "README should mention MIT License"
        )
    }
    
    func test_readme_containsContactInformation() {
        XCTAssertTrue(
            readmeContent.contains("Yusuke Abe"),
            "README should contain author name"
        )
        XCTAssertTrue(
            readmeContent.contains("2025-10-04"),
            "README should contain creation date"
        )
    }
    
    // MARK: - Performance Table Tests
    
    func test_readme_containsPerformanceComparisonTable() {
        XCTAssertTrue(
            readmeContent.contains("| 項目 |"),
            "README should contain performance comparison table"
        )
        XCTAssertTrue(
            readmeContent.contains("v3.0（旧）"),
            "README should compare v3.0 performance"
        )
        XCTAssertTrue(
            readmeContent.contains("v4.0（新）"),
            "README should show v4.0 performance"
        )
    }
    
    // MARK: - Emoji Tests
    
    func test_readme_usesEmojisForVisualEnhancement() {
        let expectedEmojis = ["🌟", "🏛", "🛠", "⚙️", "📱", "⚡️", "🧪", "🐛", "📈", "📚", "📄", "🙏", "🤝", "📧"]
        
        var foundEmojis = 0
        for emoji in expectedEmojis where readmeContent.contains(emoji) {
            foundEmojis += 1
        }
        
        XCTAssertGreaterThan(
            foundEmojis,
            10,
            "README should use emojis for visual enhancement (found \(foundEmojis))"
        )
    }
    
    // MARK: - Future Plans Tests
    
    func test_readme_containsFuturePlans() {
        XCTAssertTrue(
            readmeContent.contains("v5.0以降") || readmeContent.contains("今後の予定"),
            "README should mention future plans"
        )
    }
    
    func test_readme_containsPlannedFeatures() {
        let plannedFeatures = [
            "お気に入り機能",
            "タイプ相性チェッカー",
            "ポケモン比較機能"
        ]
        
        for feature in plannedFeatures {
            XCTAssertTrue(
                readmeContent.contains(feature),
                "README should mention planned feature: \(feature)"
            )
        }
    }
    
    // MARK: - Edge Case Tests
    
    func test_readme_isNotEmpty() {
        XCTAssertFalse(
            readmeContent.isEmpty,
            "README should not be empty"
        )
    }
    
    func test_readme_hasReasonableLength() {
        let lineCount = readmeContent.components(separatedBy: .newlines).count
        XCTAssertGreaterThan(
            lineCount,
            200,
            "README should have substantial content (found \(lineCount) lines)"
        )
    }
    
    func test_readme_doesNotContainPlaceholders() {
        let placeholders = ["TODO", "FIXME", "XXX", "PLACEHOLDER", "youruser name"]
        
        for placeholder in placeholders {
            XCTAssertFalse(
                readmeContent.lowercased().contains(placeholder.lowercased()),
                "README should not contain placeholder: \(placeholder)"
            )
        }
    }
}