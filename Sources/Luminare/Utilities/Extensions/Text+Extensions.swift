//
//  Text+Extensions.swift
//  Luminare
//
//  Created by KrLite on 2024/12/18.
//

import SwiftUI

extension Text.Case: Codable {
    enum CodingKeys: String, CodingKey {
        case rawValue
    }

    public init(from decoder: any Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        switch try values.decode(String.self, forKey: .rawValue) {
        case "uppercase":
            self = .uppercase
        case "lowercase":
            self = .lowercase
        default:
            throw DecodingError.dataCorrupted(.init(
                codingPath: [CodingKeys.rawValue],
                debugDescription: "Unknown case"
            ))
        }
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self, forKey: .rawValue)
    }
}
