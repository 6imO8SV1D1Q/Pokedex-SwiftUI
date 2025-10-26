//
//  SettingsView.swift
//  Pokedex
//
//  Created on 2025-10-12.
//

import SwiftUI

/// 設定画面
struct SettingsView: View {
    @EnvironmentObject private var localizationManager: LocalizationManager
    @ObservedObject private var appSettings = AppSettings.shared
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("言語", selection: $localizationManager.currentLanguage) {
                        ForEach(AppLanguage.allCases) { language in
                            Text(language.displayName).tag(language)
                        }
                    }
                    .pickerStyle(.segmented)
                } header: {
                    Text("表示設定")
                } footer: {
                    Text("アプリの表示言語を変更できます。タイプ名などが選択した言語で表示されます。")
                }

                Section {
                    Picker("図鑑説明バージョン", selection: $appSettings.preferredVersion) {
                        ForEach(AppSettings.PreferredVersion.allCases) { version in
                            Text(version.displayName).tag(version)
                        }
                    }
                    .pickerStyle(.segmented)
                } header: {
                    Text("図鑑データ")
                } footer: {
                    Text("スカーレット・バイオレットで図鑑説明が異なる場合、どちらを表示するか選択できます。")
                }
            }
            .navigationTitle("設定")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完了") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(LocalizationManager.shared)
}
