import UIKit
import Pager
import SwiftHEXColors

import Alamofire
import SwiftyJSON
import Toast_Swift
import SDWebImage

import Popover

class BusViewController: PagerController, PagerDataSource {

    var bid:    String = "0";
    var mylat:  String = "0.0";
    var mylng:  String = "0.0";
    
    @IBOutlet weak var myBusName: UILabel!
    @IBOutlet weak var myBusCategory: UILabel!
    @IBOutlet weak var myBusAddress: UILabel!
    @IBOutlet weak var myBusCityState: UILabel!
    @IBOutlet weak var myBusContact: UILabel!
    
    @IBOutlet weak var myBusCheckedIn: UILabel!
    @IBOutlet weak var myBusSubs: UILabel!
    @IBOutlet weak var myBusLogo: UIImageView!
    
    //Rating Dialog
    let aView =  UINib(nibName: "BusDetailsRatingUIView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! BusDetailsRatingUIView;
    let popover = Popover(options: nil, showHandler: nil, dismissHandler: nil);
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        
        //Init Storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let tabCoupons  = storyboard.instantiateViewController(withIdentifier: "CouponsViewController") as! CouponsViewController
        let tabNews     = storyboard.instantiateViewController(withIdentifier: "NewsViewController")    as! NewsViewController
        let tabGallery  = storyboard.instantiateViewController(withIdentifier: "GalleryViewController") as! GalleryViewController
        let tabInfo     = storyboard.instantiateViewController(withIdentifier: "InfoViewController")    as! InfoViewController
        let tabReviews  = storyboard.instantiateViewController(withIdentifier: "ReviewsViewController") as! ReviewsViewController
        
        self.setupPager(
            tabNames: ["Coupons", "News", "Gallery", "Info", "Reviews"],
            tabControllers: [tabCoupons, tabNews, tabGallery, tabInfo, tabReviews]);
        
        //Tab Settings
        tabsViewBackgroundColor = UIColor(hexString: "#479631")!;
        indicatorColor = UIColor(hexString: "#8ADD81")!;
        tabTopOffset = 124;
        
        tabCoupons.bid  = bid;
        tabNews.bid     = bid;
        tabGallery.bid  = bid;
        tabInfo.bid     = bid;
        tabReviews.bid  = bid;
        
        //Populate Details
        populateDetails(businessID: bid);
    }

    //NAVBAR BUTTONS
    @IBAction func myRatingButton(_ sender: Any) {
        popover.showAsDialog(aView)
        aView.myBusPostReview.addTarget(
            self,
            action: #selector(actionPostReview),
            for: .touchUpInside)
        
    }
    
    //Post Rating Reivew
    func actionPostReview() {
        if (UserDefaults.standard.string(forKey: "uid") != nil) {
            if (myUtils.isConnectedToNetwork()) {
                let params: [String: String] = [
                    "postBusinessReview":  "1",
                    "rating":           String(aView.myBusRating.rating),
                    "review":           aView.myReviewText.text,
                    "uid":              UserDefaults.standard.string(forKey: "uid")!,
                    "bid":              bid
                    
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
                                self.view.makeToast("Review Successfully Posted");
                                self.popover.dismiss();
                            } else {
                                self.view.makeToast("Your Review already Exists")
                            }
                        }
                    });
                
            } else {
                self.view.makeToast("Please Check Your Internet Connection")
            }
        } else {
            self.view.makeToast("You need to be logged in");
        }
    }
    
    
    //Subscribe
    @IBAction func btnSubscribe(_ sender: Any) {
        if (UserDefaults.standard.string(forKey: "uid") != nil) {
            if (myUtils.isConnectedToNetwork()) {
                let params: [String: String] = [
                    "subsribeToBusiness":  "1",
                    "uid":              UserDefaults.standard.string(forKey: "uid")!,
                    "bid":              bid
                    
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
                                self.view.makeToast("Successfully Subscribed!")
                                print("Trying to Refresh");
                                self.viewDidLoad()
                                self.viewWillAppear(true)
                            } else {
                                self.view.makeToast("Check Back Later, Something Went Wrong")
                            }
                        }
                    });
                
            } else {
                self.view.makeToast("Please Check Your Internet Connection")
            }
        } else {
            self.view.makeToast("You need to be logged in");
        }
    }
    
    //Check-In
    @IBAction func btnCheckIn(_ sender: Any) {
        if (UserDefaults.standard.string(forKey: "uid") != nil) {
            if (myUtils.isConnectedToNetwork()) {
                let params: [String: String] = [
                    "checkInBusiness":  "1",
                    "lat":              mylat,
                    "lng":              mylng,
                    "uid":              UserDefaults.standard.string(forKey: "uid")!,
                    "bid":              bid
                    
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
                            
                            switch (Int(json["success"].number!)) {
                            case 0:
                                self.view.makeToast("Check Back Later, Something Went Wrong")
                                break;
                            case 1:
                                self.view.makeToast("You have Successfully Chedk In");
                                break;
                            case 2:
                                self.view.makeToast("Your already Checked In");
                                break;
                            case 3:
                                self.view.makeToast("You`re out of Range")
                                break;
                            default:
                                break;
                            }
                        }
                    });
                
            } else {
                self.view.makeToast("Please Check Your Internet Connection")
            }
        } else {
            self.view.makeToast("You need to be logged in");
        }
    }
    
    //Populate Details
    func populateDetails(businessID: String) {
        if (myUtils.isConnectedToNetwork()) {
            
            let params: [String: String] = [
                "getMarkerBusDetails":  "1",
                "bid":          businessID
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
                            self.myBusName.text         = json["bus_name"].string!;
                            self.myBusCategory.text     = json["bus_cat"].string!;
                            self.myBusAddress.text      = json["bus_address"].string!;
                            self.myBusCityState.text    = json["bus_city"].string! + ", " + json["bus_state"].string! + ", " + json["bus_country"].string!;
                            self.myBusContact.text      = json["bus_phone"].string!;
                            self.myBusCheckedIn.text    = json["bus_checked"].rawString();
                            self.myBusSubs.text         = json["bus_sub"].rawString()! + " subscribers";
                            
                            self.title = json["bus_name"].string!
                            
                            let myURL = URL(string: json["bus_logo"].string!);
                            self.myBusLogo.sd_setImage(with: myURL, completed: nil);
                            
                        }
                    }
                });
            
        } else {
            self.view.makeToast("Please Check Your Internet Connection")
        }
    }
    
}
