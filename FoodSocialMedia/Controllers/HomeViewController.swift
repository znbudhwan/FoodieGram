//
//  HomeViewController.swift
//  FoodSocialMedia
//
//  Created by Zain Budhwani on 8/19/18.
//  Copyright © 2018 Zain Budhwani. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit
import FBSDKCoreKit

class HomeViewController: UIViewController, PinterestLayoutDelegate, UICollectionViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var user: User!
    var tapGestureRecognizer: UITapGestureRecognizer!
    //var refHandleUserChanged: DatabaseHandle!
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.showSettingsController(_:)))
        tapGestureRecognizer.cancelsTouchesInView = false
        self.navigationController?.navigationBar.addGestureRecognizer(tapGestureRecognizer)
        
//        let uid = Auth.auth().currentUser?.uid
//        refHandleUserChanged = Database.database().reference().child("users").child(uid!).observe(.childChanged, with: { (snapshot) in
//            var userSnapshot = snapshot.children.allObjects as? [DataSnapshot]
//            if let userChangedIndex = userSnapshot?.index(where: {$0.key == snapshot.key}) {
//                userSnapshot![userChangedIndex] = snapshot
//                DispatchQueue.main.async {
//                    self.collectionView.reloadItems(at: [IndexPath(row: userChangedIndex, section: 0)])
//                }
//            }
//
//        }, withCancel: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.navigationController?.navigationBar.removeGestureRecognizer(tapGestureRecognizer)
    }
    
    func fetchUser() {
        user = User()
        let uid = Auth.auth().currentUser?.uid
        Database.database().reference().child("users").child(uid!).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                self.user.name = dictionary["name"] as? String
                self.user.email = dictionary["email"] as? String
                self.user.profileURL = dictionary["profileURL"] as? String
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }
        }, withCancel: nil)
        Database.database().reference().child("users").child(uid!).child("posts").observe(.childAdded, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                if let imageStorageURL = dictionary["imageStorageURL"] as? String, let imageSizeHeight = dictionary["imageSizeHeight"] as? CGFloat {
                    self.user.posts.append(imageStorageURL)
                    self.user.postsHeight.append(imageSizeHeight)
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                    }
                }
            }
        }, withCancel: nil)
    }
    
    func setTitle() {
        let uid = Auth.auth().currentUser?.uid
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
    
    @objc func showSettingsController(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: self.navigationController?.navigationBar)
        let hitView = self.navigationController?.navigationBar.hitTest(location, with: nil)
        
        guard !(hitView is UIControl) else { return }
        print("Navigation bar touched")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.0, execute: {
            self.performSegue(withIdentifier: "showSettings", sender: nil)
        })
    }
    
    @IBAction func addPictureToDatabase(_ sender: UIBarButtonItem) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.allowsEditing = true
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let userSelectedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        let userSelectedImageHeight = userSelectedImage.size.height
        let imageName = NSUUID().uuidString
        let storageRef = Storage.storage().reference().child("post_images").child("\(imageName).jpg")
        let uid = Auth.auth().currentUser?.uid
        let postsRef = Database.database().reference(fromURL: "https://foodsocialmedia-fa4a9.firebaseio.com/").child("users").child(uid!).child("posts").childByAutoId()
        if let uploadData = UIImageJPEGRepresentation(userSelectedImage, 0.1) {
            storageRef.putData(uploadData, metadata: nil, completion: { (storageMetaData, error) in
                if error != nil {
                    print(error?.localizedDescription as Any)
                    return
                }
                if let imageStorageURL = storageMetaData?.downloadURL() {
                    let values = ["imageStorageURL": imageStorageURL.absoluteString, "imageSizeHeight": userSelectedImageHeight] as [String : Any]
                    postsRef.updateChildValues(values)
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                    }
                }
            })
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat {
        return user.postsHeight[indexPath.row] * 0.45
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (user.posts.count)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FeedPhotoCell", for: indexPath) as? FeedPhotoViewCell
        
        let imageStorageDownloadURL = URL(string: user.posts[indexPath.row])
        URLSession.shared.dataTask(with: imageStorageDownloadURL!, completionHandler:  { (data, response, error) in
            if(error != nil) {
                print(error?.localizedDescription as Any)
                return
            }
            DispatchQueue.main.async {
                if let feedPhotoImage = UIImage(data: data!) {
                    cell?.feedPhotoImageVIew.image = feedPhotoImage
                    cell?.feedPhotoImageVIew.layer.cornerRadius = 20
                }
            }
        }).resume()
        
        return cell!
    }
}
