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

class MainViewController: UIViewController, UIImagePickerControllerDelegate, UIPopoverControllerDelegate, UINavigationControllerDelegate {

    
    @IBOutlet weak var imagePicked: UIImageView!
    
    var imagePicker: UIImagePickerController!
    let storage = Storage.storage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.navigationController?.navigationBar.barStyle = UIBarStyle.black
//        let attrs = [
//            NSAttributedStringKey.foregroundColor: UIColor.white
//        ]
//        UINavigationBar.appearance().titleTextAttributes = attrs
        
        imagePicked.contentMode = UIViewContentMode.scaleAspectFit
        imagePicked.layer.borderWidth = 2
        imagePicked.layer.borderColor = UIColor.white.cgColor
    }
    
    func uploadFile(){
        
        if let imageToSave = imagePicked.image, let data = UIImagePNGRepresentation(imageToSave) {

            let storageRef = storage.reference()
            
            let key = Database.database().reference().childByAutoId().key
            // Create a reference to the file you want to upload
            let riversRef = storageRef.child("images/\(key).jpg")
            
            // Upload the file to the path "images/rivers.jpg"
            riversRef.putData(data, metadata: nil) { (metadata, error) in
                if let error = error{
                    print(error)
                }else{
                    print("Image sent")
                }
            }
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
    
//    @IBAction func saveButton(_ sender: Any) {
//        guard
//            let image = imagePicked.image,
//            let imageData = UIImageJPEGRepresentation(image, 0.6),
//            let compressedJPGImage = UIImage(data: imageData)
//            else { return }
//
//        UIImageWriteToSavedPhotosAlbum(compressedJPGImage, nil, nil, nil)
//
//        let alertController = UIAlertController(title: "Wow", message: "Votre image a bien été sauvegardée dans votre librairie", preferredStyle: .alert)
//        self.present(alertController, animated: true)
//
//    }

    @IBAction func save(_ sender: Any) {
        uploadFile()
        /*if let imageToSave = imagePicked.image {
            UIImageWriteToSavedPhotosAlbum(imageToSave, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        } else {
            let ac = UIAlertController(title: "Oups..", message: "Vous n'avez pas d'image à sauvegarder..", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Réessayer", style: .default))
            present(ac, animated: true)
        }*/
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
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
    
    func filter(image: UIImage) {
        
    }
}
