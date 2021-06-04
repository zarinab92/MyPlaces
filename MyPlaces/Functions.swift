//
//  Functions.swift
//  MyPlaces
//
//  Created by Zarina Bekova on 11/4/20.
//

import Foundation

func afterDelay(_ seconds: Double, execute: @escaping () -> Void) {
    
    DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: execute)
    
}


func appDocumentsDirectory() -> URL {
    return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
}


let CoreDataErrorNotification = Notification.Name("CoreDataErrorNotification")


func fatalCoreDataError(_ error: Error) {
    print(error.localizedDescription)
    NotificationCenter.default.post(name: CoreDataErrorNotification, object: nil)
}
