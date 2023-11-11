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

open class SAKeychain: NSObject {
	open class func save(_ key: String, _ str: String?) {
		//let dataFromString: Data = data.data(using: String.Encoding.utf8.rawValue, allowLossyConversion: false)!
		if let dataFromString = str?.data(using: .utf8) {
			// Instantiate a new default keychain query
			let keychainQuery: NSMutableDictionary = NSMutableDictionary(objects: [kSASecClassGenericPasswordValue, key, userAccount, dataFromString], forKeys: [kSASecClassValue, kSASecAttrServiceValue, kSASecAttrAccountValue, kSASecValueDataValue])
			// Delete any existing items
			SecItemDelete(keychainQuery as CFDictionary)
			// Add the new keychain item
			let status: OSStatus = SecItemAdd(keychainQuery as CFDictionary, nil)
			print("KEYCHAIN saved: \(status)")
		}
	}

  open class func load(_ key: String) -> String? {
    // Instantiate a new default keychain query
    // Tell the query to return a result
    // Limit our results to one item
    let keychainQuery: NSMutableDictionary = NSMutableDictionary(objects: [kSASecClassGenericPasswordValue, key, userAccount, kCFBooleanTrue, kSASecMatchLimitOneValue], 
	forKeys: [kSASecClassValue, kSASecAttrServiceValue, kSASecAttrAccountValue, kSASecReturnDataValue, kSASecMatchLimitValue])

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

    if let data = obj as? Data , status == errSecSuccess {
      contentsOfKeychain = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
    } else {
      print("Nothing was retrieved from the keychain. Status code \(status)")
    }

    return contentsOfKeychain as String?
  }
  open class func load(_ key: String, `default`: String) -> String {
	  if let s = load(key) {
		  return s
	  }
	  return `default`
  }
}
