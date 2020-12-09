//
//  AniList.swift
//  Kuro
//
//  Created by Talha Rahman on 11/22/20.
//

import Foundation

/// Holds basic info including ID, Title & coverImage
public struct AniList: Decodable {
    let id: Int
    let title: [String : String?]
    let coverImage: [String : URL]
}

/// Used for Detailed Information about an Anime
public struct DetailedAniList : Decodable {
    let genres: [String]
    let averageScore: Int?
    let episodes: Int?
    let nextAiringEpisode: [String : Int]?
    let rankings: [[String : JsonGeneric?]]
    let season: String?
    let seasonYear: Int?
    let title: [String : String?]
    let description: String
    let status: String
    let format: String
    
    /// - Parameter type: "RATED" or "POPULAR"
    func getRank(_ type: String) -> String? {
        var season: String?
        var year = 0, rank = 0
        
        for ranking in rankings {
            if ranking["type"]??.stringValue != type {
                continue
            }
            if ranking["allTime"]??.boolValue == true {
                return "#\(ranking["rank"]!!.intValue!) All Time"
            }
            
            if year < (ranking["year"]??.intValue)! {
                year = (ranking["year"]!!.intValue)!
                season = ranking["season"]??.stringValue
                rank = (ranking["rank"]??.intValue)!
            }
        }
        
        if let season = season?.lowercased() {
            return "#\(rank) \(season.capitalized) \(year)"
        }
        if year != 0 {
            return "#\(rank) \(year)"
        }
        return nil
    }
}

/// Used to handle 'Any' datatype for JSON Decoder class
public enum JsonGeneric: Decodable {
    case int(Int), string(String), bool(Bool)
    
    var intValue: Int? {
        switch self {
        case .int(let value): return value
        case .string(let value): return Int(value)
        case .bool: return -1
        }
    }
    var stringValue: String? {
        switch self {
        case .string(let string): return string
        case .int(let int): return String(int)
        case .bool(let bool): return String(bool)
        }
    }
    var boolValue: Bool {
        switch self {
        case .bool(let bool): return bool
        default:
            return false
        }
    }

    public init(from decoder: Decoder) throws {
        if let int = try? decoder.singleValueContainer().decode(Int.self) {
            self = .int(int)
            return
        }

        if let string = try? decoder.singleValueContainer().decode(String.self) {
            self = .string(string)
            return
        }
        
        if let bool = try? decoder.singleValueContainer().decode(Bool.self) {
            self = .bool(bool)
            return
        }

        throw JsonGeneric.missingValue
    }

    enum JsonGeneric:Error {
        case missingValue
    }
}

extension String {
    /// Lowercases all characters and capitalizes first character in String
    func lowerAndCapitalize() -> String {
        return self.lowercased().capitalized
    }
}
