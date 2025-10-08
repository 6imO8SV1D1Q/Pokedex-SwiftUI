//
//  ExpandableSection.swift
//  Pokedex
//
//  Created on 2025-10-08.
//

import SwiftUI

/// 展開・折りたたみ可能なセクション
struct ExpandableSection<Content: View>: View {
    let title: String
    let systemImage: String?
    @Binding var isExpanded: Bool
    @ViewBuilder let content: () -> Content

    init(
        title: String,
        systemImage: String? = nil,
        isExpanded: Binding<Bool>,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = title
        self.systemImage = systemImage
        self._isExpanded = isExpanded
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // ヘッダー
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack {
                    // アイコン
                    if let systemImage = systemImage {
                        Image(systemName: systemImage)
                            .foregroundColor(.blue)
                            .frame(width: 24)
                    }

                    // タイトル
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)

                    Spacer()

                    // 展開/折りたたみアイコン
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                        .animation(.easeInOut(duration: 0.2), value: isExpanded)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }
            .buttonStyle(PlainButtonStyle())

            // コンテンツ
            if isExpanded {
                VStack(alignment: .leading, spacing: 0) {
                    content()
                }
                .padding(.top, 8)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }
}

#Preview("展開状態") {
    ExpandableSection(
        title: "種族値",
        systemImage: "chart.bar.fill",
        isExpanded: .constant(true)
    ) {
        VStack(alignment: .leading, spacing: 8) {
            Text("HP: 78")
            Text("こうげき: 84")
            Text("ぼうぎょ: 78")
            Text("とくこう: 109")
            Text("とくぼう: 85")
            Text("すばやさ: 100")
        }
        .padding()
        .background(Color(.systemGray5))
        .cornerRadius(8)
    }
    .padding()
}

#Preview("折りたたみ状態") {
    ExpandableSection(
        title: "種族値",
        systemImage: "chart.bar.fill",
        isExpanded: .constant(false)
    ) {
        VStack(alignment: .leading, spacing: 8) {
            Text("HP: 78")
            Text("こうげき: 84")
            Text("ぼうぎょ: 78")
            Text("とくこう: 109")
            Text("とくぼう: 85")
            Text("すばやさ: 100")
        }
        .padding()
        .background(Color(.systemGray5))
        .cornerRadius(8)
    }
    .padding()
}

#Preview("インタラクティブ") {
    @Previewable @State var isExpanded = true

    ExpandableSection(
        title: "特性",
        systemImage: "star.fill",
        isExpanded: $isExpanded
    ) {
        VStack(alignment: .leading, spacing: 8) {
            Text("しんりょく")
                .fontWeight(.semibold)
            Text("HPが1/3以下のとき、くさタイプの技の威力が1.5倍になる。")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray5))
        .cornerRadius(8)
    }
    .padding()
}
