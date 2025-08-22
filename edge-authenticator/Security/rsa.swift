import Foundation
import CryptoKit

class RSA {
    // Decrypt with RSA private key from PEM
    func decryptRSA(encryptedData: Data, privateKeyPEM: String) throws -> Data {
        // Strip PEM header/footer
        let keyString = privateKeyPEM
            .replacingOccurrences(of: "-----BEGIN PRIVATE KEY-----", with: "")
            .replacingOccurrences(of: "-----END PRIVATE KEY-----", with: "")
            .replacingOccurrences(of: "\n", with: "")
        
        guard let keyData = Data(base64Encoded: keyString) else {
            throw NSError(domain: "InvalidKey", code: -1, userInfo: nil)
        }
        
        let attributes: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
            kSecAttrKeyClass as String: kSecAttrKeyClassPrivate,
            kSecAttrKeySizeInBits as String: 2048,
        ]
        
        var error: Unmanaged<CFError>?
        guard let secKey = SecKeyCreateWithData(keyData as CFData,
                                                attributes as CFDictionary,
                                                &error) else {
            throw error!.takeRetainedValue() as Error
        }
        
        guard let decryptedData = SecKeyCreateDecryptedData(secKey,
                                                            .rsaEncryptionPKCS1,
                                                            encryptedData as CFData,
                                                            &error) as Data? else {
            throw error!.takeRetainedValue() as Error
        }
        
        return decryptedData
    }
    
    /* Example usage
     func generateTOTP(encryptedSecret: Data, privateKeyPEM: String) {
     do {
     let decryptedSecret = try decryptRSA(encryptedData: encryptedSecret, privateKeyPEM: privateKeyPEM)
     
     // Create TOTP with SHA512, 6 digits, 30s step
     if let totp = TOTP(secret: decryptedSecret,
     digits: 6,
     timeInterval: 30,
     algorithm: .sha512) {
     if let code = totp.generate(time: Date()) {
     print("TOTP: \(code)")
     }
     }
     } catch {
     print("Decryption failed: \(error)")
     }
     }
     */
}
