//
//  UMDetViewController.swift
//  MyApp7
//
//  Created by Muhammad Bilal on 24/09/2017.
//  Copyright © 2017 Herdmaps. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Toast_Swift
import Popover

class UMDetViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var umid: String = "0";
    var uTitle: String = "";
    var uDetails: String = "";
    var uChecked: String = "";
    
    var mylat:  String = "0.0";
    var mylng:  String = "0.0";
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var myCheckedIn: UILabel!

    var myPeopleArray = [person]();
    
    override func viewDidLoad() {
        super.viewDidLoad()

        myCheckedIn.text = uChecked;
        
        tableView.delegate = self
        tableView.dataSource = self
        
        populateUserMarker();
    }

    @IBAction func btnInfo(_ sender: Any) {
        let aView =  UINib(nibName: "UMInfoView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UMInfoView;
        let popover = Popover(options: nil, showHandler: nil, dismissHandler: nil);
        aView.myTitle.text = uTitle;
        aView.myDetails.text = uDetails;
        popover.showAsDialog(aView)
    }
    
    
    @IBAction func btnCheckIn(_ sender: Any) {
        if (UserDefaults.standard.string(forKey: "uid") != nil) {
            if (myUtils.isConnectedToNetwork()) {
                let params: [String: String] = [
                    "checkInBusiness":  "1",
                    "bid":              umid,
                    "uid":              UserDefaults.standard.string(forKey: "uid")!,
                    "lat":              mylat,
                    "lng":              mylng
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
                                self.view.makeToast("You have successfully Checked In");
                                self.view.makeToast("Refreshing");
                                self.populateUserMarker();
                            }
                        }
                    });
                
            } else {
                self.view.makeToast("Please Check Your Internet Connection")
            }
        } else {
            self.view.makeToast("You need to be Logged In");
        }
    }
    
    
    @IBAction func btnRefresh(_ sender: Any) {
        self.view.makeToast("Refreshing");
        populateUserMarker();
    }
    
    func populateUserMarker() {
        if (myUtils.isConnectedToNetwork()) {
            let params: [String: String] = [
                "peopleCheckedIn":  "1",
                "bid":              umid
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
                            
                            let myPeopleArrayGet = json["user"]
                            
                            for (_, object) in myPeopleArrayGet {
                                let mPerson = person();
                                mPerson.name    = object["name"].string!;
                                mPerson.time    = object["date"].string!;
                                mPerson.pic     = object["profile"].string!;
                                
                                self.myPeopleArray.append(mPerson);
                            }
                            
                            self.tableView.reloadData();
                        }
                    }
                });
            
        } else {
            self.view.makeToast("Please Check Your Internet Connection")
        }
    }
    
    @available(iOS 2.0, *)
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UserCheckedInTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "cell") as! UserCheckedInTableViewCell;
        
        cell.myName.text = self.myPeopleArray[indexPath.row].name;
        cell.myTime.text = self.myPeopleArray[indexPath.row].time;
        
        cell.myPicture.imageFromServerURL(urlString: self.myPeopleArray[indexPath.row].pic);
        
        return cell;
    }
    
    @available(iOS 2.0, *)
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.myPeopleArray.count;
    }
    
    class person {
        var name: String    = "";
        var time: String    = "";
        var pic: String     = "";
    }
}
