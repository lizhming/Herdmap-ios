//
//  CategoryViewController.swift
//  MyApp7
//
//  Created by Muhammad Bilal on 23/09/2017.
//  Copyright © 2017 Herdmaps. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Toast_Swift

class CategoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {


    @IBOutlet weak var tableView: UITableView!
    
    var myCategoryArray = [category]();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.title = "Select Category";
        
        populateCats();
    }

    func populateCats() {
        if (myUtils.isConnectedToNetwork()) {
            
            let params: [String: String] = [
                "getCategories":  "1"
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
                            
                            let myCouponsArrayGet = json["cats"]
                            
                            for (_, object) in myCouponsArrayGet {
                                let bCat    = category();
                                bCat.id     = object["id"].string!;
                                bCat.name   = object["name"].string!;
                                
                                self.myCategoryArray.append(bCat);
                            }
                            
                            self.tableView.reloadData();
                            
                        }
                    }
                });
            
        } else {
            self.view.makeToast("Please Check Your Internet Connection")
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let myDict = [ "id": myCategoryArray[indexPath.row].id, "name": myCategoryArray[indexPath.row].name];
        NotificationCenter.default.post(name: Notification.Name(rawValue: "selectedCategory"), object: myDict);
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @available(iOS 2.0, *)
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:MyCatListTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "cell") as! MyCatListTableViewCell
        cell.myTitle.text   = self.myCategoryArray[indexPath.row].name;
        return cell
    }
    
    @available(iOS 2.0, *)
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.myCategoryArray.count;
    }
    
    class category {
        var id:     String = "";
        var name:   String = "";
    }
    

}
