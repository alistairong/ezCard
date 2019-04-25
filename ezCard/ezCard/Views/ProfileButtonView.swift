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
        static let imageViewPadding = CGFloat(5)
        static let defaultImage = #imageLiteral(resourceName: "person")
        static let borderWidthMultiplier = CGFloat(0.075)
        static let shadowRadiusMultiplier = CGFloat(0.05)
        static let shadowOpacity = Float(0.5)
    }
    
    private var containerView: UIView!
    private var defaultProfileImageView: UIImageView!
    private var profileImageView: UIImageView!
    private var profileButton: UIButton!
    
    var userId: String? {
        didSet {
            refresh(forceRefetch: true)
        }
    }
    
    var tappedCallback: (() -> Void)?
    
    convenience init() {
        self.init(buttonSize: ProfileButtonView.defaultSize)
    }

    init(userId: String? = User.current?.uid, buttonSize: CGFloat) {
        super.init(frame: CGRect(x: 0, y: 0, width: buttonSize, height: buttonSize))
        
        commonInit()
        
        self.userId = userId
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
        containerView = UIView(frame: CGRect(x: 0, y: -Constants.shadowOffset, width: frame.width, height: frame.height))
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .lightGray
        containerView.layer.cornerRadius = containerView.bounds.width / 2
        containerView.layer.borderWidth = round(Constants.borderWidthMultiplier * containerView.bounds.width)
        containerView.layer.borderColor = UIColor.white.cgColor
        containerView.clipsToBounds = false
        containerView.layer.shadowOffset = CGSize(width: 0, height: Constants.shadowOffset)
        containerView.layer.shadowRadius = round(Constants.shadowRadiusMultiplier * containerView.bounds.width)
        containerView.layer.shadowOpacity = Constants.shadowOpacity
        addSubview(containerView)
        
        containerView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        containerView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        containerView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        defaultProfileImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: containerView.frame.width, height: containerView.frame.height))
        defaultProfileImageView.translatesAutoresizingMaskIntoConstraints = false
        defaultProfileImageView.clipsToBounds = true
        defaultProfileImageView.layer.cornerRadius = (containerView.bounds.width - 2 * Constants.imageViewPadding) / 2
        defaultProfileImageView.tintColor = .darkGray
        defaultProfileImageView.image = Constants.defaultImage
        defaultProfileImageView.contentMode = .scaleAspectFit
        containerView.addSubview(defaultProfileImageView)

        defaultProfileImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Constants.imageViewPadding).isActive = true
        defaultProfileImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Constants.imageViewPadding).isActive = true
        defaultProfileImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: Constants.imageViewPadding).isActive = true
        defaultProfileImageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        
        profileImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: containerView.frame.width, height: containerView.frame.height))
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.clipsToBounds = true
        profileImageView.layer.cornerRadius = containerView.bounds.width / 2
        profileImageView.contentMode = .scaleAspectFill
        containerView.addSubview(profileImageView)
        
        profileImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 0).isActive = true
        profileImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: 0).isActive = true
        profileImageView.topAnchor.constraint(greaterThanOrEqualTo: containerView.topAnchor, constant: 0).isActive = true
        profileImageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        
        profileButton = UIButton(frame: containerView.frame)
        profileButton.translatesAutoresizingMaskIntoConstraints = false
        profileButton.addTarget(self, action: #selector(profileButtonTapped(_:)), for: .touchUpInside)
        addSubview(profileButton)
        
        profileButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        profileButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        profileButton.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        profileButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        containerView?.layer.shadowRadius = round(Constants.shadowRadiusMultiplier * containerView.bounds.width)
        containerView?.layer.borderWidth = round(Constants.borderWidthMultiplier * containerView.bounds.width)
        containerView?.layer.cornerRadius = containerView.bounds.width / 2
        profileImageView?.layer.cornerRadius = containerView.bounds.width / 2
        defaultProfileImageView?.layer.cornerRadius = (profileButton.bounds.width - 2 * Constants.imageViewPadding) / 2
    }
    
    @objc private func profileButtonTapped(_ sender: Any?) {
        tappedCallback?()
    }
    
    func refresh(forceRefetch: Bool = false) {
        weak var weakProfileImageView = profileImageView
        fetchProfileImage(forceRefetch: forceRefetch) { (image, error) in
            guard let profileImage = image else {
                weakProfileImageView?.image = nil
                return
            }
            
            weakProfileImageView?.image = profileImage
        }
    }
    
    private func fetchProfileImage(forceRefetch: Bool = false, completion: @escaping ((UIImage?, Error?) -> Void)) {
        guard let userId = self.userId else {
            completion(nil, nil)
            return
        }
        
        let cacheKey = "profile_image_\(userId)"
        
        if let imageFromCache = profileImageCache.object(forKey: cacheKey as AnyObject) as? UIImage, !forceRefetch {
            completion(imageFromCache, nil)
        } else {
            let profileImgRef = Storage.storage().reference().child("profile_images").child("\(userId).jpg")
            
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
