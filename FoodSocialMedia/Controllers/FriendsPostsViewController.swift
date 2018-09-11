//
//  FriendsCollectionViewController.swift
//  FoodSocialMedia
//
//  Created by Zain Budhwani on 8/28/18.
//  Copyright © 2018 Zain Budhwani. All rights reserved.
//

import UIKit
import Firebase

class FriendsPostsViewController: UIViewController, PinterestLayoutDelegate, UICollectionViewDataSource, UICollectionViewDelegate {

    var currentUser = User()
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let layout = collectionView.collectionViewLayout as? PinterestLayout {
            layout.delegate = self
        }
        collectionView.delegate = self
        collectionView.contentInset = UIEdgeInsetsMake(10, 10, 10, 10)
        collectionView.dataSource = self
        setTitle()
        fetchUser()
    }
    
    func setTitle() {
        let uid = currentUser.userID
        Database.database().reference().child("users").child(uid!).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                // Put a view in our navbar
                let navView = UIView()
                navView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
                // Create a container for the subviews
                let containerView = UIView()
                containerView.translatesAutoresizingMaskIntoConstraints = false
                navView.addSubview(containerView)
                // Create a image in navbar
                let profilePictureImageView = UIImageView()
                if let profilePictureURLString = dictionary["profileURL"] as? String {
                    let profilePictureDownloadURL = URL(string: profilePictureURLString)
                    URLSession.shared.dataTask(with: profilePictureDownloadURL!, completionHandler: { (data, response, error) in
                        if(error != nil) {
                            print(error as Any)
                            return
                        }
                        DispatchQueue.main.async {
                            profilePictureImageView.image = UIImage(data: data!)!
                            profilePictureImageView.translatesAutoresizingMaskIntoConstraints = false
                            profilePictureImageView.contentMode = .scaleAspectFill
                            profilePictureImageView.layer.cornerRadius = 20
                            profilePictureImageView.clipsToBounds = true
                            containerView.addSubview(profilePictureImageView)
                            // Constraints for profilePictureImageView
                            profilePictureImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
                            profilePictureImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
                            profilePictureImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
                            profilePictureImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
                            // Create label in navbar
                            let nameLabel = UILabel()
                            containerView.addSubview(nameLabel)
                            nameLabel.text = dictionary["name"] as? String
                            nameLabel.font = UIFont.boldSystemFont(ofSize: 20)
                            nameLabel.translatesAutoresizingMaskIntoConstraints = false
                            // Constraints for nameLabel
                            nameLabel.leftAnchor.constraint(equalTo: profilePictureImageView.rightAnchor, constant: 8.0).isActive = true
                            nameLabel.centerYAnchor.constraint(equalTo: profilePictureImageView.centerYAnchor).isActive = true
                            nameLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
                            nameLabel.heightAnchor.constraint(equalTo: profilePictureImageView.heightAnchor).isActive = true
                            // Constraints for container view
                            containerView.centerXAnchor.constraint(equalTo: navView.centerXAnchor).isActive = true
                            containerView.centerYAnchor.constraint(equalTo: navView.centerYAnchor).isActive = true
                            
                            self.navigationItem.titleView = navView
                        }
                    }).resume()
                }
            }
        }, withCancel: nil)
    }
    
    func fetchUser() {
        let uid = currentUser.userID
        Database.database().reference().child("users").child(uid!).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                self.currentUser.name = dictionary["name"] as? String
                self.currentUser.email = dictionary["email"] as? String
                self.currentUser.profileURL = dictionary["profileURL"] as? String
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }
        }, withCancel: nil)
        Database.database().reference().child("users").child(uid!).child("posts").observe(.childAdded, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                if let imageStorageURL = dictionary["imageStorageURL"] as? String, let imageSizeHeight = dictionary["imageSizeHeight"] as? CGFloat {
                    self.currentUser.posts.append(imageStorageURL)
                    self.currentUser.postsHeight.append(imageSizeHeight)
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                    }
                }
            }
        }, withCancel: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat {
        return currentUser.postsHeight[indexPath.row] * 0.45
    }


    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currentUser.posts.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionView?.dequeueReusableCell(withReuseIdentifier: "FriendsPhotoCell", for: indexPath) as! FeedPhotoViewCell
        
        let imagePhotoString = currentUser.posts[indexPath.row]
        let imagePhotoURL = URL(string: imagePhotoString)
        URLSession.shared.dataTask(with: imagePhotoURL!) { (data, response, error) in
            if error != nil {
                print(error?.localizedDescription as Any)
                return
            }
            DispatchQueue.main.async {
                cell.feedPhotoImageVIew.image = UIImage(data: data!)!
            }
        }.resume()
        return cell
    }
    
    @IBAction func back(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
