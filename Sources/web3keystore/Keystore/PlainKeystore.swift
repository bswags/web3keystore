//
//  PlainKeystore.swift
//  web3keystore
//
//  Created by Brian Wagner on 2/12/22.
//

import Foundation

public class PlainKeystore: AbstractKeystore {

    public var isHDKeystore: Bool = false

    private var privateKey: Data

    public var addresses: [EthereumAddress]?

    public func UNSAFE_getPrivateKeyData(password: String = "", account: EthereumAddress) throws -> Data {
        return self.privateKey
    }

    public convenience init?(privateKey: String) {
        guard let privateKeyData = Data.fromHex(privateKey) else { return nil }
        self.init(privateKey: privateKeyData)
    }

    public init?(privateKey: Data) {
        guard SECP256K1.verifyPrivateKey(privateKey: privateKey) else { return nil }
        guard let publicKey = privateToPublic(privateKey, compressed: false) else { return nil }
        guard let address = publicToAddress(publicKey) else { return nil }
        self.addresses = [address]
        self.privateKey = privateKey
    }
}
