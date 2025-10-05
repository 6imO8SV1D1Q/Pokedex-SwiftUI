//
//  FetchVersionGroupsUseCase.swift
//  Pokedex
//
//  Created on 2025-10-05.
//

import Foundation

/// バージョングループ一覧を取得するUseCaseのプロトコル
protocol FetchVersionGroupsUseCaseProtocol {
    /// バージョングループ一覧を取得
    func execute() -> [VersionGroup]
}

/// バージョングループ一覧を取得するUseCase
final class FetchVersionGroupsUseCase: FetchVersionGroupsUseCaseProtocol {
    func execute() -> [VersionGroup] {
        return VersionGroup.allVersionGroups
    }
}
