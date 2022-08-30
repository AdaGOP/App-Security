//
//  AuthController.swift
//  Securitos
//
//  Created by zein rezky chandra on 19/11/18.
//  Copyright © 2018 Zein. All rights reserved.
//

import Foundation
import CryptoSwift

final class AuthController {
    static let serviceName = "AuthService"
    static var isSignedIn: Bool {
        
        /*
         Check the current user stored in UserDefaults.
         If no user exists, there won’t be an identifier to lookup the password hash from the Keychain, so you indicate they are not signed in.
         */
        guard let currentUser = Settings.currentUser else {
            return false
        }
        do {
            /*
             You read the password hash from the Keychain, and if a password exists and isn’t blank, the user is considered logged in.
             */
            let password = try KeychainManager(service: serviceName, account: currentUser.email).readPassword()
            return password.count > 0
        } catch {
            return false
        }
    }
    
    /*
     This method takes an email and password, and returns a hashed string.
     The salt is a unique string used to make common passwords, well, uncommon.
     sha256() is a CryptoSwift method that completes a type of SHA-2 hash on your input string.
     */
    
    class func passwordHash(from email: String, password: String) -> String {
        let salt = "x4vV8bGgqqmQwgCoyXFQj+(o.nUNQhVP7ND"
        return "\(password).\(email).\(salt)".sha256()
    }
    
    /*
     This method stores the user’s login information securely in the Keychain.
     It creates a KeychainPasswordItem with the service name you defined along with a unique identifier (account).
     */
    
    class func signIn(_ user: User, password: String) throws {
        let finalHash = passwordHash(from: user.email, password: password)
        try KeychainManager(service: serviceName, account: user.email).savePassword(finalHash)
        Settings.currentUser = user
        NotificationCenter.default.post(name: .loginStatusChanged, object: nil)
    }
    
    class func signOut() throws {
        // Check if you’ve stored a current user, and bail out early if you haven’t.
        guard let currentUser = Settings.currentUser else {
            return
        }
        
        // Delete the password hash from the Keychain.
        try KeychainManager(service: serviceName, account: currentUser.email).deleteItem()
        
        // Clear the user object and post the notification.
        Settings.currentUser = nil
        NotificationCenter.default.post(name: .loginStatusChanged, object: nil)
    }
}
