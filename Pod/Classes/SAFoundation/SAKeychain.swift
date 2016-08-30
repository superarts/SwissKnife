import UIKit
import Security

// Identifiers
//let serviceIdentifier = "MySerivice"
let userAccount = "SAKeychain"
//let accessGroup = "MySerivice"

// Arguments for the keychain queries
/*
let kSASecClassValue = kSASecClass.takeRetainedValue() as NSString
let kSASecAttrAccountValue = kSASecAttrAccount.takeRetainedValue() as NSString
let kSASecValueDataValue = kSASecValueData.takeRetainedValue() as NSString
let kSASecClassGenericPasswordValue = kSASecClassGenericPassword.takeRetainedValue() as NSString
let kSASecAttrServiceValue = kSASecAttrService.takeRetainedValue() as NSString
let kSASecMatchLimitValue = kSASecMatchLimit.takeRetainedValue() as NSString
let kSASecReturnDataValue = kSASecReturnData.takeRetainedValue() as NSString
let kSASecMatchLimitOneValue = kSASecMatchLimitOne.takeRetainedValue() as NSString
*/
let kSASecClassValue				= NSString(format:kSecClass)
let kSASecAttrAccountValue			= NSString(format:kSecAttrAccount)
let kSASecValueDataValue			= NSString(format:kSecValueData)
let kSASecClassGenericPasswordValue	= NSString(format:kSecClassGenericPassword)
let kSASecAttrServiceValue			= NSString(format:kSecAttrService)
let kSASecMatchLimitValue			= NSString(format:kSecMatchLimit)
let kSASecReturnDataValue			= NSString(format:kSecReturnData)
let kSASecMatchLimitOneValue		= NSString(format:kSecMatchLimitOne)

public class SAKeychain: NSObject {

  public class func save(key: String, _ data: NSString) {
    let dataFromString: NSData = data.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!

    // Instantiate a new default keychain query
    let keychainQuery: NSMutableDictionary = NSMutableDictionary(objects: [kSASecClassGenericPasswordValue, key, userAccount, dataFromString], forKeys: [kSASecClassValue, kSASecAttrServiceValue, kSASecAttrAccountValue, kSASecValueDataValue])

    // Delete any existing items
    SecItemDelete(keychainQuery as CFDictionaryRef)

    // Add the new keychain item
    //var status: OSStatus = SecItemAdd(keychainQuery as CFDictionaryRef, nil)
  }

  public class func load(key: String) -> String? {
    // Instantiate a new default keychain query
    // Tell the query to return a result
    // Limit our results to one item
    let keychainQuery: NSMutableDictionary = NSMutableDictionary(objects: [kSASecClassGenericPasswordValue, key, userAccount, kCFBooleanTrue, kSASecMatchLimitOneValue], forKeys: [kSASecClassValue, kSASecAttrServiceValue, kSASecAttrAccountValue, kSASecReturnDataValue, kSASecMatchLimitValue])

    /*
    var dataTypeRef :Unmanaged<AnyObject>?
    // Search for the keychain items
    let status: OSStatus = SecItemCopyMatching(keychainQuery, &dataTypeRef)
    let opaque = dataTypeRef?.toOpaque()
    if let op = opaque {
		let retrievedData = Unmanaged<NSData>.fromOpaque(op).takeUnretainedValue()
		...
    */
    
    var obj: AnyObject?
    let status: OSStatus = SecItemCopyMatching(keychainQuery, &obj)

    var contentsOfKeychain: NSString?

    if let data = obj as? NSData where status == errSecSuccess {
      contentsOfKeychain = NSString(data: data, encoding: NSUTF8StringEncoding)
    } else {
      print("Nothing was retrieved from the keychain. Status code \(status)", terminator: "")
    }

    return contentsOfKeychain as? String
  }
}