//
//  LoadingProgressView.swift
//  Pokedex
//
//  Created on 2025-10-05.
//

import SwiftUI

struct LoadingProgressView: View {
    let progress: Double
    let current: Int
    let total: Int

    var body: some View {
        VStack(spacing: 16) {
            ProgressView(value: progress) {
                Text(L10n.Loading.pokemon)
                    .font(.headline)
            }
            .progressViewStyle(LinearProgressViewStyle())

            Text("\(current) / \(total)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(24)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 8)
    }
}

#if DEBUG
struct LoadingProgressView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingProgressView(progress: 0.65, current: 98, total: 151)
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
#endif
