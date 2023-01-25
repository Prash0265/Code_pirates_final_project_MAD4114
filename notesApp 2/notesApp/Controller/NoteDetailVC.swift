
import UIKit
import CoreData
import CoreLocation
import MapKit


class NoteDetailVC: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var titleTF: UITextField!
    
    @IBOutlet weak var descTV: UITextView!
    
    @IBOutlet weak var addImage: UIImageView!
    
    @IBOutlet weak var locationLabel: UILabel!
    
  
    let locationManager = CLLocationManager()
    let locale = Locale.current
    
    var selectedNote: Note? = nil
    var lastUpdated: Date = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
                    locationManager.requestAlwaysAuthorization()
                    locationManager.requestWhenInUseAuthorization()
                    if CLLocationManager.locationServicesEnabled()
                {
                    locationManager.delegate = self
                    locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                    locationManager.startUpdatingLocation()
                }
        
        if(selectedNote != nil)
        {
            titleTF.text = selectedNote?.title
            descTV.text = selectedNote?.desc
            if UIImage(data: selectedNote!.image ?? Data()) != nil {
                addImage.image = UIImage(data: selectedNote!.image ?? Data())}
        }
    }
    

    
    @IBAction func addImgBtn(_ sender: UIButton) {
        
        let image = UIImagePickerController()
        image.delegate = self
        image.mediaTypes = ["public.image"]
        image.allowsEditing = false
        
        self.present(image, animated: true)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        {
            addImage.image = image
        }
        
    }
    
    @IBAction func saveAction(_ sender: Any) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        
        if(selectedNote == nil)
        {
            let newNote = Note(context: context)
            //            newNote.id = noteList.count
            newNote.title = titleTF.text
            newNote.desc = descTV.text
            newNote.dateTime = Date.now
           
            if let imageData = addImage.image?.pngData() {
                newNote.image = imageData
            }
           
            do {
                try context.save()
                navigationController?.popViewController(animated: true)
            }
            catch{
                print("context save error")
            }
        }
        else{
            do {
                if let note = selectedNote{
                    note.title = titleTF.text
                    note.desc = descTV.text
                    note.dateTime = Date.now
                    try context.save()
                }
                navigationController?.popViewController(animated: true)
            }
            catch
            {
                print("Fetch Failed")
            }
        }
        
    }
    
    @IBAction func DeleteNote(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        
        do {
            if let note = selectedNote{
                note.deletedDate = Date.now
                try context.save()
            }
            navigationController?.popViewController(animated: true)
        }
        catch
        {
            print("Fetch Failed")
        }
    }
    
    
    //location added
    func fetchCityAndCountry(from location: CLLocation, completion: @escaping (_ city: String?, _ country:  String?, _ _street: String?, _ error: Error?) -> ()) {
        CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
            completion(placemarks?.first?.subLocality,
                       placemarks?.first?.locality,
                       placemarks?.first?.country,
                       error)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location: CLLocation = manager.location else { return }
        fetchCityAndCountry(from: location) { city, country, street, error in
            guard let _ = city, let country = country, let street = street, error == nil else { return }
            self.locationLabel.text = (street + ", " + country)
        }
    }
}

