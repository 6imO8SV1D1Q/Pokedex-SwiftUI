//
//  AppSettings.swift
//  Pokedex
//
//  Created on 2025-10-22.
//

import Foundation
import Combine

/// アプリ全体の設定を管理
final class AppSettings: ObservableObject {
    static let shared = AppSettings()

    /// スカーレット・バイオレットのどちらのバージョンを優先するか
    @Published var preferredVersion: PreferredVersion {
        didSet {
            UserDefaults.standard.set(preferredVersion.rawValue, forKey: "preferredVersion")
        }
    }

    /// 優先バージョンの選択肢
    enum PreferredVersion: String, CaseIterable, Identifiable {
        case scarlet = "scarlet"
        case violet = "violet"

        var id: String { rawValue }

        var displayName: String {
            switch self {
            case .scarlet: return "スカーレット"
            case .violet: return "バイオレット"
            }
        }
    }

    private init() {
        if let savedValue = UserDefaults.standard.string(forKey: "preferredVersion"),
           let version = PreferredVersion(rawValue: savedValue) {
            self.preferredVersion = version
        } else {
            // デフォルトはスカーレット
            self.preferredVersion = .scarlet
        }
    }
}
