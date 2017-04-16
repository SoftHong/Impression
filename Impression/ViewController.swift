//
//  ViewController.swift
//  Impression
//
//  Created by 홍성호 on 2017. 4. 17..
//  Copyright © 2017년 홍성호. All rights reserved.
//

import UIKit
import DBImageColorPicker

public extension UIImage {
    public convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
}

extension UIColor {
    var coreImageColor: CIColor {
        return CIColor(color: self)
    }
    var components: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        let coreImageColor = self.coreImageColor
        return (coreImageColor.red, coreImageColor.green, coreImageColor.blue, coreImageColor.alpha)
    }
    
    func toHexString() -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        
        return String(format:"#%06x", rgb)
    }
}

extension String {
    var hexColor: UIColor {
        let hex = trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.characters.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            return .clear
        }
        return UIColor(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate,
    UINavigationControllerDelegate
 {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imageView: UIImageView!
    
    var colorPicker : DBImageColorPicker = DBImageColorPicker.init()
    
    var isRgb = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.backgroundColor = UIColor.clear
        
        self.colorPicker = DBImageColorPicker.init(from: self.imageView.image, with: .default)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // MARK: - Table View
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell.init(style: .value1, reuseIdentifier: "")
        
        if(indexPath.row == 0){
            
            let primaryColor = colorPicker.primaryTextColor
            cell.textLabel?.text = "Primary text"
            cell.imageView?.image = UIImage.init(color: primaryColor!, size: CGSize.init(width: 15, height: 15))
            
//            if(isRgb){
//                
//                
//                if let primaryColorComponents = primaryColor?.components {
//                    
//                    cell.detailTextLabel?.text = "\(primaryColorComponents.red * 255.0), \(primaryColorComponents.green * 255.0), \(primaryColorComponents.blue * 255.0)"
//
//                }
//                
//            }else{
//                
//                cell.detailTextLabel?.text = primaryColor?.toHexString()
//            }
//            
        }else if(indexPath.row == 1){
            
            let secondaryColor = colorPicker.secondaryTextColor
            cell.textLabel?.text = "Secondary text"
            cell.imageView?.image = UIImage.init(color: secondaryColor!, size: CGSize.init(width: 15, height: 15))

//            if(isRgb){
//                
//                if let secondaryColorComponents = secondaryColor?.components {
//                    
//                    cell.detailTextLabel?.text = "\(secondaryColorComponents.red * 255.0), \(secondaryColorComponents.green * 255.0), \(secondaryColorComponents.blue * 255.0)"
//                    
//                }
//
//            }else{
//                
//                cell.detailTextLabel?.text =  secondaryColor?.toHexString()
//
//            }
            
        }else{
            
            let backgroundColor = colorPicker.backgroundColor
            cell.textLabel?.text = "Background"
            cell.imageView?.image = UIImage.init(color: backgroundColor!, size: CGSize.init(width: 15, height: 15))
//
//            if(isRgb){
//
//                if let backgroundColorComponents = backgroundColor?.components {
//                    
//                    cell.detailTextLabel?.text = "\(backgroundColorComponents.red * 255.0), \(backgroundColorComponents.green * 255.0), \(backgroundColorComponents.blue * 255.0)"
//                    
//                }
//
//            
//            }else{
//                
//                cell.detailTextLabel?.text =  backgroundColor?.toHexString()
//            }
//            
        }
        
        return cell
    }
    
    
    @IBAction func onRgbButton(_ sender: Any) {
        
        self.isRgb = !self.isRgb
        self.tableView.reloadData()
        
    }

    
    @IBAction func onCameraButton(_ sender: Any) {
        
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera;
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion:nil)
        }
        
    }

    @IBAction func onAlbumButton(_ sender: Any) {
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary;
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {

        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.imageView.contentMode = .scaleToFill
            self.imageView.image = pickedImage
            
            self.colorPicker = DBImageColorPicker.init(from: self.imageView.image, with: .default)
            self.tableView.reloadData()
        }
        
        picker.dismiss(animated: true, completion: nil)
        
    }
    
    
}

