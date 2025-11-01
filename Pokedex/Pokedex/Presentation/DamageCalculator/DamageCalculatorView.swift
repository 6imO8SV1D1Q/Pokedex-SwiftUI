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
                    // プリセット選択セクション
                    presetSection

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

    /// プリセット選択セクション
    private var presetSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("プリセット")
                    .font(.headline)

                Spacer()

                Button(action: {
                    Task {
                        try? await store.savePreset(name: "設定 \(store.presets.count + 1)")
                    }
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "square.and.arrow.down")
                        Text("保存")
                    }
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
            }

            if !store.presets.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(store.presets) { preset in
                            Button(action: {
                                store.loadPreset(preset)
                            }) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(preset.name)
                                        .font(.caption)
                                        .fontWeight(.medium)
                                    Text(preset.createdAt, style: .date)
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(
                                    store.selectedPreset?.id == preset.id
                                        ? Color.blue.opacity(0.2)
                                        : Color.gray.opacity(0.1)
                                )
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(
                                            store.selectedPreset?.id == preset.id
                                                ? Color.blue
                                                : Color.clear,
                                            lineWidth: 2
                                        )
                                )
                            }
                            .buttonStyle(.plain)
                            .contextMenu {
                                Button(role: .destructive) {
                                    Task {
                                        try? await store.deletePreset(preset)
                                    }
                                } label: {
                                    Label("削除", systemImage: "trash")
                                }
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
            } else {
                Text("保存されたプリセットはありません")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 8)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        .task {
            await store.loadPresets()
        }
    }

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

    /// 結果表示セクション
    private var resultSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("計算結果")
                .font(.headline)

            if let error = store.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
            }

            if let result = store.damageResult {
                VStack(alignment: .leading, spacing: 8) {
                    // HPバー可視化
                    VStack(alignment: .leading, spacing: 4) {
                        Text("ダメージ範囲")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                // 背景（最大HP）
                                Rectangle()
                                    .fill(Color.green.opacity(0.2))
                                    .frame(width: geometry.size.width, height: 24)

                                // 最大ダメージ範囲
                                Rectangle()
                                    .fill(Color.red.opacity(0.3))
                                    .frame(
                                        width: geometry.size.width * CGFloat(result.maxDamage) / CGFloat(result.defenderMaxHP),
                                        height: 24
                                    )

                                // 最小ダメージ範囲
                                Rectangle()
                                    .fill(Color.red.opacity(0.6))
                                    .frame(
                                        width: geometry.size.width * CGFloat(result.minDamage) / CGFloat(result.defenderMaxHP),
                                        height: 24
                                    )

                                // テキストオーバーレイ
                                HStack {
                                    Text("HP: \(result.defenderMaxHP)")
                                        .font(.caption2)
                                        .foregroundColor(.white)
                                        .padding(.leading, 4)
                                    Spacer()
                                }
                            }
                            .cornerRadius(4)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                        }
                        .frame(height: 24)
                    }
                    .padding(.bottom, 8)

                    HStack {
                        Text("ダメージ:")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(result.minDamage) ~ \(result.maxDamage)")
                            .font(.title3)
                            .bold()
                    }

                    HStack {
                        Text("ダメージ割合:")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(Int(Double(result.minDamage) / Double(result.defenderMaxHP) * 100))% ~ \(Int(Double(result.maxDamage) / Double(result.defenderMaxHP) * 100))%")
                            .font(.caption)
                    }

                    HStack {
                        Text("確定数:")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(result.hitsToKO)発")
                    }

                    HStack {
                        Text("撃破確率:")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(result.koChance * 100, specifier: "%.1f")%")
                    }

                    if let twoTurnKO = result.twoTurnKOChance {
                        HStack {
                            Text("2ターン撃破確率:")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("\(twoTurnKO * 100, specifier: "%.1f")%")
                        }
                    }

                    HStack {
                        Text("平均ダメージ:")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(result.averageDamage, specifier: "%.1f")")
                    }

                    Divider()

                    Text("補正倍率")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    HStack {
                        Text("タイプ一致:")
                            .font(.caption)
                        Spacer()
                        Text("×\(result.modifiers.stab, specifier: "%.2f")")
                            .font(.caption)
                    }

                    HStack {
                        Text("タイプ相性:")
                            .font(.caption)
                        Spacer()
                        Text("×\(result.modifiers.typeEffectiveness, specifier: "%.2f")")
                            .font(.caption)
                    }

                    HStack {
                        Text("総合倍率:")
                            .font(.caption)
                            .bold()
                        Spacer()
                        Text("×\(result.modifiers.total, specifier: "%.2f")")
                            .font(.caption)
                            .bold()
                    }
                }

                Button(action: {
                    Task {
                        await store.calculateDamage()
                    }
                }) {
                    HStack {
                        if store.isLoading {
                            ProgressView()
                                .progressViewStyle(.circular)
                        }
                        Text("再計算")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .disabled(store.isLoading)

            } else {
                Text("ポケモンと技を選択してください")
                    .foregroundColor(.secondary)

                Button(action: {
                    // テスト用にダミーデータを設定
                    store.battleState.attacker.pokemonId = 1
                    store.battleState.attacker.pokemonName = "テストポケモン"
                    store.battleState.attacker.baseTypes = ["normal"]
                    store.battleState.defender.pokemonId = 2
                    store.battleState.defender.pokemonName = "テストポケモン2"
                    store.battleState.defender.baseTypes = ["normal"]
                    store.battleState.selectedMoveId = 1

                    Task {
                        await store.calculateDamage()
                    }
                }) {
                    HStack {
                        if store.isLoading {
                            ProgressView()
                                .progressViewStyle(.circular)
                        }
                        Text("計算実行（テスト）")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .disabled(store.isLoading)
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
