//
//  FriendsListViewController.swift
//  MyApp7
//
//  Created by Muhammad Bilal on 24/09/2017.
//  Copyright © 2017 Herdmaps. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Toast_Swift

class FriendsListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var myPeopleArray = [person]();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        populateFriends();
    }
    
    @IBAction func btnAddFriend(_ sender: Any) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "FriendSearchViewController") as! FriendSearchViewController
        self.present(newViewController, animated: true, completion: nil)
    }
    
    func populateFriends() {
        if (myUtils.isConnectedToNetwork()) {
            let params: [String: String] = [
                "popMyFriends":     "1",
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
                            
                            let myPeopleArrayGet = json["users"]
                            
                            for (_, object) in myPeopleArrayGet {
                                let mPerson         = person();
                                mPerson.name        = object["name"].string!;
                                mPerson.image       = object["profile"].string!;
                                mPerson.status      = object["approved"].rawString()!;
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
        let cell:FListTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "cell") as! FListTableViewCell;
        
        cell.myName.text = myPeopleArray[indexPath.row].name;
        cell.myImage.downloadedFrom(link: myPeopleArray[indexPath.row].image);
        
        if (Int(myPeopleArray[indexPath.row].status) == 1) {
            cell.myStatus.text = "Approved";
            cell.myStatus.textColor = UIColor.green;
        }
        
        return cell;

    }
    
    @available(iOS 2.0, *)
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myPeopleArray.count;
    }
    
    class person {
        var name: String = "";
        var image: String = "";
        var status: String = "";
    }

}
