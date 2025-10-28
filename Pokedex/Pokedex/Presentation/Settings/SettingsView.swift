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
                // システム言語情報の表示（読み取り専用）
                Section {
                    HStack {
                        Text(L10n.Settings.language)
                        Spacer()
                        Text(localizationManager.currentLanguage.displayName)
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Text(L10n.Settings.displaySectionHeader)
                } footer: {
                    Text("言語はデバイスの設定に従います。\nLanguage follows device settings.")
                }

                Section {
                    Picker(L10n.Settings.versionPreference, selection: $appSettings.preferredVersion) {
                        ForEach(AppSettings.PreferredVersion.allCases) { version in
                            Text(version.displayName).tag(version)
                        }
                    }
                    .pickerStyle(.segmented)
                } header: {
                    Text(L10n.Settings.dataSectionHeader)
                } footer: {
                    Text(L10n.Settings.dataSectionFooter)
                }
            }
            .navigationTitle(L10n.Settings.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(L10n.Settings.done) {
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
