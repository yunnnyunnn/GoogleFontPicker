//
//  Font.swift
//  GoogleFontPicker
//
//  Created by Ting-Yang Chen on 11/18/18.
//  Copyright © 2018 Ting Yang Chen. All rights reserved.
//

import Foundation

typealias FontName = String
typealias FontVariantName = String

class Font: NSObject, NSCoding {
    
    // MARK: - Constants and properties
    static let KEY_NAME = "com.yunnnyunnn.GoogleFontPicker.Font.name"
    static let KEY_VERSION = "com.yunnnyunnn.GoogleFontPicker.Font.version"
    static let KEY_VARIANTS = "com.yunnnyunnn.GoogleFontPicker.Font.variants"
    
    let name: FontName
    let version: String
    var variants: [FontVariantName: FontVariant]
    override var description: String {
        return "Name: \(self.name)\nVersion: \(self.version)\nVariants: \(self.variants)"
    }
    
    // MARK: - Initializer
    init(name: FontName, version: String, variants: [FontVariantName: FontVariant]) {
        self.name = name
        self.version = version
        self.variants = variants
    }
    
    // MARK: - Coding
    func encode(with aCoder: NSCoder) {
        
        aCoder.encode(self.name, forKey: Font.KEY_NAME)
        aCoder.encode(self.version, forKey: Font.KEY_VERSION)
        aCoder.encode(self.variants, forKey: Font.KEY_VARIANTS)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        guard let name = aDecoder.decodeObject(forKey: Font.KEY_NAME) as? FontName,
            let version = aDecoder.decodeObject(forKey: Font.KEY_VERSION) as? String,
            let variants = aDecoder.decodeObject(forKey: Font.KEY_VARIANTS) as? [FontVariantName: FontVariant] else {
                print("Failed to decode Font because of missing data.")
                return nil
        }
        
        self.name = name
        self.version = version
        self.variants = variants
        
    }
    
}

class FontVariant: NSObject, NSCoding {
    
    // MARK: - Constants and properties
    static let KEY_NAME = "com.yunnnyunnn.GoogleFontPicker.FontVariant.name"
    static let KEY_REMOTE_URL = "com.yunnnyunnn.GoogleFontPicker.FontVariant.remoteURL"
    static let KEY_LOCAL_URL = "com.yunnnyunnn.GoogleFontPicker.FontVariant.localURL"
    
    let name: FontVariantName
    let remoteURL: URL
    var downloadTask: URLSessionDataTask? = nil
    var localURL: URL? = nil
    override var description: String {
        return "Name: \(self.name)\nRemoteURL: \(self.remoteURL)\nLocalURL: \(String(describing: self.localURL))"
    }
    
    // MARK: - Initializer
    init(name: String, remoteURL: URL) {
        self.name = name
        self.remoteURL = remoteURL
    }
    
    // MARK: - Coding
    func encode(with aCoder: NSCoder) {
        
        aCoder.encode(self.name, forKey: FontVariant.KEY_NAME)
        aCoder.encode(self.remoteURL, forKey: FontVariant.KEY_REMOTE_URL)
        aCoder.encode(self.localURL, forKey: FontVariant.KEY_LOCAL_URL)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        guard let name = aDecoder.decodeObject(forKey: FontVariant.KEY_NAME) as? FontVariantName,
            let remoteURL = aDecoder.decodeObject(forKey: FontVariant.KEY_REMOTE_URL) as? URL else {
                print("Failed to decode Font because of missing data.")
                return nil
        }
        
        self.name = name
        self.remoteURL = remoteURL
        self.localURL = aDecoder.decodeObject(forKey: FontVariant.KEY_LOCAL_URL) as? URL
        
    }
    
}
