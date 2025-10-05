//
//  MoveCache.swift
//  Pokedex
//
//  Created on 2025-10-05.
//

import Foundation

/// 技情報のキャッシュ
final class MoveCache {
    private var movesCache: [String: [MoveEntity]] = [:]
    private let queue = DispatchQueue(label: "com.pokedex.movecache", attributes: .concurrent)

    func getMoves(key: String) -> [MoveEntity]? {
        queue.sync {
            movesCache[key]
        }
    }

    func setMoves(key: String, moves: [MoveEntity]) {
        queue.async(flags: .barrier) {
            self.movesCache[key] = moves
        }
    }

    func clear() {
        queue.async(flags: .barrier) {
            self.movesCache.removeAll()
        }
    }
}
