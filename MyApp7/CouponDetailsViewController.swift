//
//  CouponDetailsViewController.swift
//  MyApp7
//
//  Created by Muhammad Bilal on 25/09/2017.
//  Copyright © 2017 Herdmaps. All rights reserved.
//

import UIKit
import TGCircularTimerView;
import Alamofire
import SwiftyJSON
import Toast_Swift
import Material

class CouponDetailsViewController: UIViewController, TGCircularTimerViewDelegate {

    @IBOutlet weak var myBarcadeImage: UIImageView!
    @IBOutlet weak var myTimer: TGCircularTimerView!
    @IBOutlet weak var lblBarcode: UILabel!
    @IBOutlet weak var myRedeemButton: FlatButton!
    
    var cid: String = "0";
    var myTitle: String = "";
    
    override func viewDidLoad() {
        super.viewDidLoad()

        myRedeemButton.addTarget(
            self,
            action: #selector(actionRedeem),
            for: .touchUpInside);
        
        self.title = myTitle;
    }
    
    func actionRedeem() {
        if (myUtils.isConnectedToNetwork()) {
            let params: [String: String] = [
                "activateCoupon":     "1",
                "tid":                cid,
                "uid":                UserDefaults.standard.string(forKey: "uid")!
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
                            let myBarcode = json["barcode"].rawString();
                            self.myBarcadeImage.image = Barcode.fromString(string: myBarcode!);
                            
                            self.lblBarcode.text = myBarcode;
                            
                            self.myRedeemButton.isHidden = true;
                            
                            self.myTimer.start();
                            
                        }
                    }
                });
            
        } else {
            self.view.makeToast("Please Check Your Internet Connection")
        }
    }

    /*
    @IBAction func btnRedeem(_ sender: Any) {
        //let img = Barcode.fromString(string: "1011");
        //myBarcadeImage.image = img;
        
        if (myUtils.isConnectedToNetwork()) {
            let params: [String: String] = [
                "activateCoupon":     "1",
                "tid":                cid,
                "uid":                UserDefaults.standard.string(forKey: "uid")!
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
                            let myBarcode = json["barcode"].rawString();
                            self.myBarcadeImage.image = Barcode.fromString(string: myBarcode!);
                            
                            self.myTimer.start();
                            
                        }
                    }
                });
            
        } else {
            self.view.makeToast("Please Check Your Internet Connection")
        }
    }
    */
    
    
}
