//
//  Extensions.swift
//  web3keystore
//
//  Created by Brian Wagner on 2/12/22.
//

import BigInt
import CryptoSwift
import Foundation

extension UInt32 {
    public func serialize32() -> Data {
        let uint32 = UInt32(self)
        let count = MemoryLayout<UInt32>.size
        var bigEndian = uint32.bigEndian

        let bytePtr = withUnsafePointer(to: &bigEndian) {
            $0.withMemoryRebound(to: UInt8.self, capacity: count) {
                UnsafeBufferPointer(start: $0, count: count)
            }
        }

        return Data(Array(bytePtr))
    }
}

extension Array {
    public func split(intoChunksOf chunkSize: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: chunkSize).map {
            let endIndex = ($0.advanced(by: chunkSize) > count) ? count - $0 : chunkSize
            return Array(self[$0..<$0.advanced(by: endIndex)])
        }
    }
}

extension Data {
    static func zero(_ data: inout Data) {
        let count = data.count

        data.withUnsafeMutableBytes { (body: UnsafeMutableRawBufferPointer) in
            body.baseAddress?.assumingMemoryBound(to: UInt8.self).initialize(repeating: 0, count: count)
        }
    }

    static func fromHex(_ hex: String) -> Data? {
        let string = hex.lowercased().stripHexPrefix()
        let array = Array<UInt8>(hex: string)

        if (array.count == 0) {
            if (hex == "0x" || hex == "") {
                return Data()
            } else {
                return nil
            }
        }

        return Data(array)
    }

    static func randomBytes(length: Int) -> Data? {
        for _ in 0...1024 {
            var data = Data(repeating: 0, count: length)

            let result = data.withUnsafeMutableBytes { (body: UnsafeMutableRawBufferPointer) -> Int32? in
                if let bodyAddress = body.baseAddress, body.count > 0 {
                    let pointer = bodyAddress.assumingMemoryBound(to: UInt8.self)
                    return SecRandomCopyBytes(kSecRandomDefault, 32, pointer)
                } else {
                    return nil
                }
            }
            
            if let notNilResult = result, notNilResult == errSecSuccess {
                return data
            }
        }

        return nil
    }

    func constantTimeComparisonTo(_ other:Data?) -> Bool {
        guard let rhs = other else {
            return false
        }

        guard count == rhs.count else {
            return false
        }

        var difference = UInt8(0x00)
        for i in 0..<self.count { // Compare full length.
            difference |= self[i] ^ rhs[i] // Constant time.
        }

        return difference == UInt8(0x00)
    }

    /// Return max of 8 bytes for simplicity.
    func bitsInRange(_ startingBit:Int, _ length:Int) -> UInt64? {
        if startingBit + length / 8 > self.count, length > 64, startingBit > 0, length >= 1 {return nil}
        let bytes = self[(startingBit/8) ..< (startingBit+length+7)/8]
        let padding = Data(repeating: 0, count: 8 - bytes.count)
        let padded = bytes + padding
        guard padded.count == 8 else {return nil}
        let pointee = padded.withUnsafeBytes { (body: UnsafeRawBufferPointer) in
            body.baseAddress?.assumingMemoryBound(to: UInt64.self).pointee
        }
        guard let ptee = pointee else {return nil}
        var uintRepresentation = UInt64(bigEndian: ptee)
        uintRepresentation = uintRepresentation << (startingBit % 8)
        uintRepresentation = uintRepresentation >> UInt64(64 - length)
        return uintRepresentation
    }

    func setLengthLeft(_ toBytes: UInt64, isNegative: Bool = false) -> Data? {
        let existingLength = UInt64(count)

        if (existingLength == toBytes) {
            return Data(self)
        } else if (existingLength > toBytes) {
            return nil
        }

        var data: Data

        if (isNegative) {
            data = Data(repeating: UInt8(255), count: Int(toBytes - existingLength))
        } else {
            data = Data(repeating: UInt8(0), count: Int(toBytes - existingLength))
        }

        data.append(self)
        return data
    }
}

extension String {
    subscript (bounds: CountableClosedRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)

        return String(self[start...end])
    }

    subscript (bounds: CountableRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)

        return String(self[start..<end])
    }

    subscript (bounds: CountablePartialRangeFrom<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = endIndex

        return String(self[start..<end])
    }

    var fullRange: Range<Index> {
        startIndex..<endIndex
    }

    var fullNSRange: NSRange {
        NSRange(fullRange, in: self)
    }

    func hasHexPrefix() -> Bool {
        hasPrefix("0x")
    }

    func addHexPrefix() -> String {
        if !hasPrefix("0x") {
            return "0x" + self
        }

        return self
    }

    func stripHexPrefix() -> String {
        if hasPrefix("0x") {
            let indexStart = index(startIndex, offsetBy: 2)
            return String(self[indexStart...])
        }

        return self
    }

    func leftPadding(toLength: Int, withPad character: Character) -> String {
        let stringLength = self.count

        if stringLength < toLength {
            return String(repeatElement(character, count: toLength - stringLength)) + self
        } else {
            return String(self.suffix(toLength))
        }
    }

    func split(intoChunksOf chunkSize: Int) -> [String] {
        var output = [String]()

        let chunks = self
            .map { $0 }
            .split(intoChunksOf: chunkSize)

        chunks.forEach {
            output.append($0.map { String($0) }.joined(separator: ""))
        }

        return output
    }

    func interpretAsBinaryData() -> Data? {
        let padded = padding(toLength: ((count + 7) / 8) * 8, withPad: "0", startingAt: 0)
        let byteArray = padded.split(intoChunksOf: 8).map { UInt8(strtoul($0, nil, 2)) }

        return Data(byteArray)
    }
}
