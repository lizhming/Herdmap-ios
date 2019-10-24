//
//  NewsViewController.swift
//  MyApp7
//
//  Created by Muhammad Bilal on 23/09/2017.
//  Copyright © 2017 Herdmaps. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Toast_Swift

class NewsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var bid: String = "0";
    var myNewsArray = [myNews]();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self;
        tableView.dataSource = self;
        populateNews();
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "NewsDetailsViewController") as! NewsDetailsViewController
        
        newViewController.nid = myNewsArray[indexPath.row].id;
        newViewController.myTitle = myNewsArray[indexPath.row].name;
        
        self.present(newViewController, animated: true, completion: nil)
    }
    
    func populateNews() {
        if (myUtils.isConnectedToNetwork()) {
            let params: [String: String] = [
                "getNews":  "1",
                "bid":      bid
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
                                
                                let myCouponsArrayGet = json["news"]
                                
                                for (_, object) in myCouponsArrayGet {
                                    let bNews = myNews();
                                    bNews.id    = object["id"].string!;
                                    bNews.name  = object["name"].string!;
                                    bNews.date  = object["time"].string!;
                                    
                                    self.myNewsArray.append(bNews);
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
        let cell:CustomNewsCell = self.tableView.dequeueReusableCell(withIdentifier: "cell") as! CustomNewsCell
        cell.myTitle.text   = self.myNewsArray[indexPath.row].name;
        cell.myDate.text    = self.myNewsArray[indexPath.row].date;
        return cell
    }
    
    @available(iOS 2.0, *)
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.myNewsArray.count
    }

    class myNews {
        var id:     String = "";
        var name:   String = "";
        var date:   String = "";
    }
    
}
