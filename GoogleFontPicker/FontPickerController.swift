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

extension FontPickerController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.fonts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FontPreviewCell.reuseIdentifier, for: indexPath) as? FontPreviewCell else {
            fatalError("Expected `\(FontPreviewCell.self)` type for reuseIdentifier \(FontPreviewCell.reuseIdentifier). Check the configuration in Main.storyboard.")
        }
        
        let font = self.fonts[indexPath.row]
        cell.configure(with: font)
        
        return cell
        
    }
    
    
}
