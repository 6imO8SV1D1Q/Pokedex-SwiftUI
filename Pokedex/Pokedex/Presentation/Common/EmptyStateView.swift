//
//  EmptyStateView.swift
//  Pokedex
//
//  Created on 2025-10-04.
//

import SwiftUI

struct EmptyStateView: View {
    let title: String
    let message: String
    let systemImage: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: DesignConstants.Spacing.large) {
            Image(systemName: systemImage)
                .font(.system(size: 64))
                .foregroundColor(.secondary)

            VStack(spacing: DesignConstants.Spacing.xSmall) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)

                Text(message)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }

            if let actionTitle = actionTitle, let action = action {
                Button(actionTitle) {
                    action()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(DesignConstants.Spacing.xLarge)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(uiColor: .systemGroupedBackground))
    }
}

#Preview {
    EmptyStateView(
        title: "ポケモンが見つかりません",
        message: "検索条件を変更してください",
        systemImage: "magnifyingglass"
    )
}
