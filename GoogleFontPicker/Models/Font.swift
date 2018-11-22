//
//  Font.swift
//  GoogleFontPicker
//
//  Created by Ting-Yang Chen on 11/18/18.
//  Copyright © 2018 Ting Yang Chen. All rights reserved.
//

import Foundation
import UIKit

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
    var regular: FontVariant? {
        get {
            return self.variants["regular"]
        }
    }
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
    static let KEY_LOCAL_FILE_NAME = "com.yunnnyunnn.GoogleFontPicker.FontVariant.localFileName"
    
    let name: FontVariantName
    let remoteURL: URL
    var downloadTask: URLSessionDataTask? = nil
    var localFileName: String? = nil
    private var customFont: UIFont? = nil

    override var description: String {
        return "Name: \(self.name)\nRemoteURL: \(self.remoteURL)\nLocalFileName: \(String(describing: self.localFileName))"
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
        aCoder.encode(self.localFileName, forKey: FontVariant.KEY_LOCAL_FILE_NAME)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        guard let name = aDecoder.decodeObject(forKey: FontVariant.KEY_NAME) as? FontVariantName,
            let remoteURL = aDecoder.decodeObject(forKey: FontVariant.KEY_REMOTE_URL) as? URL else {
                print("Failed to decode Font because of missing data.")
                return nil
        }
        
        self.name = name
        self.remoteURL = remoteURL
        self.localFileName = aDecoder.decodeObject(forKey: FontVariant.KEY_LOCAL_FILE_NAME) as? String
        
    }
    
    // MARK: - Accesss
    /**
     Get the custom UIFont with specific size.
     
     - Parameter size: The desired font size (in point).
     
     - Returns: A custom font from the file. `nil` if failure or no file path to create.
     
     */
    func getCustomFont(withSize size: CGFloat) -> UIFont? {
        
        // If UIFont already exists, use it.
        if let font = self.customFont {
            return font.withSize(size)
        }
        
        // Check if local file exist
        guard let localFileName = self.localFileName else {
            return nil
        }
        
        // Create a base font object.
        if let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(localFileName),
            let customFont = UIFont.font(withFileAt: fileURL) {
            
            self.customFont = customFont
            return customFont.withSize(size)
            
        } else {
            
            // Failed to create font.
            print("Failed to create custom font.")
            self.localFileName = nil
            return nil
            
        }
        
    }

    
}

extension UIFont {
    
    /**
     A convenient function to create a custom font with font file URL with a default size 15.0.
     
     - Parameter url: The local file URL for the font.
     
     - Returns: A custom font from the file. `nil` if failure.

     */
    class func font(withFileAt url: URL) -> UIFont? {
        guard let data = NSData(contentsOf: url) else {
            print("Failed to get data from URL:\n\(url)")
            return nil
        }
        
        guard let cfData = CFDataCreate(kCFAllocatorDefault, data.bytes.assumingMemoryBound(to: UInt8.self), data.length) else {
            print("Failed to convert data to cfData.")
            return nil
        }
        
        guard let dataProvider = CGDataProvider(data: cfData) else {
            print("Failed to create CGDataProvider.")
            return nil
        }
        
        guard let cgFont = CGFont(dataProvider) else {
            print("Failed to create CGFont.")
            return nil
        }
        
        var error: Unmanaged<CFError>?
        CTFontManagerRegisterGraphicsFont(cgFont, &error)
        if let fontName = cgFont.postScriptName,
            let customFont = UIFont(name: String(fontName), size: 15.0) {
            return customFont
        } else {
            print("Error loading Font.")
            return nil
        }
    }
}
