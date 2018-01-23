//
//  PhotosViewController.swift
//  PixelMe
//
//  Created by Thomas Pain-Surget on 19/01/2018.
//  Copyright © 2018 Thomas Pain-Surget. All rights reserved.
//

import UIKit
import FirebaseStorageUI
import Firebase

class PhotosViewController: UIViewController {
    
    let ref = Database.database().reference()
    let storageRef = Storage.storage().reference()
    
    var imagesArray : [String] = []
    
    
    @IBOutlet weak var photosCollectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        self.photosCollectionView.register(UINib(nibName: "GalleryCell", bundle: nil), forCellWithReuseIdentifier: "Gallery")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.title = "Gallery"
        download()
        self.photosCollectionView.reloadData()
    }
    
    func download() {
        
        ref.child("images").observe(.value) { (snapshot) in
            
            self.imagesArray = (snapshot.children.allObjects as! [DataSnapshot]).map({ $0.key })
            /*for snap in snapshot.children.allObjects as! [DataSnapshot] {
                let reference = self.storageRef.child("images/\(snap.key).jpg")
                self.imagesArray.append(snap.key)
            }*/
            self.photosCollectionView.reloadData()
        }
    }
    
}

extension PhotosViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.imagesArray.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Gallery", for: indexPath)
        
        if let galleryCell = cell as? GalleryCell {
            
            let reference = self.storageRef.child("images/\(imagesArray[indexPath.item]).jpg")
            
            galleryCell.imageStorage.contentMode = UIViewContentMode.scaleAspectFit
            galleryCell.imageStorage.sd_setImage(with: reference, placeholderImage: #imageLiteral(resourceName: "chouette"))
            galleryCell.layer.cornerRadius = 4
            galleryCell.layer.shadowColor = UIColor.black.cgColor
            galleryCell.layer.shadowOffset = CGSize(width: 2, height: 2)
            galleryCell.layer.shadowOpacity = 0.3
            galleryCell.layer.shadowRadius = 7.0
            galleryCell.clipsToBounds = false
            galleryCell.layer.masksToBounds = false
        }
        return cell
    }
    
}

extension PhotosViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let size = collectionView.bounds.width / 2 - 15
        return CGSize(width: size, height: size)
    }
}

