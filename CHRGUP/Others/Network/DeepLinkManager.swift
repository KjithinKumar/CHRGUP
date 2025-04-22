//
//  DeepLinkManager.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 17/04/25.
//

import UIKit
import CryptoSwift
import Foundation


class DeepLinkManager {
    static let shared = DeepLinkManager()
    var pendingPayload: QRPayload?
    func handle(url: URL) -> QRPayload?{
        guard url.scheme == "chrgup",
              url.host == "scan",
              let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let payload = components.queryItems?.first(where: { $0.name == "payload" })?.value else {
            return nil
        }
        if let decrypted = decryptPayload(encryptedBase64: payload, password: "Ankit@Sinha"){
            if let payload = decodeDecryptedPayload(decryptedText: decrypted){
                return payload
            }
        } else {
            debugPrint("Decryption failed")
            return nil
        }
        return nil
    }
    func decryptPayload(encryptedBase64: String, password: String) -> String? {
        guard let fullData = Data(base64Encoded: encryptedBase64) else {return nil}
        let prefix = "Salted__".data(using: .utf8)!
        guard fullData.prefix(8) == prefix else {return nil}
        let salt = fullData.subdata(in: 8..<16)
        let encrypted = fullData.subdata(in: 16..<fullData.count)
        // Derive key and IV using OpenSSL's EVP_BytesToKey (MD5-based KDF)
        guard let keyAndIV = evpBytesToKey(password: password, salt: salt, keyLength: 32, ivLength: 16) else {return nil}
        do {
            let aes = try AES(key: keyAndIV.key, blockMode: CBC(iv: keyAndIV.iv), padding: .pkcs7)
            let decryptedBytes = try aes.decrypt([UInt8](encrypted))
            guard let decryptedString = String(data: Data(decryptedBytes), encoding: .utf8) else {return nil}
            return decryptedString
        } catch {
            return nil
        }
    }

    // MARK: - EVP_BytesToKey (MD5-based like CryptoJS)
    private func evpBytesToKey(password: String, salt: Data, keyLength: Int, ivLength: Int) -> (key: [UInt8], iv: [UInt8])? {
        let passwordBytes = [UInt8](password.utf8)
        let saltBytes = [UInt8](salt)
        var derivedBytes = [UInt8]()
        var previous = [UInt8]()

        while derivedBytes.count < (keyLength + ivLength) {
            var hasher = MD5()

            do {
                _ = try hasher.update(withBytes: previous + passwordBytes + saltBytes)
                let digest = try hasher.finish()
                previous = digest
                derivedBytes.append(contentsOf: digest)
            } catch {
                return nil
            }
        }

        let key = Array(derivedBytes[0..<keyLength])
        let iv = Array(derivedBytes[keyLength..<(keyLength + ivLength)])
        return (key, iv)
    }
    func decodeDecryptedPayload(decryptedText: String) -> QRPayload? {
        guard let data = decryptedText.data(using: .utf8) else {return nil}
        let decoder = JSONDecoder()
        do {
            let decodedPayload = try decoder.decode(QRPayloadContainer.self, from: data)
            return decodedPayload.payload
        } catch {
            debugPrint("Failed to decode decrypted payload: \(error)")
            return nil
        }
    }
}
extension Notification.Name {
    static let DeepLinkPayloadReceived = Notification.Name("DeepLinkPayloadReceived")
}
