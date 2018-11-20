//
//  KeyManager.swift
//  GoogleFontPicker
//
//  Created by Ting-Yang Chen on 11/17/18.
//  Copyright © 2018 Ting Yang Chen. All rights reserved.
//

import Foundation

class KeyManager {
    
    static let shared = KeyManager()
    
    fileprivate let propertyList: [String: String]?
    
    var googleFont: String? {
        get {
            return self.propertyList?["GOOGLE_FONT"]
        }
    }
    
    fileprivate init() {
        if let url  = Bundle.main.url(forResource: "Keys", withExtension: "plist"),
            let data = try? Data(contentsOf: url),
            let plistDictionary = (try? PropertyListSerialization.propertyList(from: data, options: [], format: nil)) as? [String: String] {
            self.propertyList = plistDictionary
        } else {
            self.propertyList = nil
            fatalError("Add a plist file named Keys.plist with your confidential keys to the main bundle.")
        }
    }
    
}
