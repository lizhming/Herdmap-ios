//
//  FriendSearchViewController.swift
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

class FriendSearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    var myPeopleArray = [person]();
    
    let aView =  UINib(nibName: "AddFriendDialog", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! AddFriendDialog;
    let popover = Popover(options: nil, showHandler: nil, dismissHandler: nil);
    
    var selectedFriend: String = "0";
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }

    @IBAction func btnSearch(_ sender: Any) {
        populateList(name: txtSearch.text!);
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedFriend = myPeopleArray[indexPath.row].id;
        
        aView.friendText.text = "Would you like to send " + myPeopleArray[indexPath.row].name + " a friend request?";
        
        aView.btnAddFriend.addTarget(
            self,
            action: #selector(actionAddFriend),
            for: .touchUpInside);
        
        aView.btnDismiss.addTarget(
            self,
            action: #selector(actionDismiss),
            for: .touchUpInside);
        
        popover.showAsDialog(aView);
    }
    
    func actionDismiss() {
        popover.dismiss();
    }
    
    func actionAddFriend() {
        if (myUtils.isConnectedToNetwork()) {
            let params: [String: String] = [
                "addFriend":        "1",
                "fid":              selectedFriend,
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
                            self.popover.dismiss();
                        }
                    }
                });
            
        } else {
            self.view.makeToast("Please Check Your Internet Connection")
        }
    }
    
    func populateList(name: String) {
        if (myUtils.isConnectedToNetwork()) {
            let params: [String: String] = [
                "searchFriends":     "1",
                "name":              name
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
                            
                            let myUsersArrayGet = json["users"]
                            
                            for (_, object) in myUsersArrayGet {
                                let mPerson         = person();
                                mPerson.id          = object["id"].string!;
                                mPerson.name        = object["name"].string!;
                                mPerson.time        = object["time"].string!;
                                mPerson.image       = object["profile"].string!;
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
        let cell:FriendSearchTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "cell") as! FriendSearchTableViewCell;
        
        cell.myName.text = myPeopleArray[indexPath.row].name;
        cell.myTime.text = myPeopleArray[indexPath.row].time;
        
        cell.myImage.downloadedFrom(link: myPeopleArray[indexPath.row].image);
        return cell;
    }
    
    @available(iOS 2.0, *)
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myPeopleArray.count;
    }
    
    class person  {
        var id: String = "";
        var name: String = "";
        var image: String = "";
        var time: String = "";
    }
    
}
