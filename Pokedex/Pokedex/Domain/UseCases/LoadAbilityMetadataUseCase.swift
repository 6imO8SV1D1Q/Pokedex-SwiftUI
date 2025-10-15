//
//  LoadAbilityMetadataUseCase.swift
//  Pokedex
//
//  特性の詳細メタデータを読み込むUseCase
//

import Foundation

protocol LoadAbilityMetadataUseCaseProtocol {
    func execute() throws -> [AbilityMetadata]
}

struct LoadAbilityMetadataUseCase: LoadAbilityMetadataUseCaseProtocol {
    func execute() throws -> [AbilityMetadata] {
        // まずsubdirectory付きで探す
        var url = Bundle.main.url(
            forResource: "ability_metadata",
            withExtension: "json",
            subdirectory: "Resources/PreloadedData"
        )

        if url == nil {
            // subdirectoryなしで探す
            url = Bundle.main.url(
                forResource: "ability_metadata",
                withExtension: "json"
            )
        }

        guard let url = url else {
            throw NSError(domain: "LoadAbilityMetadataUseCase", code: 1, userInfo: [
                NSLocalizedDescriptionKey: "ability_metadata.json not found"
            ])
        }

        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        let metadata = try decoder.decode([AbilityMetadata].self, from: data)

        return metadata
    }
}
