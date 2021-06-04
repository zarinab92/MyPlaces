//
//  String+AddText.swift
//  MyPlaces
//
//  Created by Aslan Arapbaev on 11/21/20.
//

import Foundation


extension String {
    
    mutating func add(text: String?, separatedBy seperator: String = "") {
        if let text = text {
            if !isEmpty {
                self += seperator
            }
            self += text
        }
    }
    
}

// "" + seperator + text
