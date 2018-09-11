//
//  ViewController.swift
//  FoodSocialMedia
//
//  Created by Zain Budhwani on 8/13/18.
//  Copyright © 2018 Zain Budhwani. All rights reserved.
//

import UIKit
import Firebase
import FBSDKCoreKit
import FBSDKLoginKit
import MapKit

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate {

    // Create a global reference to our database and storage
    
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: Facebook Login Button
        
        let loginButton = FBSDKLoginButton.init(frame: CGRect(x: 16, y: view.frame.height - 150, width: view.frame.width - 32, height: 55))
        loginButton.readPermissions = ["email", "user_friends"]
        loginButton.delegate = self
        view.addSubview(loginButton)
        
        // MARK: Firebase Database
        
        ref = Database.database().reference(fromURL: "https://foodsocialmedia-fa4a9.firebaseio.com/")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)
        
        // Segue to Messaging Navigation Controller
        
        if FBSDKAccessToken.current() != nil {
            print("User is logged in currently")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.0, execute: {
                self.performSegue(withIdentifier: "performLogin", sender: nil)
            })
        }
    }
    
    // MARK: LoginButtonDelegate protocols
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        
        // MARK: Authenticating user and storing info inside of database
        
        if let error = error {
            print(error.localizedDescription)
            return
        }
        // Authenticating user
        
        if let accessToken = FBSDKAccessToken.current().tokenString {
            let credential = FacebookAuthProvider.credential(withAccessToken: accessToken)
            Auth.auth().signInAndRetrieveData(with: credential) { (authResult, error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                // User is signed in
                print("User signed in")
                // Storing user into datbase
                
                if let authenticationResult = authResult {
                    let user = authenticationResult.user
                    if let imageURL = authenticationResult.user.photoURL {
                        let profilePictureDownloadURL = imageURL.absoluteString
                        if let name = user.displayName, let email = user.email {
                            let values = ["name": name, "email": email, "profileURL": profilePictureDownloadURL]
                            let userReference = self.ref.child("users").child(authenticationResult.user.uid)
                            userReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
                                if let err = err {
                                    print(err.localizedDescription)
                                    return
                                }
                                // Saved in database
                                print("Saved in Firebase database")
                            })
                        }
                    }
                }
            }
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        // MARK: User has logged out
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        print("User signed out")
    }
}
