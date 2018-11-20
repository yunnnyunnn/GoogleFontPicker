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
        
        // Textfield setup.
        self.previewTextField.delegate = self
        self.previewTextField.text = NSLocalizedString("picker_edit", comment: "")
        self.previewTextField.placeholder = NSLocalizedString("picker_placeholder", comment: "")

        
        // Add tap gesture recognizer.
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.topViewTapped(_:)))
        self.topView.addGestureRecognizer(tapGestureRecognizer)
        
        // Set up collection view.
        self.fontCollectionView.isPrefetchingEnabled = false
        self.fontCollectionView.dataSource = self
        self.fontCollectionView.delegate = self
        
        // Listen to notifications
        NotificationCenter.default.addObserver(self, selector: #selector(self.fontListUpdated(_:)), name: NSNotification.Name(rawValue: FontManager.NOTIFICATION_UPDATED), object: nil)
        // Register keyboard notifications
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillChangeFrame(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)

        // Update Fonts.
        DispatchQueue.global(qos: .background).async {
            FontManager.shared.updateFonts()
        }
        
    }
    
    // MARK: - Helpers
    func presentFontIfVisible(_ font: Font) {
        
        for visibleCell in self.fontCollectionView.visibleCells {
            if let previewCell = visibleCell as? FontPreviewCell,
                previewCell.representedFont == font.name,
                let localFileName = font.regular?.localFileName,
                let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first,
                let customFont = UIFont.font(withFileAt: fileURL.appendingPathComponent(localFileName), size: 15.0) {
                
                let wasHidden = previewCell.label.isHidden
                previewCell.label.font = customFont
                previewCell.label.isHidden = false
                if wasHidden {
                    previewCell.label.alpha = 0.0
                    UIView.animate(withDuration: 0.25, animations: {
                        previewCell.label.alpha = 1.0
                    })
                }
                
                break
            }
        }
        
    }
    
    // MARK: - IBActions

    @IBAction func doneButtonPressed(_ sender: Any) {
        if self.previewTextField.isFirstResponder {
            self.previewTextField.resignFirstResponder()
        } else {
            self.dismiss(animated: true) {
            }
        }
    }
    
    @objc func topViewTapped(_ sender: Any) {
        self.previewTextField.resignFirstResponder()
    }
    
    // MARK: - Notification Handlers
    @objc func fontListUpdated(_ notification: Foundation.Notification) {
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
    
    @objc func keyboardWillChangeFrame(_ notification: Foundation.Notification) {
        
        // Adjust input field position.
        if let info = (notification as NSNotification).userInfo {
            
            let keyboardEndFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
            
            self.topViewBottomSpaceConstraint.constant = keyboardEndFrame.size.height - self.bottomView.frame.height
            
            var animationDuration: TimeInterval = 0.25
            
            if let keyboardAnimationDuration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber {
                animationDuration = TimeInterval(truncating: keyboardAnimationDuration)
            }
            
            UIView.animate(withDuration: animationDuration, delay: 0.0, options: .curveEaseInOut, animations: { () -> Void in
                self.view.layoutIfNeeded()
            }, completion: { (completion) -> Void in
            })
            
        }
        
    }
    
    @objc func keyboardWillHide(_ notification: Foundation.Notification) {
        
        // Adjust input field position.
        if let info = (notification as NSNotification).userInfo {
            
            self.topViewBottomSpaceConstraint.constant = 0
            
            var animationDuration: TimeInterval = 0.25
            
            if let keyboardAnimationDuration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber {
                animationDuration = TimeInterval(truncating: keyboardAnimationDuration)
            }
            
            UIView.animate(withDuration: animationDuration, delay: 0.0, options: .curveEaseInOut, animations: { () -> Void in
                self.view.layoutIfNeeded()
            }, completion: { (completion) -> Void in
            })
        }
    }

}

extension FontPickerController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.previewTextField.resignFirstResponder()
        return true
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
        
        // Basic setup for the cell and binding.
        cell.configure(with: font, selectedFontName: self.pickedFontName)
        
        // If font is not downloaded and has no ongoing download task, start the download process.
        if font.regular?.localFileName == nil && font.regular?.downloadTask == nil {
            FontManager.shared.downloadFile(forFont: font) { [unowned self] (localFileName) in
                
                if let localFileName = localFileName {
                    
                    if cell.representedFont == font.name,
                        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first,
                        let customFont = UIFont.font(withFileAt: fileURL.appendingPathComponent(localFileName), size: 15.0) {
                        
                        // The cell is still there representing the same font. Show the preview.
                        DispatchQueue.main.async {
                            let wasHidden = cell.label.isHidden
                            cell.label.font = customFont
                            cell.label.isHidden = false
                            if wasHidden {
                                cell.label.alpha = 0.0
                                UIView.animate(withDuration: 0.25, animations: {
                                    cell.label.alpha = 1.0
                                })
                            }
                        }
                        
                    } else {
                        // The original cell is not representing the same font. Try to find if another cell should present the font now.
                        DispatchQueue.main.async {
                            self.presentFontIfVisible(font)
                        }
                    }
                }
                
            }
        }
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let font = self.fonts[indexPath.row]
        
        if let localFileName = font.regular?.localFileName,
            let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first,
            let customfont = UIFont.font(withFileAt: fileURL.appendingPathComponent(localFileName), size: 26.0) {
            self.previewTextField.font = customfont
            self.pickedFontName = font.name
            collectionView.reloadData()
        }
        
        collectionView.deselectItem(at: indexPath, animated: false)
    }
    
}
