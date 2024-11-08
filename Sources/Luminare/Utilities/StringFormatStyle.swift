//
//  StringFormatStyle.swift
//
//
//  Created by KrLite on 2024/7/7.
//

import SwiftUI

/// Formats `String` into multiple styles.
///
/// This is presently used as a `parseStrategy` parameter in ``LuminareColorPicker`` to format the hex string 
/// representing a color.
///
/// See ``HexStrategy`` for more information on how to parse a hex string, or use the `Strategy.identity` as a
/// passthrough.
///
/// ## Topics
///
/// - ``HexStrategy``
public struct StringFormatStyle: Codable, Equatable, Hashable, ParseableFormatStyle {
    public var parseStrategy: Strategy = .identity

    public typealias FormatInput = String
    public typealias FormatOutput = String

    public enum Strategy: Codable, Equatable, Hashable, ParseStrategy {
        public typealias ParseInput = String
        public typealias ParseOutput = String

        case identity
        case hex(HexStrategy)

        public func parse(_ value: String) throws -> String {
            switch self {
            case .identity:
                value
            case let .hex(strategy):
                try strategy.parse(value)
            }
        }
    }

    /// A strategy to parse a hex string.
    public enum HexStrategy: Codable, Equatable, Hashable, ParseStrategy {
        public typealias ParseInput = String
        public typealias ParseOutput = String

        /// A lowercased style without any prefixes.
        ///
        /// - Parses `#42ab0E` to `42ab0e`.
        /// - Parses `42AB0E` to `42ab0e`.
        case lowercased

        /// An uppercased style without any prefixes.
        ///
        /// - Parses `#42ab0E` to `42AB0E`.
        /// - Parses `42ab0e` to `42AB0E`.
        case uppercased

        /// A lowercased style prefixed with `#`.
        ///
        /// - Parses `42ab0E` to `#42ab0e`.
        /// - Parses `#42AB0E` to `#42ab0e`.
        case lowercasedWithWell

        /// An uppercased style prefixed with `#`.
        ///
        /// - Parses `42ab0E` to `#42AB0E`.
        /// - Parses `#42ab0e` to `#42AB0E`.
        case uppercasedWithWell

        /// A style with customized text case and prefix.
        ///
        /// ## Examples
        ///
        /// - `.custom(.lowercased, "$")`
        ///     - Parses `#42AB0E` to `$42ab0e`.
        ///
        /// - `.custom(.uppercased, "@@")`
        ///     - Parses `#42ab0e` to `@@42AB0E`.
        case custom(TextCase, String)

        /// Parse a hex value using a specified strategy.
        /// - Parameter value: The hex value to parse.
        /// - Returns: The parsed hex value.
        public func parse(_ value: String) throws -> String {
            switch self {
            case .lowercased:
                return value.lowercased()
                    .replacing(#/[^a-f0-9]/#, with: "")
            case .uppercased:
                return value.uppercased()
                    .replacing(#/[^A-F0-9]/#, with: "")
            case .lowercasedWithWell:
                return try "#" + Self.lowercased.parse(value)
            case .uppercasedWithWell:
                return try "#" + Self.uppercased.parse(value)
            case .custom(let textCase, let prefix):
                let branch = switch textCase {
                case .uppercase:
                    Self.uppercased
                case .lowercase:
                    Self.lowercased
                }

                return try prefix + branch.parse(value)
            }
        }
    }

    public func format(_ value: String) -> String {
        do {
            return try parseStrategy.parse(value)
        } catch {
            print("Error: \(error)")
            return value
        }
    }
}

/// Represents a text case.
public enum TextCase: String, Equatable, Hashable, Codable {
    /// The uppercase.
    case uppercase
    /// The lowercase.
    case lowercase
}
