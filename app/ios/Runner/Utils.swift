//
//  Utils.swift
//  Runner
//
//  Created by xuqi zhong on 2021/8/10.
//

import CryptoSwift
import PassKit

class Aes {
    public static func encryptData(masterPassword: String, rawData: String)->String {
        let data = rawData.data(using: String.Encoding.utf8)
        let key = sha256(masterPassword)
        let iv = Array(sha256("ipfspass-f0znNj85f4pz-\(masterPassword)")[0...15])
        var encrypted: [UInt8] = []
        do {
            encrypted = try AES(key: key, blockMode: CBC(iv: iv)).encrypt(data!.bytes)
        } catch {
        }
        let encoded =  encrypted.map{ String(format: "%02x", $0)}.joined()
        return encoded
    }
    
    public static func decryptData(masterPassword: String, encryptedData: String)->String {
        let key = sha256(masterPassword)
        let iv = Array(sha256("ipfspass-f0znNj85f4pz-\(masterPassword)")[0...15])
        var encrypted: [UInt8] = []
        encrypted = hexaToBytes(encryptedData)
        var decrypted: [UInt8] = []
        do {
            decrypted = try AES(key: key, blockMode: CBC(iv: iv)).decrypt(encrypted)
        } catch {
        }
        let encoded = Data(decrypted)
        guard let str = String(bytes: encoded.bytes, encoding: .utf8) else {
            return ""
        }
        return str
    }
}

func sha256(_ str : String) -> [UInt8] {
    let data = str.data(using: String.Encoding.utf8)!
    var hash = [UInt8](repeating: 0,  count: Int(CC_SHA256_DIGEST_LENGTH))
    data.withUnsafeBytes {
        _ = CC_SHA256($0, CC_LONG(data.count), &hash)
    }
    return hash
}

func hexaToBytes(_ hexa: String) -> [UInt8] {
    var position = hexa.startIndex
    return (0..<hexa.count/2).compactMap { _ in
        defer { position = hexa.index(position, offsetBy: 2) }
        return UInt8(hexa[position...hexa.index(after: position)], radix: 16)
    }
}
