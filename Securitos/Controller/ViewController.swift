//
//  ViewController.swift
//  Securitos
//
//  Created by zein rezky chandra on 19/11/18.
//  Copyright © 2018 Zein. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    private enum TextFieldTag: Int {
        case email
        case password
    }
    
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        emailField.delegate = self
        emailField.tag = TextFieldTag.email.rawValue
        
        passwordField.delegate = self
        passwordField.tag = TextFieldTag.password.rawValue

        view.addGestureRecognizer(
            UITapGestureRecognizer(
                target: self,
                action: #selector(handleTap(_:))
            )
        )
        
        registerForKeyboardNotifications()
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAuthState),
            name: .loginStatusChanged,
            object: nil
        )
    }
    
    @objc func handleAuthState() {
        if AuthController.isSignedIn {
//            rootViewController = NavigationController(rootViewController: FriendsViewController())
            print("user loged in")
        } else {
//            rootViewController = AuthViewController()
            print("user not loged in")
        }
    }

    // MARK: - Actions
    
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    @IBAction func signInButtonPressed() {
        // sign in
        signIn()
    }

    // MARK: - Helpers
    
    private func signIn(){
        view.endEditing(true)
        guard let email = emailField.text, email.count > 0 else {
            return
        }
        guard let password = passwordField.text, password.count > 0 else {
            return
        }
        let name = UIDevice.current.name
        let user = User(name: name, email: email)
        
        do {
            try AuthController.signIn(user, password: password)
        } catch {
            print("Error signing in: \(error.localizedDescription)")
        }
    }
    
    private func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: NSNotification.Name.UIKeyboardWillShow,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: NSNotification.Name.UIKeyboardWillHide,
            object: nil
        )
    }
    
    // MARK: - Notifications
    
    @objc internal func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo else {
            return
        }
        guard let keyboardHeight = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height else {
            return
        }
        guard let keyboardAnimationDuration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue else {
            return
        }
        guard let keyboardAnimationCurve = (userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber)?.uintValue else {
            return
        }
        
        let options = UIViewAnimationOptions(rawValue: keyboardAnimationCurve << 16)
//        bottomConstraint.constant = keyboardHeight + 32
        
        UIView.animate(withDuration: keyboardAnimationDuration, delay: 0, options: options, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    @objc internal func keyboardWillHide(_ notification: Notification) {
        guard let userInfo = notification.userInfo else {
            return
        }
        guard let keyboardAnimationDuration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue else {
            return
        }
        guard let keyboardAnimationCurve = (userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber)?.uintValue else {
            return
        }
        
        let options = UIViewAnimationOptions(rawValue: keyboardAnimationCurve << 16)
//        bottomConstraint.constant = 0
        
        UIView.animate(withDuration: keyboardAnimationDuration, delay: 0, options: options, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }

}

extension ViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let text = textField.text, text.count > 0 else {
            return false
        }
        
        switch textField.tag {
        case TextFieldTag.email.rawValue:
            passwordField.becomeFirstResponder()
        case TextFieldTag.password.rawValue:
            signIn()
        default:
            return false
        }
        
        return true
    }
}

extension Notification.Name {
    static let loginStatusChanged = Notification.Name("com.razeware.auth.changed")
}

