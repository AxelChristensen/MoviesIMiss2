//
//  KeychainHelper.swift
//  MoviesIMiss2
//
//  Created by Axel Christensen on 3/19/26.
//

import Foundation
import Security

/// Helper class for securely storing sensitive data in the Keychain
class KeychainHelper {
    
    static let shared = KeychainHelper()
    
    private init() {}
    
    /// Save a string value to the Keychain
    /// - Parameters:
    ///   - key: The key to store the value under
    ///   - value: The string value to store
    /// - Returns: True if successful, false otherwise
    @discardableResult
    func save(key: String, value: String) -> Bool {
        guard let data = value.data(using: .utf8) else {
            return false
        }
        
        // Create query
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        
        // Delete any existing item
        SecItemDelete(query as CFDictionary)
        
        // Add new item
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    /// Retrieve a string value from the Keychain
    /// - Parameter key: The key to retrieve
    /// - Returns: The stored string value, or nil if not found
    func get(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let string = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        return string
    }
    
    /// Delete a value from the Keychain
    /// - Parameter key: The key to delete
    /// - Returns: True if successful or item didn't exist, false if there was an error
    @discardableResult
    func delete(key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }
}
