//
//  MapViewController.swift
//  MyPlaces
//
//  Created by Zarina Bekova on 11/18/20.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    var managedObjectContext: NSManagedObjectContext! {
        didSet {
            NotificationCenter.default.addObserver(forName: Notification.Name.NSManagedObjectContextObjectsDidChange, object: managedObjectContext, queue: OperationQueue.main) { (notification) in
                if self.isViewLoaded {
                    self.updateLocations()
                    
//                    if let dictionary = notification.userInfo {
//                        let updatedLocation = dictionary[NSUpdatedObjectsKey] as! Location
//                        self.mapView.removeAnnotation(updatedLocation)
//                        self.mapView.addAnnotation(updatedLocation)
//                    }
                }
            }
        }
    }
    
    var locations = [Location]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateLocations()
        
        mapView.delegate = self
       
    }
    

    @IBAction func showUser() {
        let userLocation = mapView.userLocation.coordinate
        
        let region = MKCoordinateRegion(center: userLocation, latitudinalMeters: 1000, longitudinalMeters: 1000)
        
        mapView.setRegion(mapView.regionThatFits(region), animated: true)
        
    }

    // MARK: - Helper methods
    
    func updateLocations() {
        mapView.removeAnnotations(self.locations)
        
        let fetchRequest = NSFetchRequest<Location>()
        fetchRequest.entity = Location.entity()
        
        do {
            self.locations = try managedObjectContext.fetch(fetchRequest) // returns array of locations
            mapView.addAnnotations(self.locations)
        } catch {
            fatalCoreDataError(error)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editLocation" {
            let destination = segue.destination as! LocationDetailsTableViewController
            destination.managedObjectContext = managedObjectContext
            
            let button = sender as! UIButton
            destination.locationToEdit = locations[button.tag]
        }
    }
    
}

extension MapViewController: MKMapViewDelegate {
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // 1 annotations (userLocation, savedLocation)
        guard annotation is Location else {
            return nil
        }
        
        // 2 find reusable View
        let identifier = "Location"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        // 3 create nonexisting annotation view
        if annotationView == nil {
            let pinView =  MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            
            pinView.isEnabled = true
            pinView.canShowCallout = true
            pinView.pinTintColor = .green
            
            let rightButton = UIButton(type: .detailDisclosure)
            rightButton.addTarget(self, action: #selector(showLocationDetails(_:)), for: .touchUpInside)
            
            pinView.rightCalloutAccessoryView = rightButton
            
            annotationView = pinView
        }
        
        if let annotationView = annotationView {
            let button = annotationView.rightCalloutAccessoryView as! UIButton
            
            if let index = locations.firstIndex(of: annotation as! Location) {
                button.tag = index
            }
        }
        
        
        return annotationView
    }
    
    @objc func showLocationDetails(_ sender: UIButton) {
        performSegue(withIdentifier: "editLocation", sender: sender)
    }
    
}
