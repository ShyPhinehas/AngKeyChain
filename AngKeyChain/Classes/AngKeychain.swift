
import Foundation

// Keychain 관련 쿼리 키 값들
let kSecClassValue           = NSString(format: kSecClass)
let kSecAttrAccountValue     = NSString(format: kSecAttrAccount)
let kSecValueDataValue       = NSString(format: kSecValueData)
let kSecAttrGenericValue     = NSString(format: kSecAttrGeneric)
let kSecAttrServiceValue     = NSString(format: kSecAttrService)
let kSecAttrAccessValue      = NSString(format: kSecAttrAccessible)
let kSecMatchLimitValue      = NSString(format: kSecMatchLimit)
let kSecReturnDataValue      = NSString(format: kSecReturnData)
let kSecMatchLimitOneValue   = NSString(format: kSecMatchLimitOne)
let kSecAttrAccessGroupValue = NSString(format: kSecAttrAccessGroup)
let kSecClassGenericPasswordValue = NSString(format: kSecClassGenericPassword)

open class AngKeyChain: NSObject {
    
    open var serviceIdentifier: String!
    public init(serviceIdentifier: String) {
        self.serviceIdentifier = serviceIdentifier
    }
    
    open static var uuid : String = {
        
        let serviceIdentifier : String = Bundle.main.bundleIdentifier ?? "ang_keychain"
        let keyName : String = serviceIdentifier + ".uuid"
        let tkc = AngKeyChain(serviceIdentifier: serviceIdentifier)
        
        if let data = tkc.dataFor(keyName: keyName){
            let uuid = String(data: data, encoding: String.Encoding.utf8)!
            print("saved uuid \(uuid)")
            return uuid
        }else{
            let uuid = NSUUID().uuidString.lowercased()//"\(arc4random() % 1000)"
            let _ = tkc.setData(value: uuid.data(using: String.Encoding.utf8)!, forKey: keyName)
            print("new uuid \(uuid)")
            return uuid
        }
        
    }()
    
    open static func resetAllData() {
        let _ = self.deleteAllKeysForSecClass(kSecClassGenericPassword)
        let _ = self.deleteAllKeysForSecClass(kSecClassInternetPassword)
        let _ = self.deleteAllKeysForSecClass(kSecClassCertificate)
        let _ = self.deleteAllKeysForSecClass(kSecClassKey)
        let _ = self.deleteAllKeysForSecClass(kSecClassIdentity)
        let _ = self.deleteAllKeysForSecClass(kSecValueData)
    }
    
    static private func deleteAllKeysForSecClass(_ selClass: CFTypeRef) -> Bool {
        let dict = NSMutableDictionary()
        dict.setObject(selClass, forKey: kSecClassValue)
        
        let status : OSStatus = SecItemDelete(dict)
        if status == errSecSuccess {
            return true
        }
        else {
            return false
        }
    }
    
    open func dataFor(keyName : String) -> Data? {
        let keychainQueryDictionary = self.keychainSearch(keyName: keyName)
        keychainQueryDictionary.setObject(kSecMatchLimitOneValue, forKey: kSecMatchLimitValue)
        keychainQueryDictionary.setObject(kCFBooleanTrue, forKey: kSecReturnDataValue)
        var dataTypeRef : AnyObject?
        let status = SecItemCopyMatching(keychainQueryDictionary, &dataTypeRef)
        if status == noErr {
            return dataTypeRef as? Data
        }
        return nil
    }
    
    open func setData(value: Data, forKey keyName: String, isUpdateNewVal: Bool = true) -> Bool {
        let keychainQueryDictionary : NSMutableDictionary = self.keychainSearch(keyName: keyName)
        keychainQueryDictionary.setObject(value, forKey: kSecValueDataValue)
        SecItemDelete(keychainQueryDictionary as CFDictionary)
        
        let status = SecItemAdd(keychainQueryDictionary as CFDictionary, nil)
        if status == errSecSuccess{
            return true
        }else if status == errSecDuplicateItem{
            return isUpdateNewVal ? self.updateData(value:value, forKey:keyName) : true
        }else{
            return false
        }
    }
    
    private func updateData(value: Data, forKey keyName: String) -> Bool {
        let keychainQueryDictionary: NSMutableDictionary = self.keychainSearch(keyName: keyName)
        let updateDictionary = [kSecValueDataValue : value]
        
        let status: OSStatus = SecItemUpdate(keychainQueryDictionary, updateDictionary as CFDictionary)
        if status == errSecSuccess {
            return true
        }
        else {
            return false
        }
    }

    private func keychainSearch(keyName: String) -> NSMutableDictionary {
        let keychainQueryDictionary: NSMutableDictionary = NSMutableDictionary()
        keychainQueryDictionary.setObject(kSecClassGenericPassword, forKey: kSecClassValue)
        keychainQueryDictionary.setObject(serviceIdentifier, forKey: kSecAttrServiceValue)
        keychainQueryDictionary.setObject(keyName.data(using: String.Encoding.utf8)!, forKey: kSecAttrAccountValue)
        return keychainQueryDictionary
    }
}
