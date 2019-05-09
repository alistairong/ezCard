//
//  QRCodeViewController.swift
//  ezCard
//
//  Created by Andrew Whitehead on 3/6/19.
//  Copyright © 2019 Andrew Whitehead. All rights reserved.
//

import UIKit

class QRCodeViewController: UIViewController {
    
    // Put the generated QR code into an ImageView
    @IBOutlet weak var imageView: UIImageView! {
        didSet {
            let qrData = GlobalConstants.QR_UUID + " " + card.identifier + " " + UUID().uuidString
            imageView.image = generateQRCode(with: qrData)!
        }
    }
    
    var card: Card!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title =  card.name
    }
    
    /// Generate the QR code based on the card id
    // Source: https://www.hackingwithswift.com/example-code/media/how-to-create-a-qr-code
    func generateQRCode(with string: String, scale: (x: CGFloat, y: CGFloat) = (3, 3)) -> UIImage? {
        let data = string.data(using: String.Encoding.isoLatin1, allowLossyConversion: false)
        
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: scale.x, y: scale.y)
            
            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }
        
        return nil
    }
    
}
