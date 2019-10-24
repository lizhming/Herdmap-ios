//
//  MySubsViewController.swift
//  MyApp7
//
//  Created by Muhammad Bilal on 24/09/2017.
//  Copyright © 2017 Herdmaps. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Toast_Swift

class MySubsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet weak var numSubs: UILabel!
    @IBOutlet weak var tableView: UITableView!
    var mySubsArray = [mySubs]();
    
    override func viewDidLoad() {
        super.viewDidLoad();
        tableView.delegate = self
        tableView.dataSource = self
        populateSubs();
    }
    
    @available(iOS 2.0, *)
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:SubsTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "cell") as! SubsTableViewCell;
        
        cell.myTitle.text = mySubsArray[indexPath.row].title;
        cell.myTime.text = mySubsArray[indexPath.row].time;
        
        cell.myImage.downloadedFrom(link: mySubsArray[indexPath.row].logo);
        
        return cell;
    }
    
    func populateSubs() {
        if (myUtils.isConnectedToNetwork()) {
            let params: [String: String] = [
                "getUserSubscriptions":     "1",
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
                            
                            let myMarkersGet = json["bus"]
                            
                            for (_, object) in myMarkersGet {
                                let mSub            = mySubs();
                                mSub.title          = object["name"].string!;
                                mSub.time           = object["date"].string!;
                                mSub.logo           = object["logo"].string!;
                                self.mySubsArray.append(mSub);
                            }
                            
                            self.numSubs.text = "You have " + json["numsubs"].rawString()! + " Subscriptions";
                            
                            self.tableView.reloadData();
                        }
                    }
                });
            
        } else {
            self.view.makeToast("Please Check Your Internet Connection")
        }
    }
    
    @available(iOS 2.0, *)
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mySubsArray.count;
    }


    class mySubs {
        var title:  String = "";
        var time:   String = "";
        var logo:   String = "";
    }

}
