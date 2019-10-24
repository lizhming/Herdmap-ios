//
//  ImageZoomViewController.swift
//  MyPhotoGalleryApp1
//
//  Created by Muhammad Bilal on 21/09/2017.
//  Copyright © 2017 Muhammad Bilal. All rights reserved.
//

import UIKit
import ImageScrollView

class ImageZoomViewController: UIViewController {

    
    var imageURL: String = "";
    
    @IBOutlet weak var imageScrollView: ImageScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let url = URL(string: imageURL)
        let data = try? Data(contentsOf: url!)
        let myImage = UIImage(data: data!)
        
        imageScrollView.display(image: myImage!)
    }
    
    @IBAction func goBackButton(_ sender: Any) {
        print("Go Back")
        self.dismiss(animated: true, completion: nil)
    }

}
