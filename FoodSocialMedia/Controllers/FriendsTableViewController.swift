//
//  FriendsTableViewController.swift
//  FoodSocialMedia
//
//  Created by Zain Budhwani on 8/28/18.
//  Copyright © 2018 Zain Budhwani. All rights reserved.
//

import UIKit
import Firebase

class FriendsTableViewController: UITableViewController {

    var friends = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchUsers()
        self.tableView.tableFooterView = UIView()
    }
    
    func fetchUsers() {
        Database.database().reference().child("users").observe(.childAdded, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let user = User()
                if Auth.auth().currentUser?.uid != snapshot.key {
                    user.name = dictionary["name"] as? String
                    user.email = dictionary["email"] as? String
                    user.profileURL = dictionary["profileURL"] as? String
                    user.userID = snapshot.key
                    self.friends.append(user)
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
        }, withCancel: nil)
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "friendsViewCell", for: indexPath) as! FriendsTableViewCell
        
        let user = friends[indexPath.row]
        
        cell.friendsCellNameLabel.text = user.name
        
        if let userProfileImageString = user.profileURL {
            let userProfileImageURL = URL(string: userProfileImageString)
            URLSession.shared.dataTask(with: userProfileImageURL!, completionHandler: { (data, response, error) in
                if error != nil {
                    print(error?.localizedDescription as Any)
                    return
                }
                DispatchQueue.main.async {
                    cell.friendsCellImageView.image = UIImage(data: data!)!
                }
            }).resume()
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.0, execute: {
            self.performSegue(withIdentifier: "showFriendsPhotos", sender: self)
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let recipientUser = self.friends[(self.tableView.indexPathForSelectedRow?.row)!]
        if segue.identifier == "showFriendsPhotos" {
            let navController = segue.destination
            let rootViewController = navController.childViewControllers.first as? FriendsPostsViewController
            rootViewController?.currentUser = recipientUser
        }
    }
    
}
