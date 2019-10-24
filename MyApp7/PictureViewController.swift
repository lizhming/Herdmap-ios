//
//  PictureViewController.swift
//  MyApp7
//
//  Created by Muhammad Bilal on 25/09/2017.
//  Copyright © 2017 Herdmaps. All rights reserved.
//

import UIKit
import Fusuma
import Alamofire
import SwiftyJSON
import Toast_Swift

class PictureViewController: UIViewController, FusumaDelegate {

    @IBOutlet weak var mySelectedImage: UIImageView!
    @IBOutlet weak var btnSave: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.btnSave.isHidden = true;
        
        btnSave.addTarget(
            self,
            action: #selector(actionUploadImage),
            for: .touchUpInside);
        
    }
    
    func actionUploadImage() {
        
        //print(mySelectedImage.image?.sd_imageData()?.fileExtension);
        //print(mySelectedImage.image?.sd_imageData()?.base64EncodedString());
        
        let b64String: String = (mySelectedImage.image?.sd_imageData()?.base64EncodedString())!;
        
        if (myUtils.isConnectedToNetwork()) {
            let params: [String: String] = [
                "uploadProfilePicture":     "1",
                "imgstring":                b64String,
                "uid":                      UserDefaults.standard.string(forKey: "uid")!
            ];
            
            Alamofire.request(
                myUtils.APIURL,
                method: .post,
                parameters: params,
                encoding: URLEncoding.default,
                headers: nil)
                .validate(statusCode: 200..<600)
                .responseJSON(completionHandler: { (response) in
                    if (response.result.value != nil) {
                        let json = JSON(response.result.value!);
                        
                        if (json["success"].number == 1) {
                            NotificationCenter.default.post(name: Notification.Name(rawValue: "newPicture"), object: nil);
                            self.navigationController?.popToRootViewController(animated: true);
                        }
                    }
                });
            
        } else {
            self.view.makeToast("Please Check Your Internet Connection")
        }
        
    }


    @IBAction func btnTakePic(_ sender: Any) {
        print("Taking Pic")
        let fusuma = FusumaViewController()
        fusuma.delegate = self
        fusuma.allowMultipleSelection = false // You can select multiple photos from the camera roll. The default value is false.
        self.present(fusuma, animated: true, completion: nil)
    }

    
    //Delegates
    func fusumaCameraRollUnauthorized() {
        print("Camera roll unauthorized")
        
        let alert = UIAlertController(title: "Access Requested",
                                      message: "Saving image needs to access your photo album",
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Settings", style: .default) { (action) -> Void in
            
            if let url = URL(string:UIApplicationOpenSettingsURLString) {
                
                //UIApplication.shared.openURL(url);
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                
            }
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
            
        })
        
        guard let vc = UIApplication.shared.delegate?.window??.rootViewController,
            let presented = vc.presentedViewController else {
                
                return
        }
        
        presented.present(alert, animated: true, completion: nil)
    }
    
    func fusumaVideoCompleted(withFileURL fileURL: URL) {
        
    }
    
    func fusumaMultipleImageSelected(_ images: [UIImage], source: FusumaMode) {
        
    }
    
    func fusumaImageSelected(_ image: UIImage, source: FusumaMode) {
        mySelectedImage.image = image;
        self.btnSave.isHidden = false;
    }
    
}
