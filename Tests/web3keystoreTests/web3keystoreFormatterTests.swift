//
//  web3keystoreFormatterTests.swift
//  web3keystore
//
//  Created by Brian Wagner on 2/13/22.
//

import BigInt
import XCTest
@testable import web3keystore

final class web3keystoreFormatterTests: XCTestCase {
    func testNumberFormattingUtil() throws {
        let balance = BigInt("-1000000000000000000")
        let formatted = Utils.formatToPrecision(balance, numberDecimals: 18, formattingDecimals: 4, decimalSeparator: ",")
        XCTAssert(formatted == "-1")
    }

    func testNumberFormattingUtil2() throws {
        let balance = BigInt("-1000000000000000")
        let formatted = Utils.formatToPrecision(balance, numberDecimals: 18, formattingDecimals: 4, decimalSeparator: ",")
        XCTAssert(formatted == "-0,0010")
    }

    func testNumberFormattingUtil3() throws {
        let balance = BigInt("-1000000000000")
        let formatted = Utils.formatToPrecision(balance, numberDecimals: 18, formattingDecimals: 4, decimalSeparator: ",")
        XCTAssert(formatted == "-0,0000")
    }

    func testNumberFormattingUtil4() throws {
        let balance = BigInt("-1000000000000")
        let formatted = Utils.formatToPrecision(balance, numberDecimals: 18, formattingDecimals: 9, decimalSeparator: ",")
        XCTAssert(formatted == "-0,000001000")
    }

    func testNumberFormattingUtil5() throws {
        let balance = BigInt("-1")
        let formatted = Utils.formatToPrecision(
            balance,
            numberDecimals: 18,
            formattingDecimals: 9,
            decimalSeparator: ",",
            fallbackToScientific: true
        )

        XCTAssert(formatted == "-1e-18")
    }

    func testNumberFormattingUtil6() throws {
        let balance = BigInt("0")
        let formatted = Utils.formatToPrecision(balance, numberDecimals: 18, formattingDecimals: 9, decimalSeparator: ",")
        XCTAssert(formatted == "0")
    }

    func testNumberFormattingUtil7() throws {
        let balance = BigInt("-1100000000000000000")
        let formatted = Utils.formatToPrecision(balance, numberDecimals: 18, formattingDecimals: 4, decimalSeparator: ",")
        XCTAssert(formatted == "-1,1000")
    }

    func testNumberFormattingUtil8() throws {
        let balance = BigInt("100")
        let formatted = Utils.formatToPrecision(
            balance,
            numberDecimals: 18,
            formattingDecimals: 4,
            decimalSeparator: ",",
            fallbackToScientific: true
        )

        XCTAssert(formatted == "1,00e-16")
    }

    func testNumberFormattingUtil9() throws {
        let balance = BigInt("1000000")
        let formatted = Utils.formatToPrecision(
            balance,
            numberDecimals: 18,
            formattingDecimals: 4,
            decimalSeparator: ",",
            fallbackToScientific: true
        )

        XCTAssert(formatted == "1,0000e-12")
    }
}
