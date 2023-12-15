//
//  ViewController2.swift
//  ArtBook
//
//  Created by Vedat Dokuzkardeş on 10.11.2023.
//

import UIKit
import CoreData

class ViewController2: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    
    @IBOutlet weak var imageV: UIImageView!
    @IBOutlet weak var nameTxt: UITextField!
    @IBOutlet weak var artistTxt: UITextField!
    @IBOutlet weak var yearTxt: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    
    var chosenPictures = ""
    var chosenId : UUID?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if chosenPictures != "" {
            
            saveButton.isHidden = true
            //core data
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Pictures")
            let idString = chosenId?.uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString!)
            fetchRequest.returnsObjectsAsFaults = false
            
            do{
                let results = try context.fetch(fetchRequest)
                
                if results.count > 0 {
                    
                    for result in results as! [NSManagedObject]{
                        
                        if let name = result.value(forKey: "name") as? String{
                            nameTxt.text = name
                        }
                        if let artist = result.value(forKey: "artist") as? String{
                            artistTxt.text = artist
                        }
                        if let year = result.value(forKey: "year") as? Int{
                            yearTxt.text = String(year)
                        }
                        
                        if let imageData = result.value(forKey: "image") as? Data{
                            let image = UIImage(data: imageData)
                            imageV.image = image
                        }
                        
                    }
                }
                
            }catch{
                print("error")
            }
            
            
        }else {
            saveButton.isEnabled = false
            saveButton.isHidden = false
            
            nameTxt.text = ""
            artistTxt.text = ""
            yearTxt.text = ""
        }
        
        //Recognizers

        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(gestureRecognizer)
        
        imageV.isUserInteractionEnabled = true
        let imageTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(selimg))
        imageV.addGestureRecognizer(imageTapRecognizer)
    }
    
    @objc func selimg(){
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageV.image = info[.originalImage] as? UIImage
        saveButton.isEnabled = true
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func hideKeyboard(){
        view.endEditing(true)
    }
    

    @IBAction func saveBtn(_ sender: Any) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newPainting = NSEntityDescription.insertNewObject(forEntityName: "Pictures", into: context)
        
        //Attributes
        
        newPainting.setValue(nameTxt.text!, forKey: "name")
        newPainting.setValue(artistTxt.text!, forKey: "artist")
        
        if let year = Int(yearTxt.text!){
            newPainting.setValue(year, forKey: "year")
        }
        
        newPainting.setValue(UUID(), forKey: "id")
        
        let data = imageV.image!.jpegData(compressionQuality: 0.5)
        
        newPainting.setValue(data, forKey: "image")
        
        do{
            try context.save()
            print("saved")
        }catch{
            print("error")
        }
        
        NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
        self.navigationController?.popViewController(animated: true)
        
    }
    
}
