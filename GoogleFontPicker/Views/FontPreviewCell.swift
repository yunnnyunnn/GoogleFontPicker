//
//  FontPreviewCell.swift
//  GoogleFontPicker
//
//  Created by Ting-Yang Chen on 11/18/18.
//  Copyright © 2018 Ting Yang Chen. All rights reserved.
//

import UIKit

class FontPreviewCell: UICollectionViewCell {
    
    // MARK: - Identifier
    static let reuseIdentifier = "FontPreviewCell"
    
    // MARK: - UI Elements
    @IBOutlet weak var label: UILabel!
    
    // MARK: - Binding
    var representedFont: FontName?
    
    // MARK: - UI Configurations
    override func awakeFromNib() {
        super.awakeFromNib()
        self.clipsToBounds = true
        self.layer.cornerRadius = 5.0
        self.layer.borderColor = UIColor(white: 140.0/255.0, alpha: 1.0).cgColor
        self.layer.borderWidth = 0.0
    }
    
    /**
     Present a font and bind the cell with the font name. Show border if the font is selected.
     
     - Parameter font: The font to present.
     - Parameter selectedFontName: The font name currently selected in the controller.

     */
    func configure(with font: Font, selectedFontName: FontName?) {
        
        // Bind cell with font name.
        self.representedFont = font.name
        
        // Show selection border if needed.
        if selectedFontName == font.name {
            self.layer.borderWidth = 2.0
        } else {
            self.layer.borderWidth = 0.0
        }
        
        // Change text and the font.
        self.label.text = font.name
        if let font = font.regular?.getCustomFont(withSize: 15.0) {
            // We have the font. Change it.
            self.label.isHidden = false
            self.label.font = font
        } else {
            self.label.isHidden = true
        }
    }
    
}
