//
//  Keychain.swift
//  BioAuthTest
//
//  Created by Thyeon on 07/01/2019.
//  Copyright © 2019 thhan. All rights reserved.
//

import Foundation
import Security

class Keychain {
    
    private let _kSecClass = String(kSecClass)
    private let _kSecAttrAccount = String(kSecAttrAccount)
    private let _kSecValueData = String(kSecValueData)
    private let _kSecClassGenericPassword = String(kSecClassGenericPassword)
    private let _kSecAttrService = String(kSecAttrService)
    private let _kSecMatchLimit = String(kSecMatchLimit)
    private let _kSecReturnData = String(kSecReturnData)
    private let _kSecMatchLimitOne = String(kSecMatchLimitOne)
    private let _kSecAttrAccessible = String(kSecAttrAccessible)
    
    private let WalletSecAttrService = "walletSecAttrService"
    
    enum key: String, EnumCollection {
        case pin = "pin"
        case pinFailCount = "pinFailCount"
        case pinFailTime = "pinFailTime"
        case importedPriKey = "importedPriKey"
        case encPriKey = "encPriKey"
        case seed = "seed"
    }
    
    enum error: Error {
        case convert(String)
        case keychainError(NSError)
    }
    
    func set(account: String, value: String, authenticated: Bool) throws -> Bool {
        let accessible = (authenticated) ? String(kSecAttrAccessibleWhenUnlockedThisDeviceOnly) : String(kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly)
        
        guard let data = value.data(using: .utf8) else {
            throw error.convert("set error : value convert to data")
        }
        
        let query: CFDictionary = [
            _kSecClass: _kSecClassGenericPassword,
            _kSecAttrService: WalletSecAttrService,
            _kSecAttrAccount: account,
            _kSecValueData: data,
            _kSecAttrAccessible: accessible
            ] as CFDictionary
        
        var status = SecItemDelete(query)
        status = SecItemAdd(query, nil)
        
        guard status == noErr else {
            throw error.keychainError(NSError(domain: NSOSStatusErrorDomain, code: Int(status)))
        }
        
        return true
    }
    
    func get(account: String) throws -> String? {
        let query: CFDictionary = [
            _kSecClass: _kSecClassGenericPassword,
            _kSecAttrService: WalletSecAttrService,
            _kSecAttrAccount: account,
            _kSecReturnData: kCFBooleanTrue,
            _kSecMatchLimit: _kSecMatchLimitOne
            ] as CFDictionary
        
        var buffer: AnyObject?
        let status = SecItemCopyMatching(query, &buffer)
        
        if status == errSecSuccess {
            if let data = buffer as? Data {
                return String(data: data, encoding: .utf8)
            } else {
                throw error.convert("set error : value convert to data")
            }
        } else {
            throw error.keychainError(NSError(domain: NSOSStatusErrorDomain, code: Int(status)))
        }
    }
    
    func delete(account: String) throws {
        let query: CFDictionary = [
            _kSecClass: _kSecClassGenericPassword,
            _kSecAttrService: WalletSecAttrService,
            _kSecAttrAccount: account
            ] as CFDictionary
        
        let status = SecItemDelete(query)
        
        guard status == noErr else {
            throw error.keychainError(NSError(domain: NSOSStatusErrorDomain, code: Int(status)))
        }
    }
    
    func deleteAll(completetion: (Bool) -> ()) throws {
        for key in key.cases() {
            do {
                try delete(account: key.rawValue)
            } catch error.keychainError(let e) {
                throw error.keychainError(e)
            }
        }
        
        completetion(true)
    }
    
}

extension Keychain {
    
    func setImportedPriKey(privateKey: String, with address: String, authenticated: Bool) throws -> Bool {
        let importedPriKey = key.importedPriKey.rawValue + address
        do {
            return try set(account: importedPriKey, value: privateKey, authenticated: authenticated)
        } catch error.convert(let e) {
            throw error.convert(e)
        } catch error.keychainError(let e) {
            throw error.keychainError(e)
        }
    }
    
    func getImportedPriKey(address: String) throws -> String? {
        let importedPriKey = key.importedPriKey.rawValue + address
        do {
            return try get(account: importedPriKey)
        } catch error.convert(let e) {
            throw error.convert(e)
        } catch error.keychainError(let e) {
            throw error.keychainError(e)
        }
    }
    
    func deleteImportedPriKey(address: String) throws {
        let importedPriKey = key.importedPriKey.rawValue + address
        do {
            try delete(account: importedPriKey)
        } catch error.keychainError(let e) {
            throw error.keychainError(e)
        }
    }
    
}


