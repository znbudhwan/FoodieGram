//
//  SettingsViewController.swift
//  FoodSocialMedia
//
//  Created by Zain Budhwani on 8/19/18.
//  Copyright © 2018 Zain Budhwani. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit
import FBSDKCoreKit

class SettingsViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()
    }

    @IBAction func cancelAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func logoutAction(_ sender: Any) {
        if FBSDKAccessToken.current() != nil {
            FBSDKLoginManager().logOut()
            self.dismiss(animated: false, completion: nil)
            self.presentingViewController?.dismiss(animated: true, completion: nil)
        }

    }
    
}
