//
//  FontPreviewCell.swift
//  GoogleFontPicker
//
//  Created by Ting-Yang Chen on 11/18/18.
//  Copyright © 2018 Ting Yang Chen. All rights reserved.
//

import UIKit

class FontPreviewCell: UICollectionViewCell {
    
    static let reuseIdentifier = "FontPreviewCell"
    
    // MARK: - UI Elements
    @IBOutlet weak var label: UILabel!
    
    var representedFont: FontName?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.clipsToBounds = true
        self.layer.cornerRadius = 5.0
        self.layer.borderColor = UIColor.darkGray.cgColor
        self.layer.borderWidth = 0.0
    }

    func configure(with font: Font, selectedFontName: FontName?) {
        
        self.representedFont = font.name
        self.label.text = font.name
        
        if selectedFontName == font.name {
            self.layer.borderWidth = 1.0
        } else {
            self.layer.borderWidth = 0.0
        }
        
        if let localFileName = font.regular?.localFileName,
            let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first,
            let font = UIFont.font(withFileAt: fileURL.appendingPathComponent(localFileName), size: 15.0) {
            // We have the font. Change it.
            self.label.isHidden = false
            self.label.font = font
        } else {
            self.label.isHidden = true
        }
    }
    
}
