//
//  Barcode.swift
//  MyApp7
//
//  Created by Muhammad Bilal on 25/09/2017.
//  Copyright © 2017 Herdmaps. All rights reserved.
//

import Foundation
import CoreImage
import UIKit

class Barcode {
    
    class func fromString(string : String) -> UIImage? {
        
        let data = string.data(using: .ascii)
        let filter = CIFilter(name: "CICode128BarcodeGenerator")
        filter?.setValue(data, forKey: "inputMessage")
        
        return UIImage(ciImage: (filter?.outputImage)!)
    }
    
}
