//
//  ProfileButtonView.swift
//  ezCard
//
//  Created by Andrew Whitehead on 3/6/19.
//  Copyright © 2019 Andrew Whitehead. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage

class ProfileButtonView: UIView {
    
    static let defaultSize = CGFloat(40.0)
    
    private struct Constants {
        static let shadowOffset = CGFloat(2.0)
    }
    
    private var profileImageView: UIImageView!
    private var profileButton: UIButton!
    
    var tappedCallback: (() -> Void)?
    
    convenience init() {
        self.init(buttonSize: ProfileButtonView.defaultSize)
    }

    init(buttonSize: CGFloat) {
        super.init(frame: CGRect(x: 0, y: 0, width: buttonSize, height: buttonSize))
        
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    private func commonInit() {
        profileButton = UIButton(frame: CGRect(x: 0, y: -Constants.shadowOffset, width: frame.width, height: frame.height))
        profileButton.translatesAutoresizingMaskIntoConstraints = false
        profileButton.backgroundColor = .lightGray
        profileButton.layer.cornerRadius = profileButton.bounds.width / 2
        profileButton.layer.borderWidth = 3.0
        profileButton.layer.borderColor = UIColor.white.cgColor
        profileButton.layer.masksToBounds = false
        profileButton.layer.shadowOffset = CGSize(width: 0, height: Constants.shadowOffset)
        profileButton.layer.shadowRadius = 2.0
        profileButton.layer.shadowOpacity = 0.5
        profileButton.addTarget(self, action: #selector(profileButtonTapped(_:)), for: .touchUpInside)
        addSubview(profileButton)
        
        profileButton.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        profileButton.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        profileButton.topAnchor.constraint(equalTo: topAnchor).isActive = true
        profileButton.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        profileImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: profileButton.frame.width, height: profileButton.frame.height))
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.layer.masksToBounds = true
        profileImageView.layer.cornerRadius = profileImageView.bounds.width / 2
        profileImageView.tintColor = .darkGray
        profileImageView.image = #imageLiteral(resourceName: "person")
        profileImageView.contentMode = .bottom
        profileButton.addSubview(profileImageView)
        
        profileImageView.leadingAnchor.constraint(equalTo: profileButton.leadingAnchor).isActive = true
        profileImageView.trailingAnchor.constraint(equalTo: profileButton.trailingAnchor).isActive = true
        profileImageView.topAnchor.constraint(equalTo: profileButton.topAnchor).isActive = true
        profileImageView.bottomAnchor.constraint(equalTo: profileButton.bottomAnchor).isActive = true
        
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        profileButton?.layer.cornerRadius = profileButton.bounds.width / 2
        profileImageView?.layer.cornerRadius = profileImageView.bounds.width / 2
    }
    
    @objc private func profileButtonTapped(_ sender: Any?) {
        tappedCallback?()
    }
    
    func refresh(forceRefetch: Bool = false) {
        guard let user = Auth.auth().currentUser else {
            return
        }
        
        weak var weakProfileImageView = profileImageView
        fetchProfileImage(for: user) { (image, error) in
            guard let profileImage = image else {
                return
            }
            
            weakProfileImageView?.image = profileImage
            weakProfileImageView?.contentMode = .scaleAspectFill
        }
    }
    
    private func fetchProfileImage(for user: Firebase.User, forceRefetch: Bool = false, completion: @escaping ((UIImage?, Error?) -> Void)) {
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
