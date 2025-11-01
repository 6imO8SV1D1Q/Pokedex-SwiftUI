//
//  DamageCalculatorView.swift
//  Pokedex
//
//  Created on 2025-11-01.
//

import SwiftUI

/// ダメージ計算画面
struct DamageCalculatorView: View {
    @StateObject var store: DamageCalculatorStore

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // セクションA: モード切替
                    battleModeSection

                    // セクションB: 攻撃側入力
                    participantSection(
                        title: "攻撃側",
                        participant: store.battleState.attacker,
                        isAttacker: true
                    )

                    // 入れ替えボタン
                    swapButton

                    // セクションC: 防御側入力
                    participantSection(
                        title: "防御側",
                        participant: store.battleState.defender,
                        isAttacker: false
                    )

                    // セクションD: バトル環境
                    environmentSection

                    // セクションF: 結果表示（Phase 2で実装）
                    resultSection
                }
                .padding()
            }
            .navigationTitle("ダメージ計算")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("リセット") {
                        store.reset()
                    }
                }
            }
        }
    }

    // MARK: - Sections

    /// バトルモード切替セクション
    private var battleModeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("バトルモード")
                .font(.headline)

            Picker("バトルモード", selection: Binding(
                get: { store.battleState.mode },
                set: { _ in store.toggleBattleMode() }
            )) {
                ForEach(BattleMode.allCases) { mode in
                    Text(mode.displayName).tag(mode)
                }
            }
            .pickerStyle(.segmented)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }

    /// 参加者（攻撃側/防御側）セクション
    private func participantSection(
        title: String,
        participant: BattleParticipantState,
        isAttacker: Bool
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)

            // ポケモン選択
            pokemonSelectionRow(participant: participant)

            // レベル
            levelRow(participant: participant, isAttacker: isAttacker)

            // テラスタル
            teraRow(participant: participant, isAttacker: isAttacker)

            // アイテム
            itemRow(participant: participant, isAttacker: isAttacker)

            // TODO: Phase 1.5で追加予定
            // - 努力値/個体値
            // - ランク補正
            // - 特性
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }

    /// ポケモン選択行
    private func pokemonSelectionRow(participant: BattleParticipantState) -> some View {
        HStack {
            Text("ポケモン:")
                .foregroundColor(.secondary)

            Spacer()

            Text(participant.pokemonName ?? "未選択")
                .foregroundColor(participant.pokemonName == nil ? .secondary : .primary)

            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
                .font(.caption)
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        // TODO: タップでポケモン選択画面へ
    }

    /// レベル行
    private func levelRow(participant: BattleParticipantState, isAttacker: Bool) -> some View {
        HStack {
            Text("レベル:")
                .foregroundColor(.secondary)

            Spacer()

            Text("\(participant.level)")
                .foregroundColor(.primary)
        }
        .padding(.vertical, 8)
    }

    /// テラスタル行
    private func teraRow(participant: BattleParticipantState, isAttacker: Bool) -> some View {
        HStack {
            Text("テラスタル:")
                .foregroundColor(.secondary)

            Spacer()

            Toggle("", isOn: Binding(
                get: { participant.isTerastallized },
                set: { _ in
                    if isAttacker {
                        store.toggleAttackerTerastallize()
                    } else {
                        store.toggleDefenderTerastallize()
                    }
                }
            ))
        }
        .padding(.vertical, 8)
    }

    /// アイテム行
    private func itemRow(participant: BattleParticipantState, isAttacker: Bool) -> some View {
        HStack {
            Text("持ち物:")
                .foregroundColor(.secondary)

            Spacer()

            Text(participant.heldItemId == nil ? "なし" : "アイテム#\(participant.heldItemId!)")
                .foregroundColor(participant.heldItemId == nil ? .secondary : .primary)

            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
                .font(.caption)
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        // TODO: タップでアイテム選択画面へ
    }

    /// 入れ替えボタン
    private var swapButton: some View {
        Button(action: {
            store.swapAttackerAndDefender()
        }) {
            HStack {
                Image(systemName: "arrow.up.arrow.down")
                Text("攻守入れ替え")
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
    }

    /// バトル環境セクション
    private var environmentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("バトル環境")
                .font(.headline)

            // 天候
            weatherRow

            // フィールド
            terrainRow

            // 壁
            screenRow
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }

    /// 天候行
    private var weatherRow: some View {
        HStack {
            Text("天候:")
                .foregroundColor(.secondary)

            Spacer()

            Picker("", selection: Binding(
                get: { store.battleState.environment.weather ?? .none },
                set: { store.battleState.environment.weather = $0 == .none ? nil : $0 }
            )) {
                ForEach(WeatherCondition.allCases) { weather in
                    Text(weather.displayName).tag(weather)
                }
            }
            .pickerStyle(.menu)
        }
        .padding(.vertical, 8)
    }

    /// フィールド行
    private var terrainRow: some View {
        HStack {
            Text("フィールド:")
                .foregroundColor(.secondary)

            Spacer()

            Picker("", selection: Binding(
                get: { store.battleState.environment.terrain ?? .none },
                set: { store.battleState.environment.terrain = $0 == .none ? nil : $0 }
            )) {
                ForEach(TerrainField.allCases) { terrain in
                    Text(terrain.displayName).tag(terrain)
                }
            }
            .pickerStyle(.menu)
        }
        .padding(.vertical, 8)
    }

    /// 壁行
    private var screenRow: some View {
        HStack {
            Text("壁:")
                .foregroundColor(.secondary)

            Spacer()

            Picker("", selection: Binding(
                get: { store.battleState.environment.screen ?? .none },
                set: { store.battleState.environment.screen = $0 == .none ? nil : $0 }
            )) {
                ForEach(ScreenEffect.allCases) { screen in
                    Text(screen.displayName).tag(screen)
                }
            }
            .pickerStyle(.menu)
        }
        .padding(.vertical, 8)
    }

    /// 結果表示セクション（Phase 2で実装）
    private var resultSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("計算結果")
                .font(.headline)

            if let result = store.damageResult {
                Text("ダメージ: \(result.minDamage) ~ \(result.maxDamage)")
                Text("撃破確率: \(result.koChance, specifier: "%.1f")%")
            } else {
                Text("ポケモンと技を選択してください")
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Preview

struct DamageCalculatorView_Previews: PreviewProvider {
    static var previews: some View {
        DamageCalculatorView(
            store: DamageCalculatorStore(
                itemProvider: ItemProvider()
            )
        )
    }
}
