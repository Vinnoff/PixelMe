//
//  PhotosViewController.swift
//  PixelMe
//
//  Created by Thomas Pain-Surget on 19/01/2018.
//  Copyright © 2018 Thomas Pain-Surget. All rights reserved.
//

import UIKit

class PhotosViewController: UIViewController {
    
    @IBOutlet weak var photosCollectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.photosCollectionView.register(UINib(nibName: "GalleryCell", bundle: nil), forCellWithReuseIdentifier: "Gallery")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.photosCollectionView.reloadData()
    }
    
}

extension PhotosViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 20
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Gallery", for: indexPath)
        
        if let galleryCell = cell as? GalleryCell {
            galleryCell.labelCell.text = "HELLO"
            galleryCell.layer.cornerRadius = 6
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

