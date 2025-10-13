//
//  FilterChipView.swift
//  Pokedex
//
//  選択済みフィルター項目を表示するチップコンポーネント
//

import SwiftUI

struct FilterChipView: View {
    let text: String
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: 4) {
            Text(text)
                .font(.caption)
            Button {
                onRemove()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.blue.opacity(0.2))
        .cornerRadius(12)
    }
}
