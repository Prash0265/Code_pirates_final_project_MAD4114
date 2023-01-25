import UIKit
import CoreData


class NoteTableView: UITableViewController
{
    var noteList = [Note]()
    var filteredNotes = [Note]()

    @IBOutlet weak var searchBar: UISearchBar!
    var searching = false
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let noteCell = tableView.dequeueReusableCell(withIdentifier: "noteCellID", for: indexPath)
        
        if searching {
                let thisNote: Note!
                thisNote = filteredNotes[indexPath.row]
                noteCell.textLabel?.text = thisNote.title
                noteCell.detailTextLabel?.text = "\(thisNote.desc!)\n\(thisNote.dateTime?.formatted() ?? "")"

        }
        else {
            let thisNote: Note!
            thisNote = noteList[indexPath.row]
            noteCell.textLabel?.text = thisNote.title
            noteCell.detailTextLabel?.text = "\(thisNote.desc!) \n\(thisNote.dateTime?.formatted() ?? "")"
        }
        
        return noteCell
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if searching{
            return filteredNotes.count
        }
        else{
            return noteList.count
        }
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Note")
        
        //Sorting by title
        let sortDescriptor = NSSortDescriptor(key: "title", ascending: true, selector: #selector(NSString.caseInsensitiveCompare))
        let sortDescriptors = [sortDescriptor]
        request.sortDescriptors = sortDescriptors
        
        do {
            noteList = []
            let results:NSArray = try context.fetch(request) as NSArray
            for result in results
            {
                let note = result as! Note
                if note.deletedDate == nil{
                    noteList.append(note)
                }
            }
            
            tableView.reloadData()
        }
        catch
        {
            print("Fetch Failed")
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        self.performSegue(withIdentifier: "editNote", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if(segue.identifier == "editNote")
        {
            let indexPath = tableView.indexPathForSelectedRow!
            
            let noteDetail = segue.destination as? NoteDetailVC
            
            let selectedNote : Note!
            selectedNote = noteList[indexPath.row]
            noteDetail!.selectedNote = selectedNote
            
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    
}


extension NoteTableView: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredNotes = noteList.filter { $0.title!.contains(searchText) || $0.desc!.contains(searchText)}
        searching = true
        tableView.reloadData()
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
         searching = false
         searchBar.text = ""
         tableView.reloadData()
    }
}



