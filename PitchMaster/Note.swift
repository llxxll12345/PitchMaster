//
//  Song.swift
//  Time
//
//  Created by Lixing Liu on 12/15/23.
//

import Foundation

struct Note: Codable, Hashable {
    let id: Int
    let start: Float
    let duration: Float
}

func encodeJsonString(notes: [Note]) -> String {
    do {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted // Optional: for a pretty-printed JSON string
        let jsonData = try encoder.encode(notes)
        
        if let jsonString = String(data: jsonData, encoding: .utf8) {
            print(jsonString)
            return jsonString
        }
    } catch {
        print("Error encoding to JSON: \(error)")
    }
    return ""
}

func decodeJsonString(jsonString: String) -> [Note] {
    var songs : [Note] = []
    if let jsonData = jsonString.data(using: .utf8) {
        do {
            // Decode JSON data into User object
            let decoder = JSONDecoder()
            songs = try decoder.decode([Note].self, from: jsonData)
        } catch {
            print("Error decoding JSON: \(error)")
        }
    }
    return songs
}
