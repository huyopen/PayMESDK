//
//  CryptoRSA.swift
//  PayMESDK
//
//  Created by HuyOpen on 9/29/20.
//  Copyright © 2020 PayME. All rights reserved.
//

import Foundation
import Security
import SwiftyRSA

public class CryptoRSA {
    public static func encryptRSA(plainText: String, publicKey: String) throws -> String {
        let publicKey = try PublicKey(base64Encoded: publicKey)
        let clear = try ClearMessage(string: plainText, using: .utf8)
        let encrypted = try clear.encrypted(with: publicKey, padding: .OAEP)
        return encrypted.base64String
    }
    
    public static func decryptRSA(encryptedString: String, privateKey: String) throws -> String {
        let privateKey = try PrivateKey(base64Encoded: privateKey)
        let encrypted = try EncryptedMessage(base64Encoded: encryptedString)
        let clear = try encrypted.decrypted(with: privateKey, padding: .OAEP)
        return try clear.string(encoding: .utf8)
    }
}
