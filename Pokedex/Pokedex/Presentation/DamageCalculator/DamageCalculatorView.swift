//
//  DamageCalculatorView.swift
//  Pokedex
//
//  Created as part of the v5 damage calculator experience.
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

struct DamageCalculatorView: View {
    @EnvironmentObject private var localizationManager: LocalizationManager
    @StateObject private var viewModel: DamageCalculatorViewModel
    @State private var showCopyConfirmation = false

    init(viewModel: DamageCalculatorViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    dataStatusView
                    modeSection
                    participantSection(title: L10n.DamageCalculator.sectionAttacker, isAttacker: true)
                    participantSection(title: L10n.DamageCalculator.sectionDefender, isAttacker: false)
                    environmentSection
                    turnPlanSection
                    resultSection
                }
                .padding(.horizontal)
                .padding(.bottom, 32)
            }
            .navigationTitle(L10n.DamageCalculator.title)
            .refreshable {
                viewModel.loadInitialData(force: true)
            }
        }
        .onAppear {
            viewModel.updateLanguage(localizationManager.currentLanguage)
            viewModel.loadInitialData()
        }
        .onChange(of: localizationManager.currentLanguage) { newLanguage in
            viewModel.updateLanguage(newLanguage)
        }
        .alert(L10n.DamageCalculator.statusCopied, isPresented: $showCopyConfirmation) {
            Button(L10n.Common.ok) { }
        }
    }

    // MARK: - Sections

    private var dataStatusView: some View {
        VStack(alignment: .leading, spacing: 8) {
            if viewModel.isLoadingData {
                HStack(spacing: 8) {
                    ProgressView()
                    Text(L10n.DamageCalculator.statusLoading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            } else if let error = viewModel.errorMessage {
                VStack(alignment: .leading, spacing: 8) {
                    Text(L10n.DamageCalculator.statusError)
                        .font(.headline)
                        .foregroundStyle(.red)
                    Text(verbatim: error)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    Button(L10n.DamageCalculator.Button.retry) {
                        viewModel.loadInitialData(force: true)
                    }
                    .buttonStyle(.borderedProminent)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private var modeSection: some View {
        GroupBox(label: Label(L10n.DamageCalculator.sectionMode, systemImage: "gearshape.2.fill")) {
            VStack(alignment: .leading, spacing: 12) {
                Picker("", selection: $viewModel.battleMode) {
                    ForEach(DamageCalculatorViewModel.BattleMode.allCases) { mode in
                        Text(LocalizedStringKey(mode.localizationKey)).tag(mode)
                    }
                }
                .pickerStyle(.segmented)

                Button(L10n.DamageCalculator.Button.swap) {
                    viewModel.swapParticipants()
                }
                .buttonStyle(.bordered)

                Text(L10n.DamageCalculator.placeholderPresets)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func participantSection(title: LocalizedStringKey, isAttacker: Bool) -> some View {
        GroupBox(label: Label(title, systemImage: isAttacker ? "flame.fill" : "shield.fill")) {
            VStack(alignment: .leading, spacing: 16) {
                Picker(L10n.DamageCalculator.fieldPokemon, selection: pokemonBinding(isAttacker: isAttacker)) {
                    Text(L10n.DamageCalculator.fieldNone).tag(DamageCalculatorViewModel.PokemonOption?.none)
                    ForEach(viewModel.pokemonOptions) { option in
                        Text(verbatim: option.displayName(for: localizationManager.currentLanguage))
                            .tag(Optional(option))
                    }
                }
                .pickerStyle(.menu)

                Stepper(value: levelBinding(isAttacker: isAttacker), in: 1...100) {
                    HStack {
                        Text(L10n.DamageCalculator.fieldLevel)
                        Spacer()
                        Text(verbatim: "\(levelBinding(isAttacker: isAttacker).wrappedValue)")
                            .monospacedDigit()
                    }
                }

                Picker(L10n.DamageCalculator.fieldNature, selection: natureBinding(isAttacker: isAttacker)) {
                    ForEach(DamageCalculatorViewModel.NatureOption.allCases) { option in
                        Text(LocalizedStringKey(option.localizationKey)).tag(option)
                    }
                }
                .pickerStyle(.menu)

                Picker(L10n.DamageCalculator.fieldMove, selection: moveBinding(isAttacker: isAttacker)) {
                    Text(L10n.DamageCalculator.fieldNone).tag(DamageCalculatorViewModel.MoveOption?.none)
                    ForEach(viewModel.moveOptions) { option in
                        Text(verbatim: option.displayName(for: localizationManager.currentLanguage))
                            .tag(Optional(option))
                    }
                }
                .pickerStyle(.menu)

                Picker(L10n.DamageCalculator.fieldItem, selection: itemBinding(isAttacker: isAttacker)) {
                    Text(L10n.DamageCalculator.fieldNone).tag(DamageCalculatorViewModel.ItemOption?.none)
                    ForEach(viewModel.itemOptions) { item in
                        Text(verbatim: item.displayName(for: localizationManager.currentLanguage))
                            .tag(Optional(item))
                    }
                }
                .pickerStyle(.menu)

                Picker(L10n.DamageCalculator.fieldAbility, selection: abilityBinding(isAttacker: isAttacker)) {
                    Text(L10n.DamageCalculator.fieldNone).tag(DamageCalculatorViewModel.AbilityOption?.none)
                    ForEach(viewModel.abilityOptions) { ability in
                        Text(verbatim: ability.displayName(for: localizationManager.currentLanguage))
                            .tag(Optional(ability))
                    }
                }
                .pickerStyle(.menu)

                Toggle(L10n.DamageCalculator.fieldTeraToggle, isOn: teraToggleBinding(isAttacker: isAttacker))

                Picker(L10n.DamageCalculator.fieldTeraType, selection: teraTypeBinding(isAttacker: isAttacker)) {
                    Text(L10n.DamageCalculator.fieldNone).tag(String?.none)
                    ForEach(viewModel.typeOptions, id: \.self) { typeName in
                        Text(verbatim: localizationManager.displayName(forTypeName: typeName))
                            .tag(Optional(typeName))
                    }
                }
                .pickerStyle(.menu)

                baseTypeRow(isAttacker: isAttacker)

                DisclosureGroup(L10n.DamageCalculator.fieldEVs) {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(DamageCalculatorViewModel.StatKey.allCases) { stat in
                            Stepper(value: evBinding(for: stat, isAttacker: isAttacker), in: 0...252, step: 4) {
                                statStepperLabel(for: stat, value: evBinding(for: stat, isAttacker: isAttacker).wrappedValue)
                            }
                        }
                        Text(verbatim: viewModel.remainingEVText(forAttacker: isAttacker))
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }

                DisclosureGroup(L10n.DamageCalculator.fieldIVs) {
                    ForEach(DamageCalculatorViewModel.StatKey.allCases) { stat in
                        Stepper(value: ivBinding(for: stat, isAttacker: isAttacker), in: 0...31) {
                            statStepperLabel(for: stat, value: ivBinding(for: stat, isAttacker: isAttacker).wrappedValue)
                        }
                    }
                }

                DisclosureGroup(L10n.DamageCalculator.fieldStatStages) {
                    ForEach(DamageCalculatorViewModel.StatKey.allCases) { stat in
                        Stepper(value: stageBinding(for: stat, isAttacker: isAttacker), in: -6...6) {
                            statStepperLabel(for: stat, value: stageBinding(for: stat, isAttacker: isAttacker).wrappedValue)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var environmentSection: some View {
        GroupBox(label: Label(L10n.DamageCalculator.sectionEnvironment, systemImage: "cloud.sun")) {
            VStack(alignment: .leading, spacing: 16) {
                Picker(L10n.DamageCalculator.fieldWeather, selection: $viewModel.weather) {
                    ForEach(DamageCalculatorViewModel.WeatherCondition.allCases) { condition in
                        Text(LocalizedStringKey(condition.localizationKey)).tag(condition)
                    }
                }
                .pickerStyle(.menu)

                Picker(L10n.DamageCalculator.fieldTerrain, selection: $viewModel.terrain) {
                    ForEach(DamageCalculatorViewModel.TerrainField.allCases) { field in
                        Text(LocalizedStringKey(field.localizationKey)).tag(field)
                    }
                }
                .pickerStyle(.menu)

                Picker(L10n.DamageCalculator.fieldScreen, selection: $viewModel.screen) {
                    ForEach(DamageCalculatorViewModel.ScreenEffect.allCases) { effect in
                        Text(LocalizedStringKey(effect.localizationKey)).tag(effect)
                    }
                }
                .pickerStyle(.menu)

                VStack(alignment: .leading) {
                    HStack {
                        Text(L10n.DamageCalculator.fieldHazards)
                        Spacer()
                        Text(verbatim: "\(Int(viewModel.hazardDamage))% HP")
                            .monospacedDigit()
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Slider(value: $viewModel.hazardDamage, in: 0...100, step: 1)
                    Text(L10n.DamageCalculator.hazardHelp)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var turnPlanSection: some View {
        GroupBox(label: Label(L10n.DamageCalculator.sectionTurns, systemImage: "clock.arrow.circlepath")) {
            VStack(alignment: .leading, spacing: 12) {
                Picker(L10n.DamageCalculator.fieldFirstMove, selection: $viewModel.firstTurnMove) {
                    Text(L10n.DamageCalculator.fieldNone).tag(DamageCalculatorViewModel.MoveOption?.none)
                    ForEach(viewModel.moveOptions) { option in
                        Text(verbatim: option.displayName(for: localizationManager.currentLanguage))
                            .tag(Optional(option))
                    }
                }
                .pickerStyle(.menu)

                Picker(L10n.DamageCalculator.fieldSecondMove, selection: $viewModel.secondTurnMove) {
                    Text(L10n.DamageCalculator.fieldNone).tag(DamageCalculatorViewModel.MoveOption?.none)
                    ForEach(viewModel.moveOptions) { option in
                        Text(verbatim: option.displayName(for: localizationManager.currentLanguage))
                            .tag(Optional(option))
                    }
                }
                .pickerStyle(.menu)

                Toggle(L10n.DamageCalculator.fieldApplyAccuracy, isOn: $viewModel.applyAccuracy)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var resultSection: some View {
        GroupBox(label: Label(L10n.DamageCalculator.sectionResult, systemImage: "chart.bar.doc.horizontal")) {
            VStack(alignment: .leading, spacing: 16) {
                Text(verbatim: viewModel.summaryText)
                    .font(.callout.monospaced())
                    .frame(maxWidth: .infinity, alignment: .leading)

                HStack {
                    Button(L10n.DamageCalculator.Button.recalculate) {
                        viewModel.refreshSummary()
                    }
                    .buttonStyle(.bordered)

                    Button(L10n.DamageCalculator.Button.copy) {
                        copySummaryToClipboard()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - Bindings

    private func pokemonBinding(isAttacker: Bool) -> Binding<DamageCalculatorViewModel.PokemonOption?> {
        Binding(
            get: { isAttacker ? viewModel.attackerPokemon : viewModel.defenderPokemon },
            set: { newValue in
                if isAttacker {
                    viewModel.attackerPokemon = newValue
                } else {
                    viewModel.defenderPokemon = newValue
                }
            }
        )
    }

    private func moveBinding(isAttacker: Bool) -> Binding<DamageCalculatorViewModel.MoveOption?> {
        Binding(
            get: { isAttacker ? viewModel.attackerSelectedMove : viewModel.defenderSelectedMove },
            set: { newValue in
                if isAttacker {
                    viewModel.attackerSelectedMove = newValue
                } else {
                    viewModel.defenderSelectedMove = newValue
                }
            }
        )
    }

    private func itemBinding(isAttacker: Bool) -> Binding<DamageCalculatorViewModel.ItemOption?> {
        Binding(
            get: { isAttacker ? viewModel.attackerHeldItem : viewModel.defenderHeldItem },
            set: { newValue in
                if isAttacker {
                    viewModel.attackerHeldItem = newValue
                } else {
                    viewModel.defenderHeldItem = newValue
                }
            }
        )
    }

    private func abilityBinding(isAttacker: Bool) -> Binding<DamageCalculatorViewModel.AbilityOption?> {
        Binding(
            get: { isAttacker ? viewModel.attackerAbility : viewModel.defenderAbility },
            set: { newValue in
                if isAttacker {
                    viewModel.attackerAbility = newValue
                } else {
                    viewModel.defenderAbility = newValue
                }
            }
        )
    }

    private func levelBinding(isAttacker: Bool) -> Binding<Int> {
        Binding(
            get: { isAttacker ? viewModel.attackerLevel : viewModel.defenderLevel },
            set: { newValue in
                if isAttacker {
                    viewModel.attackerLevel = newValue
                } else {
                    viewModel.defenderLevel = newValue
                }
            }
        )
    }

    private func natureBinding(isAttacker: Bool) -> Binding<DamageCalculatorViewModel.NatureOption> {
        Binding(
            get: { isAttacker ? viewModel.attackerNature : viewModel.defenderNature },
            set: { newValue in
                if isAttacker {
                    viewModel.attackerNature = newValue
                } else {
                    viewModel.defenderNature = newValue
                }
            }
        )
    }

    private func teraToggleBinding(isAttacker: Bool) -> Binding<Bool> {
        Binding(
            get: { isAttacker ? viewModel.attackerIsTerastallized : viewModel.defenderIsTerastallized },
            set: { newValue in
                if isAttacker {
                    viewModel.attackerIsTerastallized = newValue
                } else {
                    viewModel.defenderIsTerastallized = newValue
                }
            }
        )
    }

    private func teraTypeBinding(isAttacker: Bool) -> Binding<String?> {
        Binding(
            get: { isAttacker ? viewModel.attackerTeraType : viewModel.defenderTeraType },
            set: { newValue in
                if isAttacker {
                    viewModel.attackerTeraType = newValue
                } else {
                    viewModel.defenderTeraType = newValue
                }
            }
        )
    }

    private func evBinding(for stat: DamageCalculatorViewModel.StatKey, isAttacker: Bool) -> Binding<Int> {
        Binding(
            get: { isAttacker ? viewModel.attackerEV(for: stat) : viewModel.defenderEV(for: stat) },
            set: { newValue in
                if isAttacker {
                    viewModel.setAttackerEV(newValue, for: stat)
                } else {
                    viewModel.setDefenderEV(newValue, for: stat)
                }
            }
        )
    }

    private func ivBinding(for stat: DamageCalculatorViewModel.StatKey, isAttacker: Bool) -> Binding<Int> {
        Binding(
            get: { isAttacker ? viewModel.attackerIV(for: stat) : viewModel.defenderIV(for: stat) },
            set: { newValue in
                if isAttacker {
                    viewModel.setAttackerIV(newValue, for: stat)
                } else {
                    viewModel.setDefenderIV(newValue, for: stat)
                }
            }
        )
    }

    private func stageBinding(for stat: DamageCalculatorViewModel.StatKey, isAttacker: Bool) -> Binding<Int> {
        Binding(
            get: { isAttacker ? viewModel.attackerStatStage(for: stat) : viewModel.defenderStatStage(for: stat) },
            set: { newValue in
                if isAttacker {
                    viewModel.setAttackerStatStage(newValue, for: stat)
                } else {
                    viewModel.setDefenderStatStage(newValue, for: stat)
                }
            }
        )
    }

    // MARK: - Helpers

    @ViewBuilder
    private func baseTypeRow(isAttacker: Bool) -> some View {
        let types = isAttacker ? viewModel.attackerBaseTypes : viewModel.defenderBaseTypes
        if !types.isEmpty {
            VStack(alignment: .leading, spacing: 4) {
                Text(L10n.DamageCalculator.fieldBaseTypes)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                HStack {
                    ForEach(types, id: \.name) { type in
                        Text(verbatim: localizationManager.displayName(for: type))
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(type.color.opacity(0.2))
                            .foregroundStyle(type.color)
                            .clipShape(Capsule())
                    }
                }
            }
        }
    }

    private func statStepperLabel(for stat: DamageCalculatorViewModel.StatKey, value: Int) -> some View {
        HStack {
            Text(stat.localizedKey)
            Spacer()
            Text(verbatim: "\(value)")
                .monospacedDigit()
                .foregroundStyle(.secondary)
        }
    }

    private func copySummaryToClipboard() {
        #if canImport(UIKit)
        UIPasteboard.general.string = viewModel.summaryText
        showCopyConfirmation = true
        #endif
    }
}

// Preview intentionally omitted because repositories depend on runtime configuration.
