//
//  ProfileButtonView.swift
//  ezCard
//
//  Created by Andrew Whitehead on 3/6/19.
//  Copyright © 2019 Andrew Whitehead. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseStorage

class ProfileButtonView: UIView {
    
    private struct Constants {
        static let defaultProfileButtonSize = CGFloat(40.0)
        static let shadowOffset = CGFloat(2.0)
    }
    
    var tappedCallback: (() -> Void)?

    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: Constants.defaultProfileButtonSize, height: Constants.defaultProfileButtonSize))
        
        commonInit()
    }
    
    private override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    func commonInit() {
        let profileButton = UIButton(frame: CGRect(x: 0, y: -Constants.shadowOffset, width: frame.width, height: frame.height))
        profileButton.backgroundColor = .lightGray
        profileButton.layer.cornerRadius = profileButton.frame.width / 2
        profileButton.layer.borderWidth = 3.0
        profileButton.layer.borderColor = UIColor.white.cgColor
        profileButton.layer.masksToBounds = false
        profileButton.layer.shadowOffset = CGSize(width: 0, height: Constants.shadowOffset)
        profileButton.layer.shadowRadius = 2.0
        profileButton.layer.shadowOpacity = 0.5
        profileButton.addTarget(self, action: #selector(profileButtonTapped(_:)), for: .touchUpInside)
        addSubview(profileButton)
        
        let profileImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: profileButton.frame.width, height: profileButton.frame.height))
        profileImageView.layer.masksToBounds = true
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        profileImageView.tintColor = .darkGray
        profileImageView.image = #imageLiteral(resourceName: "person")
        profileImageView.contentMode = .bottom
        
        profileButton.addSubview(profileImageView)
        
        weak var weakProfileImageView = profileImageView
        Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
            guard let user = user else {
                return
            }
            
            self?.fetchProfileImage(for: user) { (image, error) in
                guard let profileImage = image else {
                    return
                }
                
                weakProfileImageView?.image = profileImage
                weakProfileImageView?.contentMode = .scaleAspectFill
            }
        }
    }
    
    @objc private func profileButtonTapped(_ sender: Any?) {
        tappedCallback?()
    }
    
    private func fetchProfileImage(for user: User, forceRefetch: Bool = false, completion: @escaping ((UIImage?, Error?) -> Void)) {
        let cacheKey = "profile_image_\(user.uid)"
        
        if let imageFromCache = profileImageCache.object(forKey: cacheKey as AnyObject) as? UIImage, !forceRefetch {
            completion(imageFromCache, nil)
        } else {
            let profileImgRef = Storage.storage().reference().child("profile_images").child("\(user.uid).jpg")
            
            // limit profile images to 2MB (2 * 1024 * 1024 bytes)
            profileImgRef.getData(maxSize: 2 * 1024 * 1024) { data, error in
                if let error = error {
                    print("Error fetching profile image:", error)
                    completion(nil, error)
                } else {
                    let image = UIImage(data: data!)!
                    profileImageCache.setObject(image, forKey: cacheKey as AnyObject)
                    completion(image, error)
                }
            }
        }
    }

}
