import CryptoSwift
import Foundation

extension String {
    
    func encryptWithAES() -> String? {
        guard let aesKey = SecurityKey.aesKeys else {
            return nil
        }
        do {
            let encrypted = try self.aes256Encrypt(key: aesKey.key, iv: aesKey.iv)
            return encrypted
        } catch {
            print("Error:", error)
            return nil
        }
    }
    
    func decryptWithAES() -> String? {
        guard let aesKey = SecurityKey.aesKeys else {
            return nil
        }
        do {
            let decrypted = try self.aes256Decrypt(key: aesKey.key, iv: aesKey.iv)
            return decrypted
        } catch {
            print("Error:", error)
            return nil
        }
    }
    
    func aes256Encrypt(key: String, iv: String) throws -> String {
        let data = Data(self.utf8)
        let encrypted = try AES(
            key: Array(key.utf8),              // 32 bytes
            blockMode: CBC(iv: Array(iv.utf8)),// 16 bytes
            padding: .pkcs7
        ).encrypt([UInt8](data))
        return Data(encrypted).base64EncodedString()
    }

    func aes256Decrypt(key: String, iv: String) throws -> String {
        let data = Data(base64Encoded: self)!
        let decrypted = try AES(
            key: Array(key.utf8),              // 32 bytes
            blockMode: CBC(iv: Array(iv.utf8)),// 16 bytes
            padding: .pkcs7
        ).decrypt([UInt8](data))
        return String(data: Data(decrypted), encoding: .utf8)!
    }
}
