//
//  Array+SafeAccess.swift
//  Pokedex
//
//  Safe array subscript extension
//

import Foundation

extension Array {
    /// 安全に配列要素にアクセス
    /// - Parameter index: インデックス
    /// - Returns: 要素、または範囲外の場合はnil
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
