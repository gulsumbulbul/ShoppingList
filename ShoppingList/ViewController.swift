//
//  ViewController.swift
//  ShoppingList
//
//  Created by Gülsüm Bülbül on 1.08.2024.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var nameArray = [String]()
    var idArray = [UUID]()
    var selectedProduct = ""
    var selectedUUID : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addButtonHasBeenClick))
        
        saveData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(saveData), name: NSNotification.Name(rawValue: "addData"), object: nil)
    }
    
    @objc func saveData(){
        
        nameArray.removeAll(keepingCapacity: false)
        idArray.removeAll(keepingCapacity: false)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Shopping")
        fetchRequest.returnsObjectsAsFaults = false //çok büyük verilerle çalışırken kullanılır...
        
        do{
            let results = try context.fetch(fetchRequest)
            
            for result in results as! [NSManagedObject]{
                if let name = result.value(forKey: "type") as? String{
                    nameArray.append(name)
                }
                if let id = result.value(forKey: "id") as? UUID {
                    idArray.append(id)
                }
            }
            
            tableView.reloadData() //data güncelleme
            
        }catch{
            print("error")
        }
        
    }
    
    @objc func addButtonHasBeenClick(){
        selectedProduct = ""
        performSegue(withIdentifier: "toDetailsVC", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = nameArray[indexPath.row]
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailsVC" {
            let destinationVC = segue.destination as! DetailsViewController
            destinationVC.selectedProductName = selectedProduct
            destinationVC.selectedProductUUID = selectedUUID
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedProduct = nameArray[indexPath.row]
        selectedUUID = idArray[indexPath.row]
        performSegue(withIdentifier: "toDetailsVC", sender: nil)
    }


}

