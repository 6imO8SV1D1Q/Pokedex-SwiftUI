#!/usr/bin/env swift

import Foundation

print("🔍 Testing: Fetch all Pokemon IDs (including forms)...")

func fetchAllPokemonIds() async throws -> [Int] {
    let url = URL(string: "https://pokeapi.co/api/v2/pokemon?limit=10000")!
    let (data, _) = try await URLSession.shared.data(from: url)
    
    guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
          let results = json["results"] as? [[String: Any]] else {
        return []
    }
    
    var pokemonIds: [Int] = []
    for result in results {
        guard let urlString = result["url"] as? String,
              let idStr = urlString.split(separator: "/").last,
              let id = Int(idStr) else {
            continue
        }
        pokemonIds.append(id)
    }
    
    return pokemonIds.sorted()
}

Task {
    do {
        let allIds = try await fetchAllPokemonIds()
        print("✅ Total Pokemon (including forms): \(allIds.count)")
        print("")
        
        // Show first 20 and last 20
        print("First 20 IDs:")
        print(Array(allIds.prefix(20)))
        print("")
        
        print("Last 20 IDs:")
        print(Array(allIds.suffix(20)))
        print("")
        
        // Check for specific forms
        let hisuianForms = allIds.filter { $0 > 10000 && $0 < 11000 }
        print("Forms (10000-11000): \(hisuianForms.count) forms")
        
        exit(0)
    } catch {
        print("Error: \(error)")
        exit(1)
    }
}

RunLoop.main.run()
