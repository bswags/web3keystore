//
//  Crypto.swift
//  web3keystore
//
//  Created by Brian Wagner on 2/12/22.
//

import Foundation
import CryptoSwift

func scrypt(password: String, salt: Data, length: Int, N: Int, R: Int, P: Int) -> Data? {
    guard let passwordData = password.data(using: .utf8) else { return nil }
    guard let deriver = try? Scrypt(password: passwordData.bytes, salt: salt.bytes, dkLen: length, N: N, r: R, p: P) else { return nil }
    guard let result = try? deriver.calculate() else { return nil }
    return Data(result)
}

/// Convert the private key (32 bytes of Data) to compressed (33 bytes) or non-compressed (65 bytes) public key.
func privateToPublic(_ privateKey: Data, compressed: Bool = false) -> Data? {
    guard let publicKey = SECP256K1.privateToPublic(privateKey: privateKey, compressed: compressed) else { return nil }
    return publicKey
}

/// Convert a public key to the corresponding ``EthereumAddress``. Accepts public keys in compressed (33 bytes), uncompressed (65 bytes)
/// or uncompressed without prefix (64 bytes) format.
///
/// - Parameter publicKey: compressed 33, non-compressed (65 bytes) or non-compressed without prefix (64 bytes)
/// - Returns: 20 bytes of address data.
func publicToAddressData(_ publicKey: Data) -> Data? {
    var publicKey = publicKey
    if publicKey.count == 33 {
        guard
            (publicKey[0] == 2 || publicKey[0] == 3),
            let decompressedKey = SECP256K1.combineSerializedPublicKeys(keys: [publicKey], outputCompressed: false)
        else {
            return nil
        }
        publicKey = decompressedKey
    }

    if publicKey.count == 65 {
        guard publicKey[0] == 4 else {
            return nil
        }
        publicKey = publicKey[1...64]
    } else if publicKey.count != 64 {
        return nil
    }
    let sha3 = publicKey.sha3(.keccak256)
    let addressData = sha3[12...31]
    return addressData
}

/// Convert a public key to the corresponding ``EthereumAddress``. Accepts public keys in compressed (33 bytes), uncompressed (65 bytes)
/// or uncompressed without prefix (64 bytes) format.
///
/// - Parameter publicKey: compressed 33, non-compressed (65 bytes) or non-compressed without prefix (64 bytes)
/// - Returns: `EthereumAddress` object.
func publicToAddress(_ publicKey: Data) -> EthereumAddress? {
    guard let addressData = publicToAddressData(publicKey) else { return nil }
    let address = addressData.toHexString().addHexPrefix().lowercased()
    return EthereumAddress(address)
}

/// Convert a public key to the corresponding ``EthereumAddress``. Accepts public keys in compressed (33 bytes), uncompressed (65 bytes)
/// or uncompressed without prefix (64 bytes) format.
///
/// - Parameter publicKey: compressed 33, non-compressed (65 bytes) or non-compressed without prefix (64 bytes)
/// - Returns: `0x` prefixed hex string.
func publicToAddressString(_ publicKey: Data) -> String? {
    guard let addressData = publicToAddressData(publicKey) else { return nil }
    let address = addressData.toHexString().addHexPrefix().lowercased()
    return address
}
