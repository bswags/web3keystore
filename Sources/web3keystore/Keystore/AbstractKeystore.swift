//
//  AbstractKeystore.swift
//  web3keystore
//
//  Created by Brian Wagner on 2/12/22.
//

import Foundation

public protocol AbstractKeystore {
    var addresses: [EthereumAddress]? { get }
    var isHDKeystore: Bool { get }

    func UNSAFE_getPrivateKeyData(password: String, account: EthereumAddress) throws -> Data
}

public enum AbstractKeystoreError: LocalizedError {
    case aesError
    case noEntropyError
    case keyDerivationError
    case invalidAccountError
    case invalidPasswordError
    case encryptionError(String)
}
