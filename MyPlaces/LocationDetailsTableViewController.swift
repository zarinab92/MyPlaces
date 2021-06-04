//
//  LocationDetailsTableViewController.swift
//  MyPlaces
//
//  Created by Zarina Bekova on 10/28/20.
//

import UIKit
import CoreLocation
import CoreData


private let dateFormatter: DateFormatter = { // lazy loading
    let formatter = DateFormatter()
    
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    
    print("--- formatter created ---")
    
    return formatter
}()

class LocationDetailsTableViewController: UITableViewController {
    
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var addPhotoLabel: UILabel!
    @IBOutlet weak var imageHeight: NSLayoutConstraint!
    
    var managedObjectContext: NSManagedObjectContext!
    
    var coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var placeMark: CLPlacemark?
    var categoryName = "No Category"
    var currentDate = Date()
    var descriptionText = ""
    var pickedImage: UIImage?
    var locationToEdit: Location? {
        didSet {
            if let location = locationToEdit {
                self.descriptionText = location.locationDescription
                self.categoryName = location.category
                self.currentDate = location.date
                self.placeMark = location.placemark
                self.coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        listenForBackgroundNotification()
        
        if let location = locationToEdit {
            title = "Edit Location"
            
            if location.hasPhoto {
                if let photo = location.photoImage {
                    show(image: photo)
                }
            }
        }

        descriptionTextView.text = descriptionText
        categoryLabel.text = categoryName
        
        latitudeLabel.text = String(format: "%.8f", coordinate.latitude)
        longitudeLabel.text = String(format: "%.8f", coordinate.longitude)
        
        if let placemark = placeMark {
            addressLabel.text = string(from: placemark)
        } else {
            addressLabel.text = "No Address Found"
        }
        
        dateLabel.text = format(date: currentDate)
        
    }
    
    deinit {
        print("---- deinit \(self) ----")
    }

    @IBAction func done(_ sender: UIBarButtonItem) {
        
        let hudView = HudView.hud(inView: navigationController!.view, animated: true)
        // 1. -> creating Location and making changes
        
        let location: Location
        
        if let locationToEdit = locationToEdit {
            // edit
            hudView.text = "Updated"
            location = locationToEdit
        } else {
            // create
            hudView.text = "Saved"
            location = Location(context: managedObjectContext) // creating location
            location.photoID = nil
        }
        
        location.category = categoryName   // changing or editing
        location.locationDescription = descriptionTextView.text
        location.latitude = coordinate.latitude
        location.longitude = coordinate.longitude
        location.date = currentDate
        location.placemark = placeMark
        
        
        // saving photo
        
        if let image = pickedImage {
            if location.hasPhoto == false {
                location.photoID = Location.nextPhotoID() as NSNumber
            }
            
            if let data = image.jpegData(compressionQuality: 0.5) {
                do {
                    try data.write(to: location.photoURL, options: .atomic)
                } catch {
                    print("Error writing file: \(error.localizedDescription)")
                }
            }
        }
        
        // 2. -> save() all changes
        
        do {
            try managedObjectContext.save()
            // success
            afterDelay(0.6) {
                hudView.hide()
                self.navigationController?.popViewController(animated: true)
            }
            
        } catch {
            fatalCoreDataError(error)
        }
        
    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func categoryPickerDidPickCategory(_ segue: UIStoryboardSegue) {
        let controller = segue.source as! CategoryPickerTVController
        categoryName = controller.selectedCategoryName
        categoryLabel.text = categoryName
    }
    
    func format(date: Date) -> String {
        print("calling formatter")
        return dateFormatter.string(from: date)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "pickCategory" {
            let destVC = segue.destination as! CategoryPickerTVController
            destVC.selectedCategoryName = categoryName
        }
    }
    
    func string(from placemark: CLPlacemark) -> String {
        
        var text = ""
        
        text.add(text: placemark.subThoroughfare)
        text.add(text: placemark.thoroughfare, separatedBy: " ")
        text.add(text: placemark.locality, separatedBy: ", ")
        text.add(text: placemark.administrativeArea, separatedBy: ", ")
        text.add(text: placemark.postalCode, separatedBy: ", ")
        
        return text
    }
    
    // MARK: - Table View Delegates
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            descriptionTextView.becomeFirstResponder()
        } else if indexPath.section == 1 && indexPath.row == 0 {
            pickPhoto()
        } else {
            descriptionTextView.resignFirstResponder()
        }
    }
    
}

// Add Photo
extension LocationDetailsTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func show(image: UIImage) {
        imageView.image = image
        imageView.isHidden = false
        addPhotoLabel.text = ""
        imageHeight.constant = 260
        tableView.reloadData()
    }
    
    func pickPhoto() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            showPhotoAlert()
        } else {
            choosePhotoFromGallery()
        }
    }
    
    func showPhotoAlert() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancel)
        
        let gallery = UIAlertAction(title: "Choose from Gallery", style: .default) { (_) in
            self.choosePhotoFromGallery()
        }
        alert.addAction(gallery)
        
        let camera = UIAlertAction(title: "Take Photo", style: .default) { (_) in
            self.takePhotoWithCamera()
        }
        alert.addAction(camera)
        
        present(alert, animated: true, completion: nil)
    }
    
    
    func takePhotoWithCamera() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .camera
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    
    
    func choosePhotoFromGallery() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    
    
    
    // MARK: - UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        pickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
            
        if let image = pickedImage {
            show(image: image)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Listen for Background Notification
    
    func listenForBackgroundNotification() {
        NotificationCenter.default.addObserver(forName: UIScene.didEnterBackgroundNotification, object: nil, queue: OperationQueue.main) { [weak self] (_) in  // capture list helps avoid bug (ownership cycle)
            
            if self?.presentedViewController != nil {
                self?.dismiss(animated: false, completion: nil)
            }
            
            self?.descriptionTextView.resignFirstResponder()
        }
    }
    
}

// ARC
