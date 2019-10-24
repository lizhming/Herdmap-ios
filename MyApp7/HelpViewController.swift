//
//  HelpViewController.swift
//  MyApp7
//
//  Created by Muhammad Bilal on 24/09/2017.
//  Copyright © 2017 Herdmaps. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Toast_Swift

class HelpViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var myFAQArray = [myFAQs]();
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        populateFAQs();
    }

    func populateFAQs() {
        if (myUtils.isConnectedToNetwork()) {
            let params: [String: String] = [
                "getFAQs":  "1"
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
                            if (json["results"].number != 0) {
                                
                                let myCouponsArrayGet = json["faqs"]
                                
                                for (_, object) in myCouponsArrayGet {
                                    let bNews = myFAQs();
                                    bNews.id    = object["id"].string!;
                                    bNews.name  = object["name"].string!;
                                    bNews.type  = object["tname"].string!;
                                    
                                    self.myFAQArray.append(bNews);
                                }
                                
                                self.tableView.reloadData();
                                
                            }
                        }
                    }
                });
            
        } else {
            self.view.makeToast("Please Check Your Internet Connection")
        }
    }
    
    @available(iOS 2.0, *)
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:MyFAQTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "cell") as! MyFAQTableViewCell
        cell.myTitle.text           = self.myFAQArray[indexPath.row].name;
        cell.myType.text            = self.myFAQArray[indexPath.row].type;
        return cell
    }
    
    @available(iOS 2.0, *)
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.myFAQArray.count
    }

    class myFAQs {
        var id:     String = "";
        var name:   String = "";
        var type:   String = "";
    }
    
}
