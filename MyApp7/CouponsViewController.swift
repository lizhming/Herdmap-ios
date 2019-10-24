//
//  CouponsViewController.swift
//  MyApp7
//
//  Created by Muhammad Bilal on 23/09/2017.
//  Copyright © 2017 Herdmaps. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Toast_Swift

class CouponsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var bid: String = "0";
    var myCouponsArray = [myCoupon]();
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        populateCoupons();
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "CouponDetailsViewController") as! CouponDetailsViewController
        
        newViewController.cid = myCouponsArray[indexPath.row].id;
        newViewController.myTitle = myCouponsArray[indexPath.row].name;
        
        self.present(newViewController, animated: true, completion: nil)
    }

    func populateCoupons() {
        if (myUtils.isConnectedToNetwork()) {
            let params: [String: String] = [
                "getCoupons":  "1",
                "bid":          bid
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
                                
                                let myCouponsArrayGet = json["coupons"]
                                
                                for (_, object) in myCouponsArrayGet {
                                    let bCoupon = myCoupon();
                                    bCoupon.id = object["id"].string!;
                                    bCoupon.name = object["name"].string!;
                                    bCoupon.status = object["active"].string!;
                                    
                                    self.myCouponsArray.append(bCoupon);
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
        let cell:CustomCouponCell = self.tableView.dequeueReusableCell(withIdentifier: "cell") as! CustomCouponCell
        cell.myTitle.text = self.myCouponsArray[indexPath.row].name;
        if (Int(self.myCouponsArray[indexPath.row].status) == 1) {
            cell.myStatus.text = "Available";
            cell.myStatus.textColor = UIColor.green;
        }
        return cell
    }
    
    @available(iOS 2.0, *)
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.myCouponsArray.count;
    }
    

    class myCoupon {
        var id:     String = "";
        var name:   String = "";
        var status: String = "";
    }
    
}
