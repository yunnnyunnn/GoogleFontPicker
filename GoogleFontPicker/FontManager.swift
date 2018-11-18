//
//  FontManager.swift
//  GoogleFontPicker
//
//  Created by Ting-Yang Chen on 11/18/18.
//  Copyright © 2018 Ting Yang Chen. All rights reserved.
//

import Foundation

/**
 FontManager manages all the font instances accross the app. It updates font list from remote and cache font data.
 */
class FontManager {
    
    static let shared = FontManager()

    fileprivate static let KEY_FONTS = "com.yunnnyunnn.GoogleFontPicker.fonts"
    static let NOTIFICATION_UPDATED = "font-updated"

    fileprivate var fonts: [FontName: Font]
    fileprivate var updateRequest: URLSessionTask? = nil
    var fontList: [Font] {
        get {
            return self.fonts.values.sorted { (f1, f2) -> Bool in
                return f1.name < f2.name
            }
        }
    }
    
    fileprivate init() {
        
        if let fontData = UserDefaults.standard.data(forKey: FontManager.KEY_FONTS),
            let cachedFonts = NSKeyedUnarchiver.unarchiveObject(with: fontData) as? [FontName: Font]
        {
            self.fonts = cachedFonts
        } else {
            self.fonts = [:]
        }
        
    }
    
    fileprivate func saveToUserDefaults() {
        // Save the current list to UserDefaults.
        let fontData = NSKeyedArchiver.archivedData(withRootObject: self.fonts)
        UserDefaults.standard.set(fontData, forKey: FontManager.KEY_FONTS)
    }
    
    func updateFonts() {
        
        // Avoid duplicated request.
        if self.updateRequest != nil {
            print("There is an ongoing request to update fonts. Will not create another request.")
            return
        }
        
        // Construct URL.
        guard let key = KeyManager.shared.googleFont,
            let url = URL(string: "https://www.googleapis.com/webfonts/v1/webfonts?sort=popularity&key=\(key)") else {
                print("ERROR: Failed to update fonts from remote because of missing API key.")
                return
        }
        
        // Send request.
        self.updateRequest = URLSession.shared.dataTask(with: url) { [unowned self] (data, response, error) in
            
            // Clear request.
            self.updateRequest = nil
            
            // Parse result.
            if let data = data,
                let json = try? JSONSerialization.jsonObject(with: data, options: []),
                let fontData = json as? [AnyHashable: Any],
                self.updateFonts(withData: fontData) == true {
                
                // Send notification to tell the app: Font has been updated.
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: FontManager.NOTIFICATION_UPDATED), object: nil)
                }
                
            } else {
                print("Failed to update font info with error:\n\(String(describing: error))")
            }
        }
        self.updateRequest?.resume()
    }
    
    fileprivate func updateFonts(withData data: [AnyHashable: Any]) -> Bool {
        
        guard let items = data["items"] as? [[AnyHashable: Any]] else {
            print("Cannot find items from data. Will not update local fonts.")
            return false
        }
        
        for fontData in items {
            
            // Check essential data.
            guard let family = fontData["family"] as? String,
                let version = fontData["version"] as? String,
                let variantList = fontData["variants"] as? [String],
                let files = fontData["files"] as? [AnyHashable: String] else {
                print("Data missing for font item:\n\(fontData)\nIgnoring.")
                continue
            }
            
            if self.fonts[family]?.version != version {
                
                // Local font with this name does not exist or has old version.
                // Create a new font instance.
                var variants = [FontVariantName: FontVariant]()
                for variantName in variantList {
                    if let fileString = files[variantName],
                        let remoteURL = URL(string: fileString) {
                        variants[fileString] = FontVariant(name: variantName, remoteURL: remoteURL)
                    } else {
                        // Cannot find url from variant list.
                    }
                }
                self.fonts[family] = Font(name: family, version: version, variants: variants)
                
            } else {
                // Local font exists and has the same version as remote. No update needed.
            }
            
        }
        
        // Save to user default.
        self.saveToUserDefaults()
        
        return true
    }


}
