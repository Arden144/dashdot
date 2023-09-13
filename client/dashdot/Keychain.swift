//
//  Keychain.swift
//  dashdot
//
//  Created by Arden Sinclair on 2023-04-16.
//

import SwiftUI
import OSLog

enum Keychain {
    private static let logger = Logger(subsystem: "com.ardensinclair.dashdot", category: "Keychain")
    private static let account = "com.ardensinclair.dashdot"
    private static let encoder = JSONEncoder()
    private static let decoder = JSONDecoder()
    
    private static func getKeychainError(status: OSStatus) -> String {
        let error = SecCopyErrorMessageString(status, nil)
        
        switch error {
        case .some(let error):
            return error as String
        case .none:
            return "Unknown OSError"
        }
    }
    
    static func save<T>(_ item: T?, service: String) where T: Codable {
        guard let item else {
            delete(service: service)
            return
        }
        
        let data: Data
        do {
            data = try encoder.encode(item)
        } catch {
            logger.fault("Failed to encode '\(service, privacy: .public)' for keychain: \(error, privacy: .public)")
            return
        }
        
        let query = [
            kSecValueData: data,
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account,
        ] as [CFString : Any] as CFDictionary
        
        let status = SecItemAdd(query, nil)
        
        switch status {
        case errSecSuccess:
            logger.notice("Saved '\(service, privacy: .public)' to keychain")
        case errSecDuplicateItem:
            let query = [
                kSecAttrService: service,
                kSecAttrAccount: account,
                kSecClass: kSecClassGenericPassword,
            ] as [CFString : Any] as CFDictionary

            let attributesToUpdate = [kSecValueData: data] as CFDictionary

            let status = SecItemUpdate(query, attributesToUpdate)
            if status != errSecSuccess {
                logger.error("Error updating keychain entry '\(service, privacy: .public)': \(getKeychainError(status: status), privacy: .public)")
            }
        default:
            logger.error("Error saving keychain entry '\(service, privacy: .public)': \(getKeychainError(status: status), privacy: .public)")
        }
    }
    
    static func read<T>(service: String, type: T.Type) -> T? where T: Codable {
        let query = [
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecClass: kSecClassGenericPassword,
            kSecReturnData: true
        ] as [CFString : Any] as CFDictionary
        
        var result: AnyObject?
        SecItemCopyMatching(query, &result)
        
        guard let data = result as? Data else {
            logger.info("'\(service, privacy: .public)' doesn't exist in keychain")
            return nil
        }
        
        do {
            let data = try decoder.decode(type, from: data)
            logger.notice("Read '\(service, privacy: .public)' from keychain")
            return data
        } catch {
            logger.fault("Failed to decode '\(service, privacy: .public)' from keychain: \(error, privacy: .public)")
            delete(service: service)
            return nil
        }
    }
    
    static func delete(service: String) {
        let query = [
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecClass: kSecClassGenericPassword
        ] as [CFString : Any] as CFDictionary
        
        let status = SecItemDelete(query)
        
        if status != errSecSuccess {
            logger.error("Error updating keychain entry '\(service, privacy: .public)': \(getKeychainError(status: status), privacy: .public)")
        } else {
            logger.notice("Deleted '\(service, privacy: .public)' from keychain")
        }
    }
}
