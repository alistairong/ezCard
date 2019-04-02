//
//  ProfileButtonView.swift
//  ezCard
//
//  Created by Andrew Whitehead on 3/6/19.
//  Copyright © 2019 Andrew Whitehead. All rights reserved.
//

import UIKit
import FirebaseStorage

class ProfileButtonView: UIView {
    
    static let defaultSize = CGFloat(40.0)
    
    private struct Constants {
        static let shadowOffset = CGFloat(2.0)
        static let imageViewPadding: CGFloat = CGFloat(5)
        static let defaultImage = #imageLiteral(resourceName: "person")
    }
    
    private var profileImageView: UIImageView!
    private var profileButton: UIButton!
    
    var user: User? {
        didSet {
            refresh(forceRefetch: true)
        }
    }
    
    var tappedCallback: (() -> Void)?
    
    convenience init() {
        self.init(buttonSize: ProfileButtonView.defaultSize)
    }

    init(user: User? = nil, buttonSize: CGFloat) {
        super.init(frame: CGRect(x: 0, y: 0, width: buttonSize, height: buttonSize))
        
        commonInit()
        
        self.user = user
        refresh(forceRefetch: true)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
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
        profileButton.clipsToBounds = false
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
        profileImageView.clipsToBounds = true
        profileImageView.layer.cornerRadius = (profileButton.bounds.width - 2 * Constants.imageViewPadding) / 2
        profileImageView.tintColor = .darkGray
        profileImageView.image = Constants.defaultImage
        profileImageView.contentMode = .scaleAspectFit
        profileButton.addSubview(profileImageView)
        
        profileImageView.leadingAnchor.constraint(equalTo: profileButton.leadingAnchor, constant: Constants.imageViewPadding).isActive = true
        profileImageView.trailingAnchor.constraint(equalTo: profileButton.trailingAnchor, constant: -Constants.imageViewPadding).isActive = true
        profileImageView.topAnchor.constraint(greaterThanOrEqualTo: profileButton.topAnchor, constant: Constants.imageViewPadding).isActive = true
        profileImageView.bottomAnchor.constraint(equalTo: profileButton.bottomAnchor).isActive = true
        profileImageView.heightAnchor.constraint(equalTo: profileImageView.widthAnchor, multiplier: 1.0).isActive = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        profileButton?.layer.cornerRadius = profileButton.bounds.width / 2
        profileImageView?.layer.cornerRadius = (profileButton.bounds.width - 2 * Constants.imageViewPadding) / 2
    }
    
    @objc private func profileButtonTapped(_ sender: Any?) {
        tappedCallback?()
    }
    
    func refresh(forceRefetch: Bool = false) {
        guard let user = self.user else {
            profileImageView.image = Constants.defaultImage
            return
        }
        
        weak var weakProfileImageView = profileImageView
        fetchProfileImage(for: user) { (image, error) in
            guard let profileImage = image else {
                weakProfileImageView?.image = Constants.defaultImage
                return
            }
            
            weakProfileImageView?.image = profileImage
        }
    }
    
    private func fetchProfileImage(for user: User, forceRefetch: Bool = false, completion: @escaping ((UIImage?, Error?) -> Void)) {
        self.user = user
        
        let cacheKey = "profile_image_\(user.uid)"
        
        if let imageFromCache = profileImageCache.object(forKey: cacheKey as AnyObject) as? UIImage, !forceRefetch {
            completion(imageFromCache, nil)
        } else {
            let profileImgRef = Storage.storage().reference().child("profile_images").child("\(user.uid).jpg")
            
            // limit profile images to 2MB (2 * 1024 * 1024 bytes)
            profileImgRef.getData(maxSize: 2 * 1024 * 1024) { data, error in
                if let error = error {
                    let storageError = StorageErrorCode(rawValue: (error as NSError).code)
                    
                    if storageError != .objectNotFound {
                        print("Error fetching profile image:", error)
                    }
                    
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
