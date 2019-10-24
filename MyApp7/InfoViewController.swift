//
//  InfoViewController.swift
//  MyApp7
//
//  Created by Muhammad Bilal on 23/09/2017.
//  Copyright © 2017 Herdmaps. All rights reserved.
//

import UIKit
import Toast_Swift
import Alamofire
import SwiftyJSON

class InfoViewController: UIViewController {

    var bid: String     = "0";
    
    var bPhone: String  = "0";
    var bLat: String    = "0";
    var bLng: String    = "0";
    var bWeb: String    = "0";
    
    @IBOutlet weak var myWebView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myWebView.loadHTMLString("Please Wait Loading...", baseURL: nil)
        populateData();
    }

    func populateData() {
        if (myUtils.isConnectedToNetwork()) {
            let params: [String: String] = [
                "getBusinessDetails":  "1",
                "bid":                  bid
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
                            let myBusDetails = json["details"].string;
                            self.myWebView.loadHTMLString(myBusDetails!, baseURL: nil)
                            
                            self.bPhone = json["phone"].string!;
                            
                            self.bLat = json["lat"].string!;
                            self.bLng = json["lat"].string!;
                            
                            self.bWeb = json["web"].string!;
                        }
                    }
                });
            
        } else {
            self.view.makeToast("Please Check Your Internet Connection")
        }
    }
    
    @IBAction func btnWeb(_ sender: Any) {
        let url = URL(string: bWeb)!
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            //If you want handle the completion block than
            UIApplication.shared.open(url, options: [:], completionHandler: { (success) in
                print("Open url : \(success)")
            })
        }
    }
    
    @IBAction func btnCall(_ sender: Any) {
        if let url = URL(string: "tel:\(bPhone)"), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    @IBAction func getDirectionButton(_ sender: Any) {
        self.view.makeToast("Opening Location")
        if (UIApplication.shared.canOpenURL(NSURL(string:"comgooglemaps://")! as URL)) {
            //UIApplication.shared.openURL(NSURL(string: "comgooglemaps://?saddr=&daddr=\(bLat),\(bLng)&directionsmode=driving")! as URL)
            UIApplication.shared.open(NSURL(string: "comgooglemaps://?saddr=&daddr=\(bLat),\(bLng)&directionsmode=driving")! as URL, options: [:], completionHandler: nil)
        } else {
            NSLog("Can't use comgooglemaps://");
        }
        
    }

}
