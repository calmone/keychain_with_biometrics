//
//  Keychain.swift
//  BioAuthTest
//
//  Created by Thyeon on 07/01/2019.
//  Copyright © 2019 thhan. All rights reserved.
//

import Foundation
import Security

private let _kSecClass = String(kSecClass)
private let _kSecAttrAccount = String(kSecAttrAccount)
private let _kSecValueData = String(kSecValueData)
private let _kSecClassGenericPassword = String(kSecClassGenericPassword)
private let _kSecAttrService = String(kSecAttrService)
private let _kSecMatchLimit = String(kSecMatchLimit)
private let _kSecReturnData = String(kSecReturnData)
private let _kSecMatchLimitOne = String(kSecMatchLimitOne)

struct Keychain {
    
    static func set(service: String, account: String, value: String) {
        guard let data = value.data(using: .utf8) else { return }
        let query: CFDictionary = [
            _kSecClass: _kSecClassGenericPassword,
            _kSecAttrService: service,
            _kSecAttrAccount: account,
            _kSecValueData: data
        ] as CFDictionary
        
        SecItemDelete(query)
        SecItemAdd(query, nil)
    }
    
    static func get(service: String, account: String) -> String? {
        let query: CFDictionary = [
            _kSecClass: _kSecClassGenericPassword,
            _kSecAttrService: service,
            _kSecAttrAccount: account,
            _kSecReturnData: kCFBooleanTrue,
            _kSecMatchLimit: _kSecMatchLimitOne
        ] as CFDictionary
        
        var buffer: AnyObject?
        if SecItemCopyMatching(query, &buffer) == errSecSuccess {
            if let data = buffer as? Data {
                return String(data: data, encoding: .utf8)
            }
        }
        
        return nil
    }
    
    static func delete(service: String, account: String) {
        let query: CFDictionary = [
            _kSecClass: _kSecClassGenericPassword,
            _kSecAttrService: service,
            _kSecAttrAccount: account
        ] as CFDictionary
        
        SecItemDelete(query)
    }
    
}
