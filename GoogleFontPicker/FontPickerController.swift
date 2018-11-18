//
//  FontPickerController.swift
//  GoogleFontPicker
//
//  Created by Ting-Yang Chen on 11/17/18.
//  Copyright © 2018 Ting Yang Chen. All rights reserved.
//

import UIKit

class FontPickerController: UIViewController {

    // MARK: - UI elements
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var previewTextField: UITextField!
    @IBOutlet weak var topViewBottomSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var fontCollectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Data
    var fonts: [Font] = FontManager.shared.fontList
    var pickedFontName: FontName? = nil

    // MARK: - Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Zero state for bottom view.
        if self.fonts.count == 0 {
            self.activityIndicator.isHidden = false
            self.activityIndicator.startAnimating()
        } else {
            self.activityIndicator.stopAnimating()
            self.activityIndicator.isHidden = true
        }
        
        // Navigation items setup.
        self.title = NSLocalizedString("picker_title", comment: "")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.doneButtonPressed(_:)))
        
        // Set up collection view.
        self.fontCollectionView.dataSource = self
        self.fontCollectionView.delegate = self
        // Uncomment this line to enable data prefetching.
        //self.fontCollectionView.prefetchDataSource = self
        
        // Listen to notifications
        NotificationCenter.default.addObserver(self, selector: #selector(self.fontListUpdated(_:)), name: NSNotification.Name(rawValue: FontManager.NOTIFICATION_UPDATED), object: nil)
        
        // Update Fonts.
        DispatchQueue.global(qos: .background).async {
            FontManager.shared.updateFonts()
        }
    }
    
    // MARK: - IBActions

    @IBAction func doneButtonPressed(_ sender: Any) {
        self.dismiss(animated: true) {
        }
    }
    
    // MARK: - Notification Handlers
    @objc func fontListUpdated(_ notification: NSNotification) {
        print("Font updated.")
        
        let fontWasEmpty = self.fonts.count == 0
        
        self.fonts = FontManager.shared.fontList
        
        if self.fonts.count == 0 {
            self.activityIndicator.isHidden = false
            self.activityIndicator.startAnimating()
        } else {
            self.activityIndicator.stopAnimating()
            self.activityIndicator.isHidden = true
        }
        
        self.fontCollectionView.reloadData()
        
        if fontWasEmpty {
            self.fontCollectionView.alpha = 0.0
            UIView.animate(withDuration: 0.25, animations: {
                self.fontCollectionView.alpha = 1.0
            }, completion: nil)
        }
        
    }

}

extension FontPickerController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDataSourcePrefetching {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.fonts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FontPreviewCell.reuseIdentifier, for: indexPath) as? FontPreviewCell else {
            fatalError("Expected `\(FontPreviewCell.self)` type for reuseIdentifier \(FontPreviewCell.reuseIdentifier). Check the configuration in Main.storyboard.")
        }
        
        let font = self.fonts[indexPath.row]
        
        cell.configure(with: font, selectedFontName: self.pickedFontName)
        
        if font.regular?.localFileName == nil && font.regular?.downloadTask == nil {
            FontManager.shared.downloadFile(forFont: font) { (localFileName) in
                
                if font.name == cell.representedFont,
                    let localFileName = localFileName,
                    let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first,
                    let font = UIFont.font(withFileAt: fileURL.appendingPathComponent(localFileName), size: 15.0) {
                    // Now we have the font. Change it and animate.
                    DispatchQueue.main.async {
                        
                        cell.label.font = font
                        cell.label.isHidden = false
                        cell.label.alpha = 0.0
                        UIView.animate(withDuration: 0.25, animations: {
                            cell.label.alpha = 1.0
                        })
                        
                    }
                }
                
            }
        }
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let font = self.fonts[indexPath.row]
        self.pickedFontName = font.name
        collectionView.reloadData()
        
        if let localFileName = font.regular?.localFileName,
            let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first,
            let font = UIFont.font(withFileAt: fileURL.appendingPathComponent(localFileName), size: 26.0) {
            self.previewTextField.font = font
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        
        // Begin asynchronously fetching font files for the requested index paths.
        for indexPath in indexPaths {
            let font = self.fonts[indexPath.row]
            
            if font.regular?.localFileName == nil && font.regular?.downloadTask == nil {
                FontManager.shared.downloadFile(forFont: font) { (localFileName) in
                    
                    if let localFileName = localFileName,
                        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first,
                        let customFont = UIFont.font(withFileAt: fileURL.appendingPathComponent(localFileName), size: 15.0) {
                        // Now we have the font. Change it and animate.
                        DispatchQueue.main.async {
                            
                            if let cell = collectionView.cellForItem(at: IndexPath(row: indexPath.row, section: 0)) as? FontPreviewCell,
                                font.name == cell.representedFont {
                                
                                cell.label.font = customFont
                                cell.label.isHidden = false
                                cell.label.alpha = 0.0
                                UIView.animate(withDuration: 0.25, animations: {
                                    cell.label.alpha = 1.0
                                })
                            }
                            
                            
                        }
                    }
                    
                    
                }
            }
            
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        // Cancel any in-flight requests for data for the specified index paths.
        for indexPath in indexPaths {
            let font = self.fonts[indexPath.row]
            FontManager.shared.cancelDownload(forFont: font)
        }
    }
    
    
}
