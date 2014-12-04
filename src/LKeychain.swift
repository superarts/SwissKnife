import UIKit
import Security

// Identifiers
//let serviceIdentifier = "MySerivice"
let userAccount = "LKeychain"
//let accessGroup = "MySerivice"

// Arguments for the keychain queries
/*
let kSecClassValue = kSecClass.takeRetainedValue() as NSString
let kSecAttrAccountValue = kSecAttrAccount.takeRetainedValue() as NSString
let kSecValueDataValue = kSecValueData.takeRetainedValue() as NSString
let kSecClassGenericPasswordValue = kSecClassGenericPassword.takeRetainedValue() as NSString
let kSecAttrServiceValue = kSecAttrService.takeRetainedValue() as NSString
let kSecMatchLimitValue = kSecMatchLimit.takeRetainedValue() as NSString
let kSecReturnDataValue = kSecReturnData.takeRetainedValue() as NSString
let kSecMatchLimitOneValue = kSecMatchLimitOne.takeRetainedValue() as NSString
*/
let kSecClassValue = NSString(format:kSecClass)
let kSecAttrAccountValue = NSString(format:kSecAttrAccount)
let kSecValueDataValue = NSString(format:kSecValueData)
let kSecClassGenericPasswordValue = NSString(format:kSecClassGenericPassword)
let kSecAttrServiceValue = NSString(format:kSecAttrService)
let kSecMatchLimitValue = NSString(format:kSecMatchLimit)
let kSecReturnDataValue = NSString(format:kSecReturnData)
let kSecMatchLimitOneValue = NSString(format:kSecMatchLimitOne)

class LKeychain: NSObject {

  class func save(key: NSString, _ data: NSString) {
    var dataFromString: NSData = data.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!

    // Instantiate a new default keychain query
    var keychainQuery: NSMutableDictionary = NSMutableDictionary(objects: [kSecClassGenericPasswordValue, key, userAccount, dataFromString], forKeys: [kSecClassValue, kSecAttrServiceValue, kSecAttrAccountValue, kSecValueDataValue])

    // Delete any existing items
    SecItemDelete(keychainQuery as CFDictionaryRef)

    // Add the new keychain item
    var status: OSStatus = SecItemAdd(keychainQuery as CFDictionaryRef, nil)
  }

  class func load(key: NSString) -> NSString? {
    // Instantiate a new default keychain query
    // Tell the query to return a result
    // Limit our results to one item
    var keychainQuery: NSMutableDictionary = NSMutableDictionary(objects: [kSecClassGenericPasswordValue, key, userAccount, kCFBooleanTrue, kSecMatchLimitOneValue], forKeys: [kSecClassValue, kSecAttrServiceValue, kSecAttrAccountValue, kSecReturnDataValue, kSecMatchLimitValue])

    var dataTypeRef :Unmanaged<AnyObject>?

    // Search for the keychain items
    let status: OSStatus = SecItemCopyMatching(keychainQuery, &dataTypeRef)

    let opaque = dataTypeRef?.toOpaque()

    var contentsOfKeychain: NSString?

    if let op = opaque? {
      let retrievedData = Unmanaged<NSData>.fromOpaque(op).takeUnretainedValue()

      // Convert the data retrieved from the keychain into a string
      contentsOfKeychain = NSString(data: retrievedData, encoding: NSUTF8StringEncoding)
    } else {
      println("Nothing was retrieved from the keychain. Status code \(status)")
    }

    return contentsOfKeychain
  }
}
