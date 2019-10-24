//
//  ReviewsViewController.swift
//  MyApp7
//
//  Created by Muhammad Bilal on 23/09/2017.
//  Copyright © 2017 Herdmaps. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Toast_Swift
import SDWebImage

class ReviewsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var bid: String = "0";
    
    @IBOutlet weak var tableView: UITableView!

    var myReviewsArray = [myReview]();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        popReviews();
    }

    func popReviews() {
        if (myUtils.isConnectedToNetwork()) {
            let params: [String: String] = [
                "getReviews":  "1",
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
                                
                                let myReviewsArrayGet = json["reviews"]
                                
                                for (_, object) in myReviewsArrayGet {
                                    let mReview = myReview();
                                    mReview.rating      = object["rating"].string!;
                                    mReview.name        = object["name"].string!;
                                    mReview.time        = object["time"].string!;
                                    mReview.details     = object["details"].string!;
                                    mReview.profile     = object["profile"].string!;
                                    
                                    self.myReviewsArray.append(mReview);
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
        let cell:CustomReviewCell = self.tableView.dequeueReusableCell(withIdentifier: "cell") as! CustomReviewCell
        cell.myName.text        = self.myReviewsArray[indexPath.row].name;
        cell.myDetails.text     = self.myReviewsArray[indexPath.row].details;
        cell.myRating.rating    = Double(self.myReviewsArray[indexPath.row].rating)!;
        
        let myURL = URL(string: self.myReviewsArray[indexPath.row].profile);
        cell.myImageView.sd_setImage(with: myURL, completed: nil);
        return cell
    }
    
    @available(iOS 2.0, *)
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.myReviewsArray.count;
    }
    
    class myReview {
        var name:       String = "";
        var rating:     String = "";
        var details:    String = "";
        var time:       String = "";
        var profile:    String = "";
    }
    
}
