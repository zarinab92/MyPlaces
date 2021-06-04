//
//  Location+CoreDataClass.swift
//  MyPlaces
//
//  Created by Zarina Bekova on 11/4/20.
//
//

import Foundation
import CoreData
import MapKit

@objc(Location)
public class Location: NSManagedObject, MKAnnotation {
    
    public var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    public var title: String? {
        return category
    }
    
    public var subtitle: String? {
        if locationDescription.isEmpty {
            return "NO DESCRIPTION"
        } else {
            return locationDescription
        }
    }
    
    
    // propeties for photo
    
    var hasPhoto: Bool {
        return photoID != nil
    }
    
    var photoURL: URL {
        assert(photoID != nil, "No photo ID")
        let filename = "Photo-\(photoID!.intValue).jpg"
        // /.../Documents/Photo-3.jpg
        return appDocumentsDirectory().appendingPathComponent(filename)
    }
    
    var photoImage: UIImage? {
        return UIImage(contentsOfFile: photoURL.path)
    }
    
    static func nextPhotoID() -> Int {
        let userDefaults = UserDefaults.standard
        let currentID = userDefaults.integer(forKey: "PhotoID") + 1
        userDefaults.set(currentID, forKey: "PhotoID")
        userDefaults.synchronize()
        return currentID
    }
    
    func deletePhotoFile() {
        if hasPhoto {
            do {
                try FileManager.default.removeItem(at: photoURL)
            } catch  {
                print("Error deleting file: \(error.localizedDescription)")
            }
        }
    }

    
}
