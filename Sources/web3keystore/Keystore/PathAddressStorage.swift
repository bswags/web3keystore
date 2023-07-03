//
//  PathAddressStorage.swift
//  web3keystore
//
//  Created by Brian Wagner on 2/12/22.
//

import Foundation

public struct PathAddressStorage {
    public private(set) var addresses: [EthereumAddress]
    public private(set) var paths: [String]

    init() {
        addresses = []
        paths = []
    }

    mutating func add(address: EthereumAddress, for path: String) {
        addresses.append(address)
        paths.append(path)
    }

    func path(by address: EthereumAddress) -> String? {
        guard let index = addresses.firstIndex(of: address) else { return nil }
        return paths[index]
    }
}

extension PathAddressStorage {
    init(pathAddressPairs: [PathAddressPair]) {
        var addresses = [EthereumAddress]()
        var paths = [String]()
        for pair in pathAddressPairs {
            guard let address = EthereumAddress(pair.address) else { continue }
            addresses.append(address)
            paths.append(pair.path)
        }

        assert(addresses.count == paths.count)

        self.addresses = addresses
        self.paths = paths
    }

    func toPathAddressPairs() -> [PathAddressPair] {
        var pathAddressPairs = [PathAddressPair]()
        for (index, path) in paths.enumerated() {
            let address = addresses[index]
            let pair = PathAddressPair(path: path, address: address.address)
            pathAddressPairs.append(pair)
        }
        return pathAddressPairs
    }
}
