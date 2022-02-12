//
//  web3keystoreTests.swift
//  web3keystore
//
//  Created by Brian Wagner on 2/12/22.
//

import XCTest
@testable import web3keystore

final class web3keystoreUtilsTests: XCTestCase {
    func testBitFunctions () throws {
        let data = Data([0xf0, 0x02, 0x03])
        let firstBit = data.bitsInRange(0,1)
        XCTAssert(firstBit == 1)
        let first4bits = data.bitsInRange(0,4)
        XCTAssert(first4bits == 0x0f)
    }

    func testHexFunctions() throws {
        let hexRepresentation = "0x1c31de57e49fc00".stripHexPrefix()
        XCTAssert(hexRepresentation == "1c31de57e49fc00")
    }

    func testCombiningPublicKeys() throws {
        let priv1 = Data(repeating: 0x01, count: 32)
        let pub1 = privateToPublic(priv1, compressed: true)!
        let priv2 = Data(repeating: 0x02, count: 32)
        let pub2 = privateToPublic(priv2, compressed: true)!
        let combined = SECP256K1.combineSerializedPublicKeys(keys: [pub1, pub2], outputCompressed: true)
        let compinedPriv = Data(repeating: 0x03, count: 32)
        let compinedPub = privateToPublic(compinedPriv, compressed: true)
        XCTAssert(compinedPub == combined)
    }

    func testChecksumAddress() throws {
        let input = "0xfb6916095ca1df60bb79ce92ce3ea74c37c5d359"
        let output = EthereumAddress.toChecksumAddress(input);
        XCTAssert(output == "0xfB6916095ca1df60bB79Ce92cE3Ea74c37c5d359", "Failed to checksum address")
    }

    func testChecksumAddressParsing() throws {
        let input = "0xfB6916095ca1df60bB79Ce92cE3Ea74c37c5d359"
        let addr = EthereumAddress(input);
        XCTAssert(addr != nil);
        let invalidInput = "0xfb6916095ca1df60bB79Ce92cE3Ea74c37c5d359"
        let invalidAddr = EthereumAddress(invalidInput);
        XCTAssert(invalidAddr == nil);
    }

    func testMakePrivateKey() throws {
        let privateKey = SECP256K1.generatePrivateKey()
        XCTAssert(privateKey != nil, "Failed to create new private key")
    }
}
