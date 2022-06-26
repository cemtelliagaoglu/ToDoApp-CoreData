//
//  ViewController.swift
//  ToDoApp-CoreData
//
//  Created by admin on 17.06.2022.
//

import UIKit
import CoreData
import SwipeCellKit
import ChameleonFramework

class TodoListViewController: SwipeTableViewCellController {
    
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var itemArray:[Item]?
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var selectedCategory:Category? {
        didSet{
            loadItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadItems()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let categoryColor = UIColor(hexString:(selectedCategory?.color)!) {
            
            let contrastColor = ContrastColorOf(categoryColor, returnFlat: true)
            title = selectedCategory!.name
            searchBar.barTintColor = categoryColor
            searchBar.searchTextField.textColor = categoryColor
            searchBar.searchTextField.backgroundColor = .flatWhite()
            
            let navBarAppearance = UINavigationBarAppearance()
            let navBar = navigationController?.navigationBar
            let navItem = navigationController?.navigationItem
            navBarAppearance.configureWithOpaqueBackground()
            
            navBarAppearance.titleTextAttributes = [.foregroundColor: contrastColor,.font: UIFont(name: "Verdana", size: 25)!]
            navBarAppearance.largeTitleTextAttributes = [.foregroundColor: contrastColor]
            navBarAppearance.backgroundColor = categoryColor
            navItem?.rightBarButtonItem?.tintColor = contrastColor
            navBar?.tintColor = contrastColor
            
            navBar?.standardAppearance = navBarAppearance
            navBar?.scrollEdgeAppearance = navBarAppearance
        }
    }
    
    //Adding newItem to the itemArray with UIAlert
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        let alert = UIAlertController(title: "Add new Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add", style: .default) { action in
            let newItem = Item(context: self.context)
            newItem.name = textField.text
            newItem.done = false
            newItem.parentCategory = self.selectedCategory
            self.itemArray?.append(newItem)
            self.saveItems()
        }
        alert.addAction(action)
        alert.addTextField { field in
            textField = field
            textField.placeholder = "Add new Item"
        }
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - TableViewDataSource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray?.count ?? 1
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let item = itemArray?[indexPath.row]{
        cell.textLabel?.text = item.name
        cell.accessoryType = item.done ? .checkmark : .none //If the item is done adds checkmark
        }
        if let backgroundColor = UIColor(hexString: selectedCategory!.color!){
            let contrastColor = ContrastColorOf(backgroundColor, returnFlat: true)
            cell.backgroundColor = backgroundColor.darken(byPercentage: CGFloat(indexPath.row)/CGFloat(itemArray?.count ?? 1))
            cell.textLabel?.textColor = contrastColor
        }
        return cell
    }
    //MARK: - TableViewDelegate Methods
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            // handle action by updating model with deletion
            self.deleteItem(self.itemArray![indexPath.row],indexPath)
        }

        // customize the action appearance
        deleteAction.image = UIImage(named: "delete-icon")

        return [deleteAction]
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        itemArray![indexPath.row].done = itemArray![indexPath.row].done ? false: true
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.reloadData()
    }
    
    //MARK: - Data Manipulation Methods
    
    func loadItems( with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil ){
        
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@",selectedCategory!.name!)
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        if let additionalPredicate = predicate{ //If there's another predicate to query data, it combines both predicates to apply.
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate,additionalPredicate])
        }else{
            request.predicate = categoryPredicate
        }
        do{
            itemArray = try context.fetch(request)
        }catch{
            print("Error fetching data from context, \(error)")
        }
        tableView.reloadData()
    }
    
    func saveItems(){
        do{
            try context.save()
        }catch{
            print("Error fetching data from context, \(error)")
        }
        tableView.reloadData()
    }
    
    func deleteItem(_ item: Item,_ indexPath:IndexPath){
        context.delete(item)
        saveItems()
        itemArray?.remove(at: indexPath.row)
    }
}

//MARK: - SearchBarDelegate Methods

extension TodoListViewController: UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        let predicate = NSPredicate(format: "name CONTAINS[cd] %@", searchBar.text!)
        loadItems(predicate: predicate)
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}
