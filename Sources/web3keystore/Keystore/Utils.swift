//
//  Utils.swift
//  web3keystore
//
//  Created by Brian Wagner on 2/13/22.
//

import BigInt
import Foundation

public struct Utils {
    /// Various units used in the Ethereum ecosystem.
    public enum Units {
        case eth
        case wei
        case Kwei
        case Mwei
        case Gwei
        case Microether
        case Finney

        var decimals:Int {
            get {
                switch self {
                case .eth:
                    return 18
                case .wei:
                    return 0
                case .Kwei:
                    return 3
                case .Mwei:
                    return 6
                case .Gwei:
                    return 9
                case .Microether:
                    return 12
                case .Finney:
                    return 15
                }
            }
        }
    }

    /// Formats a BigInt object to String. The supplied number is first divided into integer and decimal part based on "toUnits",
    /// then limit the decimal part to "decimals" symbols and uses a "decimalSeparator" as a separator.
    ///
    /// Returns nil of formatting is not possible to satisfy.
    public static func formatToEthereumUnits(
        _ bigNumber: BigInt,
        toUnits: Units = .eth,
        decimals: Int = 4,
        decimalSeparator: String = "."
    ) -> String? {
        let magnitude = bigNumber.magnitude
        guard let formatted = formatToEthereumUnits(
            magnitude,
            toUnits: toUnits,
            decimals: decimals,
            decimalSeparator: decimalSeparator
        ) else {
            return nil
        }

        switch bigNumber.sign {
        case .plus:
            return formatted
        case .minus:
            return "-" + formatted
        }
    }

    /// Formats a BigUInt object to String. The supplied number is first divided into integer and decimal part based on "toUnits",
    /// then limit the decimal part to "decimals" symbols and uses a "decimalSeparator" as a separator.
    ///
    /// Returns nil of formatting is not possible to satisfy.
    public static func formatToEthereumUnits(
        _ bigNumber: BigUInt,
        toUnits: Units = .eth,
        decimals: Int = 4,
        decimalSeparator: String = ".",
        fallbackToScientific: Bool = false
    ) -> String? {
        formatToPrecision(
            bigNumber,
            numberDecimals: toUnits.decimals,
            formattingDecimals: decimals,
            decimalSeparator: decimalSeparator,
            fallbackToScientific: fallbackToScientific
        )
    }

    /// Formats a BigInt object to String. The supplied number is first divided into integer and decimal part based on "toUnits",
    /// then limit the decimal part to "decimals" symbols and uses a "decimalSeparator" as a separator.
    /// Fallbacks to scientific format if higher precision is required.
    ///
    /// Returns nil of formatting is not possible to satisfy.
    public static func formatToPrecision(
        _ bigNumber: BigInt,
        numberDecimals: Int = 18,
        formattingDecimals: Int = 4,
        decimalSeparator: String = ".",
        fallbackToScientific: Bool = false
    ) -> String? {
        let magnitude = bigNumber.magnitude
        guard let formatted = formatToPrecision(
            magnitude,
            numberDecimals: numberDecimals,
            formattingDecimals: formattingDecimals,
            decimalSeparator: decimalSeparator,
            fallbackToScientific: fallbackToScientific
        ) else {
            return nil
        }

        switch bigNumber.sign {
        case .plus:
            return formatted
        case .minus:
            return "-" + formatted
        }
    }

    /// Formats a BigUInt object to String. The supplied number is first divided into integer and decimal part based on "numberDecimals",
    /// then limits the decimal part to "formattingDecimals" symbols and uses a "decimalSeparator" as a separator.
    /// Fallbacks to scientific format if higher precision is required.
    ///
    /// Returns nil of formatting is not possible to satisfy.
    public static func formatToPrecision(
        _ bigNumber: BigUInt,
        numberDecimals: Int = 18,
        formattingDecimals: Int = 4,
        decimalSeparator: String = ".",
        fallbackToScientific: Bool = false
    ) -> String? {
        if bigNumber == 0 {
            return "0"
        }

        let unitDecimals = numberDecimals
        var toDecimals = formattingDecimals
        if unitDecimals < toDecimals {
            toDecimals = unitDecimals
        }

        let divisor = BigUInt(10).power(unitDecimals)
        let (quotient, remainder) = bigNumber.quotientAndRemainder(dividingBy: divisor)
        var fullRemainder = String(remainder);
        let fullPaddedRemainder = fullRemainder.leftPadding(toLength: unitDecimals, withPad: "0")
        let remainderPadded = fullPaddedRemainder[0..<toDecimals]

        if remainderPadded == String(repeating: "0", count: toDecimals) {
            if quotient != 0 {
                return String(quotient)
            } else if fallbackToScientific {
                var firstDigit = 0
                for char in fullPaddedRemainder {
                    if (char == "0") {
                        firstDigit = firstDigit + 1;
                    } else {
                        let firstDecimalUnit = String(fullPaddedRemainder[firstDigit ..< firstDigit+1])
                        var remainingDigits = ""
                        let numOfRemainingDecimals = fullPaddedRemainder.count - firstDigit - 1
                        if numOfRemainingDecimals <= 0 {
                            remainingDigits = ""
                        } else if numOfRemainingDecimals > formattingDecimals {
                            let end = firstDigit+1+formattingDecimals > fullPaddedRemainder.count ? fullPaddedRemainder.count : firstDigit+1+formattingDecimals
                            remainingDigits = String(fullPaddedRemainder[firstDigit+1 ..< end])
                        } else {
                            remainingDigits = String(fullPaddedRemainder[firstDigit+1 ..< fullPaddedRemainder.count])
                        }
                        if remainingDigits != "" {
                            fullRemainder = firstDecimalUnit + decimalSeparator + remainingDigits
                        } else {
                            fullRemainder = firstDecimalUnit
                        }
                        firstDigit = firstDigit + 1;
                        break
                    }
                }
                return fullRemainder + "e-" + String(firstDigit)
            }
        }

        if (toDecimals == 0) {
            return String(quotient)
        }

        return String(quotient) + decimalSeparator + remainderPadded
    }
}
