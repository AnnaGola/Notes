//
//  NotesTVC.swift
//  Notes
//
//  Created by anna on 13.06.2022.
//

import UIKit
import CoreData
import UserNotifications

class NotesTVC: UITableViewController {
    
    var notes: [Note] = []
    
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    
    @IBAction func saveNote(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "New Note", message: "enter new note", preferredStyle: .alert)
        
        let save = UIAlertAction(title: "Save", style: .cancel) { action in
            self.appDelegate?.scaduleNotification(notificationType: "Don't forget about your list")
            let tf = alert.textFields?.first
            if let newNoteTitle = tf?.text {
                self.saveNote(withTitle: newNoteTitle)
                self.tableView.reloadData()
            }
        }
        alert.addTextField { _ in }
        let cancel = UIAlertAction(title: "Cancel", style: .default) { _ in }
        alert.addAction(cancel)
        alert.addAction(save)
        
        
        if alert.textFields?.isEmpty == false {
            save.isEnabled = true
        }
        present(alert, animated: true)
    }

    
    private func saveNote(withTitle title: String) {
        let context = getContext()
        
        guard let entity = NSEntityDescription.entity(forEntityName: "Note", in: context) else { return }
        let noteObject = Note(entity: entity, insertInto: context)
        noteObject.title = title
        
        do {
            try context.save()
            notes.insert(noteObject, at: 0)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    private func getContext() -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let context = getContext()
        let fetchRequest: NSFetchRequest<Note> = Note.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "title", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            notes = try context.fetch(fetchRequest)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()
       
    }

    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let note = notes[indexPath.row]
        cell.textLabel?.text = note.title
        return cell
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let trash = deleteAction(at: indexPath)
        return UISwipeActionsConfiguration(actions: [trash])
        
    }
    
    func deleteAction(at indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .destructive, title: "trash") { (action, view, complition) in
            self.notes.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .fade)
            complition(true)
        }
        action.backgroundColor = .red
        action.image = UIImage(systemName: "trash")
        return action
    }
}
