//
//  NewsDetailsViewController.swift
//  MyApp7
//
//  Created by Muhammad Bilal on 25/09/2017.
//  Copyright © 2017 Herdmaps. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Toast_Swift

class NewsDetailsViewController: UIViewController {

    @IBOutlet weak var myWebView: UIWebView!
    
    var nid: String = "0";
    var myTitle: String = "0";
    
    override func viewDidLoad() {
        super.viewDidLoad();
        populateNews(nid: nid);
        
        self.title = myTitle;
    }
    
    func populateNews(nid: String) {
        if (myUtils.isConnectedToNetwork()) {
            let params: [String: String] = [
                "getNewsDetails":        "1",
                "nid":                   nid
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
                            self.myWebView.loadHTMLString(json["details"].rawString()!, baseURL: nil);
                        }
                    }
                });
        } else {
            self.view.makeToast("Please Check Your Internet Connection")
        }
    }


}
