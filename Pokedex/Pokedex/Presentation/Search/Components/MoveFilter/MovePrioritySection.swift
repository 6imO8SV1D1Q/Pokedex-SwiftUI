//
//  MovePrioritySection.swift
//  Pokedex
//
//  技の優先度選択セクション
//

import SwiftUI

struct MovePrioritySection: View {
    @Binding var priority: Int?

    var body: some View {
        Section {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("優先度:")
                    Spacer()
                    if let priority = priority {
                        Text(priority >= 0 ? "+\(priority)" : "\(priority)")
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                    } else {
                        Text("指定なし")
                            .foregroundColor(.secondary)
                    }
                }

                Slider(
                    value: Binding(
                        get: { priority.map(Double.init) ?? 0 },
                        set: { priority = Int($0) }
                    ),
                    in: -7...5,
                    step: 1
                )

                if priority != nil {
                    Button {
                        priority = nil
                    } label: {
                        Text("解除")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(Color.secondary.opacity(0.2))
                            .foregroundColor(.primary)
                            .cornerRadius(8)
                    }
                }
            }
            .padding(.vertical, 8)
        } header: {
            Text("優先度")
        } footer: {
            Text("スライダーを動かすと即座に優先度が設定されます。")
        }
    }
}
