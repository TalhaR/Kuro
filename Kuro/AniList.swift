//
//  AniList.swift
//  Kuro
//
//  Created by Talha Rahman on 11/22/20.
//

import Foundation

public struct AniList: Decodable {
    let id: Int
    let title: [String : String?]
    let coverImage: [String : URL]
}

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
