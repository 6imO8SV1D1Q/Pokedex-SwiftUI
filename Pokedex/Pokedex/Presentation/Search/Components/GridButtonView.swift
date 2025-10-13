//
//  GridButtonView.swift
//  Pokedex
//
//  フィルター選択用のグリッドボタンコンポーネント
//

import SwiftUI

struct GridButtonView: View {
    let text: String
    let isSelected: Bool
    let action: () -> Void
    var selectedColor: Color = .blue

    var body: some View {
        Button {
            action()
        } label: {
            Text(text)
                .font(.caption)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(
                    isSelected
                        ? selectedColor.opacity(0.2)
                        : Color.secondary.opacity(0.1)
                )
                .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }
}
