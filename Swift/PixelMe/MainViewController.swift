//
//  MainViewController.swift
//  PixelMe
//
//  Created by Thomas Pain-Surget on 08/12/2017.
//  Copyright © 2017 Thomas Pain-Surget. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import FirebaseStorageUI

class MainViewController: UIViewController, UIImagePickerControllerDelegate, UIPopoverControllerDelegate, UINavigationControllerDelegate {

    
    @IBOutlet weak var imagePicked: UIImageView!
    @IBOutlet weak var opacityView: UIView!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    
    var imagePicker: UIImagePickerController!
    
    let storage = Storage.storage()
    let database = Database.database()
    let ref = Database.database().reference()
    let storageRef = Storage.storage().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.opacityView.isHidden = true
        self.loader.isHidden = true
        
        self.navigationItem.title = "PixelMe"
        
        imagePicked.contentMode = UIViewContentMode.scaleAspectFit
        imagePicked.layer.borderWidth = 2
        imagePicked.layer.borderColor = UIColor.white.cgColor
    }
    
    func uploadFileInStorage(){
        
        if let imageToSave = imagePicked.image {
            
            let imageRotated = imageRotatedByDegrees(oldImage: imageToSave, deg: 180)
            
            if let dataResize = UIImageJPEGRepresentation(imageRotated.resizedImage(newSize: CGSize(width: 32 , height: 16)), 1.0),
                let data = UIImageJPEGRepresentation(imageToSave, 1.0) {
                
                self.opacityView.isHidden = false
                self.loader.isHidden = false
                
                loader.startAnimating()
                
                let storageRef = storage.reference()
                
                let key = Database.database().reference().childByAutoId().key
                
                var riversRef = self.storageRef.child("images/current.jpg")
                
                riversRef.putData(dataResize, metadata: nil) { (metadata, error) in
                    if let error = error{
                        print(error)
                    }else{
                        print("Current image sent")
                    }
                }
                
                riversRef = storageRef.child("images/\(key)-resize.bmp")
                
                riversRef.putData(dataResize, metadata: nil) { (metadata, error) in
                    if let error = error{
                        print(error)
                    }else{
                        print("Image sent")
                        self.ref.child("images").updateChildValues([key:true])
                        //self.opacityView.isHidden = true
                        //self.imagePicked.image = nil
                    }
                }
                
                riversRef = storageRef.child("images/\(key).bmp")
                
                riversRef.putData(data, metadata: nil) { (metadata, error) in
                    if let error = error{
                        print(error)
                    }else{
                        print("Image sent")
                        self.ref.child("images").updateChildValues([key:true])
                        self.loader.stopAnimating()
                        self.loader.isHidden = true
                        self.opacityView.isHidden = true
                        self.imagePicked.image = nil
                        let ac = UIAlertController(title: "", message: "Image envoyée !", preferredStyle: .alert)
                        ac.addAction(UIAlertAction(title: "Ok", style: .default))
                        self.present(ac, animated: true)
                    }
                }
            }
        } else {
            let ac = UIAlertController(title: "Attention", message: "Vous n'avez pas d'image à envoyer", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Réessayer", style: .default))
            self.present(ac, animated: true)
        }
    }

    @IBAction func openCameraButton(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true)
        }
    }
    
    @IBAction func openPhotoLibraryButton(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true)
        }
    }


    @IBAction func saveLibrary(_ sender: Any) {
        imagePicked.image = imagePicked.image
        if let imageToSave = imagePicked.image {
            UIImageWriteToSavedPhotosAlbum(imageToSave, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
            
        } else {
            let ac = UIAlertController(title: "Oups..", message: "Vous n'avez pas d'image à sauvegarder..", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Réessayer", style: .default))
            present(ac, animated: true)
        }
    }
    
    @IBAction func send(_ sender: Any) {
        uploadFileInStorage()
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            let ac = UIAlertController(title: "Erreur !", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Wow", message: "Votre image a bien été sauvegardée dans votre librairie", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imagePicker.dismiss(animated: true)
        imagePicked.image = info[UIImagePickerControllerOriginalImage] as? UIImage
    }
    
    @IBAction func clear(_ sender: Any) {
        imagePicked.image = nil
    }
    
    @IBAction func goToGallery(_ sender: Any) {
        let photosVC = PhotosViewController(nibName: "PhotosViewController", bundle: nil)
        navigationController?.pushViewController(photosVC, animated: true)
    }
    
    
    func imageRotatedByDegrees(oldImage: UIImage, deg degrees: CGFloat) -> UIImage {
        let rotatedViewBox: UIView = UIView(frame: CGRect(x: 0, y: 0, width: oldImage.size.width, height: oldImage.size.height))
        let t: CGAffineTransform = CGAffineTransform(rotationAngle: degrees * CGFloat.pi / 180)
        rotatedViewBox.transform = t
        let rotatedSize: CGSize = rotatedViewBox.frame.size
        UIGraphicsBeginImageContext(rotatedSize)
        let bitmap: CGContext = UIGraphicsGetCurrentContext()!
        bitmap.translateBy(x: rotatedSize.width / 2, y: rotatedSize.height / 2)
        bitmap.rotate(by: (degrees * CGFloat.pi / 180))
        bitmap.scaleBy(x: 1.0, y: -1.0)
        bitmap.draw(oldImage.cgImage!, in: CGRect(x: -oldImage.size.width / 2, y: -oldImage.size.height / 2, width: oldImage.size.width, height: oldImage.size.height))
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
}

extension UIImage {
    enum JPEGQuality: CGFloat {
        case lowest  = 0
        case low     = 0.25
        case medium  = 0.5
        case high    = 0.75
        case highest = 1
    }
    
    func jpeg(_ quality: JPEGQuality) -> Data? {
        return UIImageJPEGRepresentation(self, quality.rawValue)
    }
    
    func resizedImage(newSize: CGSize) -> UIImage {
        
        guard self.size != newSize else { return self }
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        self.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        if let newImage : UIImage = UIGraphicsGetImageFromCurrentImageContext() {
            UIGraphicsEndImageContext()
            return newImage
        }
        return self
    }
    
}


