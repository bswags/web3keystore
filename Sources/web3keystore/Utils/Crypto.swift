//
//  Crypto.swift
//  web3keystore
//
//  Created by Brian Wagner on 2/12/22.
//

import Foundation
import libscrypt

enum Scrypt {
    enum ScryptError: Error {
        case invalidLength
        case invalidParameters
        case emptySalt
        case unknownError(code: Int32)
    }

    static func calculate(password: Array<UInt8>, salt: Array<UInt8>, dkLen: Int, N: Int, r: Int, p: Int) throws -> [UInt8] {
        guard dkLen > 0, UInt64(dkLen) <= 137_438_953_440 else {
            throw ScryptError.invalidLength
        }
        guard r > 0, p > 0, r * p < 1_073_741_824, N.isPowerOfTwo else {
            throw ScryptError.invalidParameters
        }

        var rv = [UInt8](repeating: 0, count: dkLen)
        var result: Int32 = -1

        try rv.withUnsafeMutableBufferPointer { bufptr in
            try password.withUnsafeBufferPointer { passwd in

                try salt.withUnsafeBufferPointer { saltptr in
                    guard !saltptr.isEmpty else {
                        throw ScryptError.emptySalt
                    }
                    result = libscrypt_scrypt(
                        passwd.baseAddress!, passwd.count,
                        saltptr.baseAddress!, saltptr.count,
                        UInt64(N), UInt32(r), UInt32(p),
                        bufptr.baseAddress!, dkLen
                    )
                }
            }
        }

        guard result == 0 else {
            throw ScryptError.unknownError(code: result)
        }

        return rv
    }
}

private extension BinaryInteger {
    var isPowerOfTwo: Bool {
        (self > 0) && (self & (self - 1) == 0)
    }
}

func scrypt (password: String, salt: Data, length: Int, N: Int, R: Int, P: Int) -> Data? {
    guard let passwordData = password.data(using: .utf8) else {
        return nil
    }

    guard let result = try? Scrypt.calculate(password: passwordData.bytes, salt: salt.bytes, dkLen: length, N: N, r: R, p: P) else {
        return nil
    }

    return Data(result)
}

/// Convert the private key (32 bytes of Data) to compressed (33 bytes) or non-compressed (65 bytes) public key.
func privateToPublic(_ privateKey: Data, compressed: Bool = false) -> Data? {
    return SECP256K1.privateToPublic(privateKey: privateKey, compressed: compressed)
}

/// Convert a public key to the corresponding EthereumAddress.
/// Accepts public keys in compressed (33 bytes), non-compressed (65 bytes) or raw concat(X,Y) (64 bytes) format.
///
/// Returns 20 bytes of address data.
func publicToAddressData(_ publicKey: Data) -> Data? {
    if publicKey.count == 33 {
        guard let decompressedKey = SECP256K1.combineSerializedPublicKeys(keys: [publicKey], outputCompressed: false) else {
            return nil
        }

        return publicToAddressData(decompressedKey)
    }

    var stipped = publicKey
    if (stipped.count == 65) {
        if (stipped[0] != 4) {
            return nil
        }
        stipped = stipped[1...64]
    }

    if (stipped.count != 64) {
        return nil
    }

    let sha3 = stipped.sha3(.keccak256)
    return sha3[12...31]
}

/// Convert a public key to the corresponding EthereumAddress.
/// Accepts public keys in compressed (33 bytes), non-compressed (65 bytes) or raw concat(X,Y) (64 bytes) format.
///
/// Returns the EthereumAddress object.
func publicToAddress(_ publicKey: Data) -> EthereumAddress? {
    guard let addressData = publicToAddressData(publicKey) else {
        return nil
    }

    let address = addressData.toHexString().addHexPrefix().lowercased()
    return EthereumAddress(address)
}
