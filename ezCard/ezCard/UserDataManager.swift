//
//  UserDataManager.swift
//  ezCard
//
//  Created by Andrew Whitehead on 3/25/19.
//  Copyright © 2019 Andrew Whitehead. All rights reserved.
//

import Contacts
import FirebaseStorage
import FirebaseAuth

class UserDataManager {
    
    private let _user: User
    private let vCardRemoteRef: StorageReference
    private let profileImgRef: StorageReference
    private var profileImgDownloadURL: URL?
    
    init(user: User) {
        _user = user
        vCardRemoteRef = Storage.storage().reference().child("users").child("\(user.uid).vcard")
        profileImgRef = Storage.storage().reference().child("profile_images").child("\(user.uid).jpg")
        
        profileImgRef.downloadURL(completion: { [weak self] (url, error) in
            self?.profileImgDownloadURL = url
        })
    }
    
    func download(completion: ((CNContact?, Error?) -> Void)? = nil) {
        vCardRemoteRef.getData(maxSize: Int64.max) { (data, error) in
            if let error = error {
                completion?(nil, error)
                return
            }
            
            do {
                let contact = try CNContactVCardSerialization.contacts(with: data!).first
                completion?(contact, nil)
            } catch let e {
                completion?(nil, e)
            }
        }
    }
    
    func upload(_ contact: CNContact, completion: ((Error?) -> Void)? = nil) {
        do {
            let vCardData = try CNContactVCardSerialization.data(with: [contact])
            
            vCardRemoteRef.putData(vCardData, metadata: nil) { [weak self] (metadata, error) in
                if let error = error {
                    completion?(error)
                    return
                }
                
                print("Successfully uploaded vCard.")
                
                // add display name for quick reference
                let changeRequest = self?._user.createProfileChangeRequest()
                changeRequest?.displayName = "\(contact.givenName) \(contact.familyName)"
                changeRequest?.commitChanges { (error) in
                    if let error = error {
                        print("error changing user display name:", error)
                        return
                    }
                }
                
                completion?(nil)
                
                if let originalImageData = contact.imageData, let image = UIImage(data: originalImageData), let imageData = image.jpegData(compressionQuality: 0.3) {
                    let metadata = StorageMetadata()
                    metadata.contentType = "image/jpeg"
                    
                    self?.profileImgRef.putData(imageData, metadata: metadata) { (metadata, error) in
                        if let error = error {
                            print("error uploading profile image:", error)
                            return
                        }
                        
                        let changeUserPhotoURL: (URL) -> Void = { [weak self] url in
                            let changeRequest = self?._user.createProfileChangeRequest()
                            changeRequest?.photoURL = url
                            changeRequest?.commitChanges { (error) in
                                if let error = error {
                                    print("error changing user photoURL:", error)
                                    return
                                }
                            }
                        }
                        
                        if let profileImgDownloadURL = self?.profileImgDownloadURL {
                            changeUserPhotoURL(profileImgDownloadURL)
                        } else {
                            self?.profileImgRef.downloadURL(completion: { (url, error) in
                                if let error = error {
                                    print("error fetching profile image download URL:", error)
                                    return
                                }
                                
                                if let url = url {
                                    changeUserPhotoURL(url)
                                } else {
                                    print("profile image download URL was nil")
                                    return
                                }
                            })
                        }
                    }
                }
            }
        } catch let error {
            completion?(error)
        }
    }
    
    
    
}
