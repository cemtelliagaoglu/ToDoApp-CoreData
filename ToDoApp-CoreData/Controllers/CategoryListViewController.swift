//
//  ControllerViewController.swift
//  ToDoApp-CoreData
//
//  Created by admin on 17.06.2022.
//

import UIKit
import CoreData
import SwipeCellKit
import ChameleonFramework

class CategoryListViewController: SwipeTableViewCellController{
    
    var categories: [Category]?
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategories()
    }
    override func viewWillAppear(_ animated: Bool) {
        //NavigationBar Preferences for CategoryList Page
        let navBar = self.navigationController!.navigationBar
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.backgroundColor = .white
        navBarAppearance.titleTextAttributes = [.font:UIFont(name: "Verdana", size: 25)!,.foregroundColor: UIColor.black]
        navigationItem.rightBarButtonItem?.tintColor = .black
        navBar.standardAppearance = navBarAppearance
        navBar.scrollEdgeAppearance = navBarAppearance
    }

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add", style: .default) { action in
            let newCategory = Category(context:self.context)
            newCategory.name = textField.text
            newCategory.color = UIColor.randomFlat().hexValue()
            
            self.categories?.append(newCategory)
            self.saveCategories()
        }
        
        alert.addAction(action)
        alert.addTextField { field in
            textField = field
            textField.placeholder = "Add a new category"
        }
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return categories?.count ?? 1
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let category = categories?[indexPath.row]{
        cell.textLabel?.text = category.name
            cell.backgroundColor = UIColor(hexString: category.color!)
            cell.textLabel?.textColor = ContrastColorOf(cell.backgroundColor!, returnFlat: true)
        }
        return cell
    }

    //MARK: - Tableview Delegate Methods
   
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            self.delete(self.categories![indexPath.row], indexPath)
        }
        deleteAction.image = UIImage(named: "delete-icon")
        
        return [deleteAction]
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "goToItems", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow{
            destinationVC.selectedCategory = categories![indexPath.row]
        }
        
    }
    
    
    
    //MARK: - Data Manipulation methods
    func loadCategories(){
        
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        do{
        categories = try context.fetch(request)
        }catch{
            print("Error fetching data from context, \(error)")
        }
        tableView.reloadData()

    }
    
    func saveCategories(){
        do{
        try context.save()
        }catch{
            print("Error while saving, \(error)")
        }
        tableView.reloadData()
    }
    
    func delete(_ category: Category,_ indexPath:IndexPath){
        context.delete(category)
        
        saveCategories()
        categories?.remove(at: indexPath.row)
    }
}
