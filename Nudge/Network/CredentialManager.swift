//
//  CredentialManager.swift
//  Nudge
//
//  Created by Eli Zhang on 1/22/22.
//

import Foundation
import KeychainAccess

struct CredentialManager {
    enum CredentialError: Error {
        case noUserId
        case noPassword
    }
    
    static let keychain = Keychain(service: "elizhang.Nudge")
    
    static func getUserId() -> String? {
        return keychain["userId"]
    }
    
    static func setUserId(userId: String) {
        keychain["userId"] = userId
    }
    
    static func getPassword() -> String? {
        return keychain["password"]
    }
    
    static func setPassword(password: String) {
        keychain["password"] = password
    }
}
