//
//  MyUserMarkersViewController.swift
//  MyApp7
//
//  Created by Muhammad Bilal on 24/09/2017.
//  Copyright © 2017 Herdmaps. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Toast_Swift

class MyUserMarkersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet weak var myNumMarkers: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var myMarkersArray = [marker]();
    
    override func viewDidLoad() {
        super.viewDidLoad();
        tableView.delegate = self
        tableView.dataSource = self
        populateUserMarkers();
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "UMDetViewController") as! UMDetViewController
        
        newViewController.umid = myMarkersArray[indexPath.row].id;
        newViewController.uTitle = myMarkersArray[indexPath.row].name;
        newViewController.uDetails = myMarkersArray[indexPath.row].details;
        newViewController.uChecked = myMarkersArray[indexPath.row].checkedIn;
        
        self.navigationController?.pushViewController(newViewController, animated: true)
    }
    
    func populateUserMarkers() {
        if (myUtils.isConnectedToNetwork()) {
            let params: [String: String] = [
                "getUserMarkers":  "1",
                "uid":              UserDefaults.standard.string(forKey: "uid")!
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
                            
                            let myMarkersGet = json["umarkers"]
                            
                            for (_, object) in myMarkersGet {
                                let mMarker     = marker();
                                mMarker.id          = object["id"].string!;
                                mMarker.name        = object["name"].string!;
                                mMarker.time        = object["date"].string!;
                                mMarker.location    = object["lat"].string! + ", " + object["lng"].string!;
                                mMarker.details     = object["details"].string!;
                                mMarker.checkedIn   = object["checkedin"].rawString()!;
                                
                                self.myMarkersArray.append(mMarker);
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
        let cell:UMListTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "cell") as! UMListTableViewCell;
        
        cell.myTitle.text = myMarkersArray[indexPath.row].name;
        cell.myTime.text = myMarkersArray[indexPath.row].time;
        cell.myLocation.text = myMarkersArray[indexPath.row].location;
        
        return cell;
    }
    
    @available(iOS 2.0, *)
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myMarkersArray.count;
    }

    class marker {
        var id: String = "";
        var name: String = "";
        var time: String = "";
        var location: String = "";
        var details: String = "";
        var checkedIn: String = "";
    }
    
}
