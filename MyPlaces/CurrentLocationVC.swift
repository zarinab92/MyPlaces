//
//  CurrentLocationVC.swift
//  MyPlaces
//
//  Created by Zarina Bekova on 10/17/20.
//

import UIKit
import CoreLocation
import CoreData

class CurrentLocationVC: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var tagButton: UIButton!
    @IBOutlet weak var getButton: UIButton!
    
    var managedObjectContext: NSManagedObjectContext!
    
    let locationManager = CLLocationManager()
    var location: CLLocation?
    var isLocationManagerWorking = false
    var lastLocationError: Error?
    
    let geocoder = CLGeocoder()
    var placeMark: CLPlacemark?
    var lastGeocoderError: Error?
    var isGeocoderWorking = false
    
    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateLabels()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    
    @IBAction func getLocation(_ sender: UIButton) {
        let authStatus = locationManager.authorizationStatus
        
        if authStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
            return
        }
        
        if authStatus == .denied || authStatus == .restricted {
            showLocationDeniedAlert()
            return
        }
        
        
        if isLocationManagerWorking == true {
            stopLocationManager()
        } else {
            location = nil
            lastLocationError = nil
            startLocationManager()
        }
        
        updateLabels()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "tagLocation" {
            let destination = segue.destination as! LocationDetailsTableViewController
            
            destination.coordinate = location!.coordinate
            destination.placeMark = self.placeMark
            destination.managedObjectContext = self.managedObjectContext
        }
    }
    
    
    // MARK: - Helping Methods
    
    func showLocationDeniedAlert() {
        let alert = UIAlertController(title: "Location Service Disabled", message: "Please enable location services for this app in Settings -> Privacy -> Location Services -> MyPlaces", preferredStyle: .alert)
        
        let okButton = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alert.addAction(okButton)

        present(alert, animated: true, completion: nil)
    }
    
    func startLocationManager() {
        if CLLocationManager.locationServicesEnabled() == true {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            isLocationManagerWorking = true
            
            timer = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(timeOut), userInfo: nil, repeats: false)
            
        }
    }
    
    func stopLocationManager() {
        if isLocationManagerWorking == true {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            isLocationManagerWorking = false
            
            if let timer = timer {
                timer.invalidate()
            }
            
        }
    }
    
    @objc func timeOut() {
        print("TIME OUT")
        if location == nil {
            stopLocationManager()
            lastLocationError = NSError(domain: "MyErrorDomain", code: 7, userInfo: nil)
            updateLabels()
        }
    }
    
    func configureGetLocationButton() {
        if isLocationManagerWorking {
            getButton.setTitle("Stop", for: .normal)
        } else {
            getButton.setTitle("Get My Location", for: .normal)
        }
    }
    
    func updateLabels() {
        if let location = location {
            latitudeLabel.text = String(format: "%.8f", location.coordinate.latitude)
            longitudeLabel.text = String(format: "%.8f", location.coordinate.longitude)
            tagButton.isHidden = false
            messageLabel.text = ""
            
            if let placemark = placeMark {
                addressLabel.text = string(from: placemark)
            } else if isGeocoderWorking == true {
                addressLabel.text = "Searching for address"
            } else if lastGeocoderError != nil {
                addressLabel.text = "Error finding address"
            } else {
                addressLabel.text = "No Address Found"
            }
            
        } else {
            latitudeLabel.text = ""
            longitudeLabel.text = ""
            addressLabel.text = ""
            tagButton.isHidden = true
            
            var statusMessage: String = ""
            
            if let error = lastLocationError as NSError? {
                if error.domain == kCLErrorDomain && error.code == CLError.denied.rawValue {
                    statusMessage = "Location Services Disabled"
                } else if error.domain == "MyErrorDomain" && error.code == 7 {
                    statusMessage = "Try again later"
                } else {
                    statusMessage = "Error Getting Location"
                }
            } else if CLLocationManager.locationServicesEnabled() == false {
                statusMessage = "Location Services Disabled"
            } else if isLocationManagerWorking == true {
                statusMessage = "Searching..."
            } else {
                statusMessage = "Tap 'Get My Location' to Start"
            }
            
            messageLabel.text = statusMessage
        }
        
        configureGetLocationButton()
        
    }
    
    func string(from placemark: CLPlacemark) -> String {
        
        var line1 = ""
        
        line1.add(text: placemark.subThoroughfare)
        line1.add(text: placemark.thoroughfare, separatedBy: " ")
        
        var line2 = ""
        
        line2.add(text: placemark.locality)
        line2.add(text: placemark.administrativeArea, separatedBy: " ")
        line2.add(text: placemark.country, separatedBy: " ")
        line2.add(text: placemark.postalCode, separatedBy: ", ")
        
        return line1 + "\n" + line2
    }

    
    
    // MARK: - CLLocation Manager Delegate
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("didFailWithError: \(error.localizedDescription)")
        
        if (error as NSError).code == CLError.locationUnknown.rawValue {
            return
        }
        
        lastLocationError = error
        stopLocationManager()
        updateLabels()
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLocation = locations.last!
        print("didUpdateLocations: \(newLocation)")
        
        if newLocation.timestamp.timeIntervalSinceNow < -10 {
            return
        }
        
        if newLocation.horizontalAccuracy < 0 {
            return
        }
        
        // 1-location (1000m) -> 2-location (200m) -> 3-location (50m) 5-location (10m) -> 6-location (100m)
        
        if location == nil || location!.horizontalAccuracy > newLocation.horizontalAccuracy {
            lastLocationError = nil
            location = newLocation
            
            if newLocation.horizontalAccuracy <= locationManager.desiredAccuracy {
                print("---We are done!---")
                stopLocationManager()
            }
            
            updateLabels()
            
            if isGeocoderWorking == false {
                
                isGeocoderWorking = true
                
                geocoder.reverseGeocodeLocation(newLocation) { (placemarks, error) in
                    self.lastGeocoderError = error
                    if error == nil, let places = placemarks, !places.isEmpty {
                        self.placeMark = places.last!
                    } else {
                        self.placeMark = nil
                    }
                    
                    self.isGeocoderWorking = false
                    self.updateLabels()
                }
    
            }
            
        }
        
    }
    
    
}


/* HW:
 1 - Geocoder -> CLPlacemark -> String -> Model
 2 - Timer -> 30 seconds -> Timout (stopLocationManager) + (NSError)
 3 - func string(from placemark: CLplacemark) -> String
 4 - Done -> TableView -> TableViewCell (latitude, longitude, address)
 */
