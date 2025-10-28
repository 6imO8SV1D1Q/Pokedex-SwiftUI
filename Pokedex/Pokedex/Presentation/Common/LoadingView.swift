//
//  LoadingView.swift
//  Pokedex
//
//  Created on 2025-10-04.
//

import SwiftUI

struct LoadingView: View {
    var message: LocalizedStringKey = L10n.Common.loading

    var body: some View {
        VStack(spacing: DesignConstants.Spacing.medium) {
            ProgressView()
                .scaleEffect(1.5)
                .progressViewStyle(CircularProgressViewStyle())

            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    LoadingView()
}
