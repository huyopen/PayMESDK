//
//  CryptoAES.swift
//  PayMESDK
//
//  Created by HuyOpen on 9/29/20.
//  Copyright © 2020 PayME. All rights reserved.
//

import Foundation
import CryptoSwift
import CommonCrypto

public class CryptoAES: NSObject {
  public static func encryptAES(text: String, password: String) -> String {
    var keyAndIv = Data.init(count: 0)
    var hash = Data.init(count: 0)
    let salt = self.randomData(ofLength: 8)
    let passpharse = password.bytes
    let passAndSalt = passpharse + salt
    
    while (keyAndIv.count < 48) {
      hash = MD5(messageData: hash + Data.init(_: passAndSalt))
      keyAndIv += hash
    }
    
    let iv = keyAndIv.subdata(in: 32..<48)
    let key = keyAndIv.subdata(in: 0..<32)
    
    let bytesIV = [UInt8](iv as Data)
    let bytesKey = [UInt8](key as Data)
    
    do {
      let encrypted = try AES(key: bytesKey, blockMode: CBC(iv: bytesIV), padding: .pkcs5)
      let cipherText = try! encrypted.encrypt(text.bytes)
      let saltData = "Salted__".bytes
      let finalData = saltData + salt + cipherText
      return finalData.toBase64()!
    } catch {
      return ""
    }
  }
  
  public static func decryptAES(text: String, password: String) -> String {
    let passpharse = password.bytes
    let inBytes = self.decodeBase64(base64Encoded: text)
    let salt = self.copyOfRange(arr: inBytes!, from: "Salted__".bytes.count, to: "Salted__".bytes.count + 8)
    let passAndSalt = passpharse + salt!
    var keyAndIv = Data.init(count: 0)
    var hash = Data.init(count: 0)
  
    while (keyAndIv.count < 48) {
      hash = MD5(messageData: hash + Data.init(_: passAndSalt))
      keyAndIv += hash
    }
    
    let iv = keyAndIv.subdata(in: 32..<48)
    let key = keyAndIv.subdata(in: 0..<32)
    
    let bytesIV = [UInt8](iv as Data)
    let bytesKey = [UInt8](key as Data)
    
    do {
      let decrypted = try AES(key: bytesKey, blockMode: CBC(iv: bytesIV), padding: .pkcs5)
      let cipherText = try! decrypted.decrypt(self.copyOfRange(arr: inBytes!, from: 16, to: inBytes!.count)!)
      return String(bytes: cipherText, encoding: .utf8)!
    } catch {
      return ""
    }
  }
  
  private static func randomData(ofLength length: Int) -> Array<UInt8> {
    var bytes = [UInt8](repeating: 0, count: length)
    let status = SecRandomCopyBytes(kSecRandomDefault, length, &bytes)
    if status == errSecSuccess {
      return bytes
    }
    return Data.init(count: 0).bytes
  }
  
  
  private static func MD5(messageData: Data) -> Data {
    let length = Int(CC_MD5_DIGEST_LENGTH)
    var digestData = Data(count: length)
    
    _ = digestData.withUnsafeMutableBytes { digestBytes -> UInt8 in
      messageData.withUnsafeBytes { messageBytes -> UInt8 in
        if let messageBytesBaseAddress = messageBytes.baseAddress, let digestBytesBlindMemory = digestBytes.bindMemory(to: UInt8.self).baseAddress {
          let messageLength = CC_LONG(messageData.count)
          CC_MD5(messageBytesBaseAddress, messageLength, digestBytesBlindMemory)
        }
        return 0
      }
    }
    return digestData
  }
  
  private static func decodeBase64(base64Encoded: String) -> Array<UInt8>? {
    guard let data = Data(base64Encoded: base64Encoded) else { return nil }
    return data.bytes
  }
  
  private static func copyOfRange<T>(arr: [T], from: Int, to: Int) -> [T]? where T: ExpressibleByIntegerLiteral {
    guard from >= 0 && from <= arr.count && from <= to else { return nil }
    var to = to
    var padding = 0
    if to > arr.count {
      padding = to - arr.count
      to = arr.count
    }
    return Array(arr[from..<to]) + [T](repeating: 0, count: padding)
  }
  
  public static func MD5(_ string: String) -> String? {
    let length = Int(CC_MD5_DIGEST_LENGTH)
    var digest = [UInt8](repeating: 0, count: length)
    
    if let d = string.data(using: String.Encoding.utf8) {
      _ = d.withUnsafeBytes { (body: UnsafePointer<UInt8>) in
        CC_MD5(body, CC_LONG(d.count), &digest)
      }
    }
    
    return (0..<length).reduce("") {
      $0 + String(format: "%02x", digest[$1])
    }
  }
}
