// NSScanner+Swift.swift
// A set of Swift-idiomatic methods for NSScanner
//
// (c) 2015 Nate Cook, licensed under the MIT license

import Foundation

extension Scanner {

    // MARK: Strings

    /// Returns a string, scanned as long as characters from a given character set are encountered, or `nil` if none are found.
    func scanCharacters(from set: CharacterSet) -> String? {
        var value: NSString? = ""
        if scanCharacters(from: set, into: &value),
            let value = value as? String {
            return value
        }
        return nil
    }

    /// Returns a string, scanned until a character from a given character set are encountered, or the remainder of the scanner's string. Returns `nil` if the scanner is already `atEnd`.
    func scanUpToCharacters(from set: CharacterSet) -> String? {
        var value: NSString? = ""
        if scanUpToCharacters(from: set, into: &value),
            let value = value as? String {
            return value
        }
        return nil
    }

    /// Returns the given string if scanned, or `nil` if not found.
    func scanString(_ str: String) -> String? {
        var value: NSString? = ""
        if scanString(str, into: &value),
            let value = value as? String {
            return value
        }
        return nil
    }

    /// Returns a string, scanned until the given string is found, or the remainder of the scanner's string. Returns `nil` if the scanner is already `atEnd`.
    func scanUpTo(_ str: String) -> String? {
        var value: NSString? = ""
        if scanUpTo(str, into: &value),
            let value = value as? String {
            return value
        }
        return nil
    }

    // MARK: Numbers

    /// Returns a Double if scanned, or `nil` if not found.
    func scanDouble() -> Double? {
        var value = 0.0
        if scanDouble(&value) {
            return value
        }
        return nil
    }

    /// Returns a Float if scanned, or `nil` if not found.
    func scanFloat() -> Float? {
        var value: Float = 0.0
        if scanFloat(&value) {
            return value
        }
        return nil
    }

    /// Returns an Int if scanned, or `nil` if not found.
    func scanInt() -> Int? {
        var value = 0
        if scanInt(&value) {
            return value
        }
        return nil
    }

    /// Returns an Int32 if scanned, or `nil` if not found.
    func scanInt32() -> Int32? {
        var value: Int32 = 0
        if scanInt32(&value) {
            return value
        }
        return nil
    }

    /// Returns an Int64 if scanned, or `nil` if not found.
    func scanInt64() -> Int64? {
        var value: Int64 = 0
        if scanInt64(&value) {
            return value
        }
        return nil
    }

    /// Returns a UInt64 if scanned, or `nil` if not found.
    func scanUnsignedLongLong() -> UInt64? {
        var value: UInt64 = 0
        if scanUnsignedLongLong(&value) {
            return value
        }
        return nil
    }

    /// Returns an Decimal if scanned, or `nil` if not found.
    func scanDecimal() -> Decimal? {
        var value = Decimal()
        if scanDecimal(&value) {
            return value
        }
        return nil
    }

    // MARK: Hex Numbers

    /// Returns a Double if scanned in hexadecimal, or `nil` if not found.
    func scanHexDouble() -> Double? {
        var value = 0.0
        if scanHexDouble(&value) {
            return value
        }
        return nil
    }

    /// Returns a Float if scanned in hexadecimal, or `nil` if not found.
    func scanHexFloat() -> Float? {
        var value: Float = 0.0
        if scanHexFloat(&value) {
            return value
        }
        return nil
    }

    /// Returns a UInt32 if scanned in hexadecimal, or `nil` if not found.
    func scanHexInt32() -> UInt32? {
        var value: UInt32 = 0
        if scanHexInt32(&value) {
            return value
        }
        return nil
    }

    /// Returns a UInt64 if scanned in hexadecimal, or `nil` if not found.
    func scanHexInt64() -> UInt64? {
        var value: UInt64 = 0
        if scanHexInt64(&value) {
            return value
        }
        return nil
    }

    typealias Position = (line: Range<String.CharacterView.Index>, row: Int, pos: Int)
    var position: Position {
        let index = string.index(string.startIndex, offsetBy: scanLocation)
        var head = string.startIndex..<string.startIndex
        var row = 0
        while head.upperBound <= index {
            head = string.lineRange(for: head.upperBound..<head.upperBound)
            row += 1
        }
        return (head, row, string.distance(from: head.lowerBound, to: index) + 1)
    }
}





extension Scanner {
    
    static func scanTypeName(line: String) throws -> String {
        let scanner = Scanner(string: line)
        guard
            scanner.scanString("struct", into: nil) ||
                //            scanner.scanString("class", into: nil) || TODO: Add support for enums
                scanner.scanString("enum", into: nil)
            else {
                throw EditorError.parseError.nsError
        }
        guard let typeName = scanner.scanUpTo("{") else {
            throw EditorError.parseError.nsError
        }
        
        return typeName.trimmingCharacters(in: CharacterSet(charactersIn: " "))
    }
    
    static func scanVariableName(line: String) throws -> String {
        let accessModifiers = ["open", "public", "internal", "private", "fileprivate"]
        let scanner = Scanner(string: line)
        var weak = scanner.scanString("weak", into: nil)
        for modifier in accessModifiers {
            if scanner.scanString(modifier, into: nil) {
                break
            }
        }
        weak = weak || scanner.scanString("weak", into: nil)
        
        guard scanner.scanString("let", into: nil) || scanner.scanString("var", into: nil) else {
            throw EditorError.parseError.nsError
        }
        guard let variableName = scanner.scanUpTo(":") else {
            throw EditorError.parseError.nsError
        }
        
        return variableName
    }
}

