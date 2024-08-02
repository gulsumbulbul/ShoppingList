//
//  DetailsViewController.swift
//  ShoppingList
//
//  Created by Gülsüm Bülbül on 1.08.2024.
//

import UIKit
import CoreData

class DetailsViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var typeTextField: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var sizeTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    var selectedProductName = ""
    var selectedProductUUID : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if selectedProductName != "" {
            
            saveButton.isHidden = true
            //Core data seçilen ürün bilgilerini göster
            if let uuidString = selectedProductUUID?.uuidString{
                
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let context = appDelegate.persistentContainer.viewContext
                
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Shopping")
                fetchRequest.predicate = NSPredicate(format: "id = %@", uuidString) //filtreleme işlemi: idsi şuna eşit olanları getir
                fetchRequest.returnsObjectsAsFaults = false
                
                do{
                    let results = try context.fetch(fetchRequest)
                    
                    if results.count > 0{
                        for result in results as! [NSManagedObject]{
                            if let name = result.value(forKey: "type") as? String{
                                typeTextField.text = name
                            }
                            if let price = result.value(forKey: "price") as? Int{
                                priceTextField.text = String(price)
                            }
                            if let size = result.value(forKey: "size") as? String{
                                sizeTextField.text = size
                            }
                            if let imageData = result.value(forKey: "image") as? Data {
                                let image = UIImage(data: imageData)
                                imageView.image = image
                            }
                        }
                    }
                }catch{
                    print("error")
                }
                
                
                
            }
            
        } else {
            saveButton.isHidden = false
            saveButton.isEnabled = false
            typeTextField.text = ""
            priceTextField.text = ""
            sizeTextField.text = ""
        }
        
        //klavyeyi gizlemek için:
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeybord))
        view.addGestureRecognizer(gestureRecognizer)
        
        // tıkladığında resim eklenmesi için
        imageView.isUserInteractionEnabled = true
        let imageGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectPhoto))
        imageView.addGestureRecognizer(imageGestureRecognizer)
       
    }
    
    @objc func hideKeybord() {
        view.endEditing(true)
    }
    
    @objc func selectPhoto(){
        // galeri için
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary //kaynak: kamera, galeri vs
        picker.allowsEditing = true //editlemeye izin verilsin mi
        present(picker, animated: true, completion: nil)
    }
    
    //kullanıcı galeriden resim seçimi yaptıktan sonra:
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        imageView.image = info[.originalImage] as? UIImage
        saveButton.isEnabled = true
        self.dismiss(animated: true, completion: nil) //galeriyi kapat
    }
    
    @IBAction func saveButtonHasBeenClick(_ sender: Any) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate //değişken olarak tanımladık
        let context = appDelegate.persistentContainer.viewContext
        
        let shopping = NSEntityDescription.insertNewObject(forEntityName: "Shopping", into: context)
        
        shopping.setValue(typeTextField.text!, forKey: "type")
        shopping.setValue(sizeTextField.text!, forKey: "size")
        
        if let price = Int(priceTextField.text!){
            shopping.setValue(price, forKey: "price")
        }
        
        shopping.setValue(UUID(), forKey: "id")
        
        let data = imageView.image!.jpegData(compressionQuality: 0.5)
        
        shopping.setValue(data, forKey: "image")
        
        do{
            try context.save()
            print("saved successfully")
        } catch {
            print("error")
        }
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "addData"), object: nil)
        self.navigationController?.popViewController(animated: true) //bi önceki view controller'a geri dön
        
    }
    

}
