//
//  Errors.swift
//  web3keystore
//
//  Created by Brian Wagner on 2/12/22.
//

import Foundation

enum KeystoreError: LocalizedError {
    /// Something has gone wrong while manipulating data, likely in cryptography.
    case data
}
