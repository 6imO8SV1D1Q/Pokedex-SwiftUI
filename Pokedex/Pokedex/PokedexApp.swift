//
//  PokedexApp.swift
//  Pokedex
//
//  Created by 阿部友祐 on 2025/10/04.
//

import SwiftUI
import SwiftData

@main
struct PokedexApp: App {
    let modelContainer: ModelContainer

    init() {
        do {
            // SwiftData スキーマ定義 (Scarlet/Violet data structure)
            let schema = Schema([
                PokemonModel.self,
                MoveModel.self,
                MoveMetaModel.self,
                AbilityModel.self,
                PokedexModel.self
            ])

            // ModelConfiguration（ディスク永続化）
            let modelConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                cloudKitDatabase: .none
            )

            // ストレージディレクトリが存在しない場合は作成
            let fileManager = FileManager.default
            let storageDir = modelConfiguration.url.deletingLastPathComponent()
            if !fileManager.fileExists(atPath: storageDir.path) {
                try fileManager.createDirectory(
                    at: storageDir,
                    withIntermediateDirectories: true
                )
                print("📁 Created storage directory: \(storageDir.path)")
            }

            // ModelContainer作成（マイグレーション失敗時は古いファイルを削除）
            do {
                modelContainer = try ModelContainer(
                    for: schema,
                    configurations: [modelConfiguration]
                )

                print("✅ ModelContainer initialized successfully")
                print("📂 Storage path: \(modelConfiguration.url.path)")
            } catch {
                // スキーマ変更によるマイグレーション失敗の場合、古いストアを削除
                print("⚠️ ModelContainer initialization failed: \(error)")
                print("🔄 Deleting old store and retrying...")

                let storeURL = modelConfiguration.url
                try? FileManager.default.removeItem(at: storeURL)
                try? FileManager.default.removeItem(at: storeURL.deletingPathExtension().appendingPathExtension("store-shm"))
                try? FileManager.default.removeItem(at: storeURL.deletingPathExtension().appendingPathExtension("store-wal"))

                // 再試行
                modelContainer = try ModelContainer(
                    for: schema,
                    configurations: [modelConfiguration]
                )

                print("✅ ModelContainer re-initialized successfully after cleanup")
                print("📂 Storage path: \(modelConfiguration.url.path)")
            }

        } catch {
            fatalError("❌ Failed to initialize ModelContainer even after cleanup: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(modelContainer)
        }
    }
}

/// ContentView: ModelContextを取得してDIContainerに注入
struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var pokemonListViewModel: PokemonListViewModel?
    @State private var statsCalculatorViewModel: StatsCalculatorViewModel?
    @State private var damageCalculatorStore: DamageCalculatorStore?
    @State private var isInitialized = false

    var body: some View {
        Group {
            if let pokemonListViewModel = pokemonListViewModel,
               let statsCalculatorViewModel = statsCalculatorViewModel,
               let damageCalculatorStore = damageCalculatorStore {
                // タブ構成
                TabView {
                    // 図鑑タブ
                    PokemonListView(viewModel: pokemonListViewModel)
                        .environmentObject(LocalizationManager.shared)
                        .tabItem {
                            Label(NSLocalizedString("tab.pokedex", comment: "Pokédex tab title"), systemImage: "book.fill")
                        }

                    // 実数値計算タブ
                    StatsCalculatorView(viewModel: statsCalculatorViewModel)
                        .environmentObject(LocalizationManager.shared)
                        .tabItem {
                            Label(NSLocalizedString("tab.calculator", comment: "Calculator tab title"), systemImage: "function")
                        }

                    // ダメージ計算タブ
                    DamageCalculatorView(store: damageCalculatorStore)
                        .environmentObject(LocalizationManager.shared)
                        .tabItem {
                            Label("ダメージ計算", systemImage: "bolt.fill")
                        }
                }
            } else {
                ProgressView("初期化中...")
                    .onAppear {
                        // 重複初期化を防ぐ
                        guard !isInitialized else { return }
                        isInitialized = true

                        print("🔧 Setting up ModelContext in DIContainer...")
                        DIContainer.shared.setModelContext(modelContext)

                        print("🏗️ Creating ViewModels...")
                        pokemonListViewModel = DIContainer.shared.makePokemonListViewModel()
                        statsCalculatorViewModel = DIContainer.shared.makeStatsCalculatorViewModel()
                        damageCalculatorStore = DIContainer.shared.makeDamageCalculatorStore()

                        print("✅ App initialization completed")
                    }
            }
        }
    }
}
