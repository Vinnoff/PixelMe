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
        
        self.navigationItem.title = "PixelMe"
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
            let riversRef = storageRef.child("images/\(key).bmp")
            
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


    @IBAction func saveLibrary(_ sender: Any) {
        imagePicked.image = imagePicked.image?.filter()
        if let imageToSave = imagePicked.image {
            UIImageWriteToSavedPhotosAlbum(imageToSave, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
            
        } else {
            let ac = UIAlertController(title: "Oups..", message: "Vous n'avez pas d'image à sauvegarder..", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Réessayer", style: .default))
            present(ac, animated: true)
        }
    }
    
    @IBAction func send(_ sender: Any) {
        uploadFile()
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
    
    @IBAction func goToGallery(_ sender: Any) {
        let photosVC = PhotosViewController(nibName: "PhotosViewController", bundle: nil)
        navigationController?.pushViewController(photosVC, animated: true)
    }
}

extension UIImage{
    
    func resizeImageWith(newSize: CGSize) -> UIImage {
        
        let horizontalRatio = newSize.width / size.width
        let verticalRatio = newSize.height / size.height
        let ratio = max(horizontalRatio, verticalRatio)
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        UIGraphicsBeginImageContextWithOptions(newSize, true, 0)
        draw(in: CGRect(origin: CGPoint(x: 0, y: 0), size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    func resizeImage(newSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContext(newSize)
        self.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }

    
    func filter() -> UIImage {
        let controlsFilter = CIFilter(name: "CIColorControls")!
        let ccimage = CIImage(image: self)
        controlsFilter.setValue(ccimage, forKey: kCIInputImageKey)
        controlsFilter.setValue(2, forKey: kCIInputSaturationKey)
        let azerty = UIImage(cgImage: CIContext(options: nil).createCGImage(controlsFilter.outputImage!, from: controlsFilter.outputImage!.extent)!).resizeImage(newSize: CGSize(width: 64, height: 32))

        return azerty
    }
    
}
