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
    }

    
    func configure(with font: Font) {
        self.representedFont = font.name
        self.label.text = font.name
    }
    
}
