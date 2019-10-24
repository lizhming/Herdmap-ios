//
//  ViewController.swift
//  MyApp7
//
//  Created by Muhammad Bilal on 23/09/2017.
//  Copyright © 2017 Herdmaps. All rights reserved.
//

import UIKit
import GoogleMaps
import Alamofire
import SwiftyJSON
import Toast_Swift
import Popover
import CoreLocation

class ViewController: BaseViewController, GMSMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet var mapView: GMSMapView!

    //CAMERA INITS
    var mylat: Double = 0.0; var mylng: Double = 0.0;
    var myLocation: CLLocation?
    
    var camera = GMSCameraPosition
        .camera(
            withLatitude: 0,
            longitude: 0,
            zoom: 10);
    
    //Markers Array
    var myMarkersArray = [MarkerBus]();
    
    //Map Markers
    var mapMarkers = [GMSMarker]()
    
    //Custom InfoWindows
    var infoWindowBusiness:     IWBusinessMarker?;
    var infoWindowUserMarker:   IWUserMarkerInfo?;
    var infoWindowUserCreate:   IWUserMarkerCreate?;
    
    //Selected Category
    var selectedCategory: String = "0";
    
    //Custom Marker
    var createMarker: Bool = false;
    
    //Popup for Create User Marker
    var aView: UserMarkerPopup?     = nil;
    var umDialog: Popover?          = nil;
    
    //GPS Location
    var locationManager:CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Herdmaps";
        
        //NavDrawer
        addSlideMenuButton();
        
        /*
        //Init MyCordinates
        mylat = 38.59;
        mylng = -90.50;
        myLocation = CLLocation(latitude: mylat, longitude: mylng);
        
        //Camera
        camera = GMSCameraPosition
            .camera(
                withLatitude: (myLocation?.coordinate.latitude)!,
                longitude: (myLocation?.coordinate.longitude)!,
                zoom: 10);
        */
        
        //Map Properties
        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        
        //Map Inits
        self.mapView.delegate = self
        self.view = mapView
        
        //Populate Map With Markers
        //populateMap(cat: "0");
        
        //Load InfoWindow Views
        self.infoWindowBusiness     = IWBusinessMarker().loadView();
        self.infoWindowUserMarker   = IWUserMarkerInfo().loadView();
        self.infoWindowUserCreate   = IWUserMarkerCreate().loadView();
        
        //Listeners from Others Controlelrs
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(selectCat),
                                               name: NSNotification.Name(rawValue: "selectedCategory"),
                                               object: nil);
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        determineMyCurrentLocation()
    }
    
    //Refresh Map Specific Location
    func refreshMap(lat: Double, lng: Double) {
        myLocation = CLLocation(latitude: lat, longitude: lng);
        camera = GMSCameraPosition
            .camera(
                withLatitude: (myLocation?.coordinate.latitude)!,
                longitude: (myLocation?.coordinate.longitude)!,
                zoom: 10);
        mapView.animate(to: camera);
        populateMap(cat: selectedCategory);
    }
    
    //Location Manager Functions
    func determineMyCurrentLocation() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
            //locationManager.startUpdatingHeading()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0] as CLLocation
        
        manager.stopUpdatingLocation()
        
        print("user latitude = \(userLocation.coordinate.latitude)");
        print("user longitude = \(userLocation.coordinate.longitude)");
        
        mylat = userLocation.coordinate.latitude;
        mylng = userLocation.coordinate.longitude;
        refreshMap(lat: mylat, lng: mylng);
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("Error \(error)")
    }

    //Category Selected
    func selectCat(_ notification: Notification) {
        if let myDict = notification.object as? [String: Any] {
            if (Int(myDict["id"] as! String)! < 0) {
                selectedCategory = myDict["id"] as! String;
            }
            
            mapView.clear();
            populateMap(cat: myDict["id"] as! String);
            
            self.view.makeToast(myDict["name"] as! String +  " selected")
        }
    }
    
    //Return View for InfoWindow
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        if (createMarker == false) {
            if (Int(selectedCategory)! < 0) {
                return self.infoWindowUserMarker;
            } else {
                return self.infoWindowBusiness;
            }
        } else {
            return self.infoWindowUserCreate;
        }
        
    }
    
    //InfoWindow Tap Listener
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        if (createMarker == false) {
            if (Int(selectedCategory)! < 0) {
                //User Marker Details
                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let newViewController = storyBoard.instantiateViewController(withIdentifier: "UMDetViewController") as! UMDetViewController
                let index = mapMarkers.index(of: marker);
                
                newViewController.umid = myMarkersArray[index!].id;
                newViewController.uTitle = myMarkersArray[index!].name;
                newViewController.uDetails = myMarkersArray[index!].details;
                newViewController.uChecked = myMarkersArray[index!].checkedIn;
                
                //Send Location
                newViewController.mylat = String(mylat);
                newViewController.mylng = String(mylng);
                self.navigationController?.pushViewController(newViewController, animated: true)
            } else {
                //Busines Marker Details
                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let newViewController = storyBoard.instantiateViewController(withIdentifier: "BusViewController") as! BusViewController
                let index = mapMarkers.index(of: marker);
                
                newViewController.bid = myMarkersArray[index!].id;
                
                //Send Location
                newViewController.mylat = String(mylat);
                newViewController.mylng = String(mylng);
                self.navigationController?.pushViewController(newViewController, animated: true)
            }
        } else {
            //Popover to Add Marker
            aView       = UINib(nibName: "UserMarkerPopup", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as? UserMarkerPopup;
            umDialog    = Popover(options: nil, showHandler: nil, dismissHandler: nil);
            umDialog?.showAsDialog(aView!);
            aView?.btnAddMarker.addTarget(
                self,
                action: #selector(addUserMarker),
                for: .touchUpInside)
        }
    }
    
    //Add User Marker 
    func addUserMarker() {
        if (myUtils.isConnectedToNetwork()) {

            let params: [String: String] = [
                "addUserMarker":        "1",
                "lat":                  String(mylat),
                "lng":                  String(mylng),
                "uid":                  UserDefaults.standard.string(forKey: "uid")!,
                "title":                (aView?.txtTitle.text)!,
                "det":                  (aView?.txtDetails.text!)!
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
                            self.view.makeToast("Marker Successfully Added")
                            self.mapView.clear();
                            self.selectedCategory = "-1";
                            self.populateMap(cat: "-1");
                            self.umDialog?.dismiss();
                            self.navigationController?.navigationBar.backgroundColor = UIColor.white;
                        }
                    }
                });
            
        } else {
            self.view.makeToast("Please Check Your Internet Connection")
        }
    }
    
    //Marker Tap Listener
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        
        mapView.animate(toLocation: marker.position);
        let index = mapMarkers.index(of: marker)
        
        if (createMarker == false) {
            if (Int(selectedCategory)! < 0) {
                //User Marker Data
                infoWindowUserMarker?.myTitle.text      = myMarkersArray[index!].name;
                infoWindowUserMarker?.myDetails.text    = myMarkersArray[index!].details;
                infoWindowUserMarker?.myCheckedIn.text  = myMarkersArray[index!].checkedIn;
            } else {
                //Business Marker Data
                infoWindowBusiness?.myCompName.text     = myMarkersArray[index!].name;
                infoWindowBusiness?.myCategory.text     = myMarkersArray[index!].cat;
                infoWindowBusiness?.myRating.rating     = Double(myMarkersArray[index!].rating)!
                infoWindowBusiness?.myRatingText.text   = "(" + myMarkersArray[index!].numRating + ") Ratings";
                infoWindowBusiness?.mySubs.text         = myMarkersArray[index!].checkedIn + "+ People Checked In";
                let myURL                               = URL(string: myMarkersArray[index!].logo);
                infoWindowBusiness?.myLogo.downloadedFrom(url: myURL!)
            }
        }



        return false;
    }
    
    //Populate Map
    func populateMap(cat: String) {
        if (!myUtils.isConnectedToNetwork()) {
            self.view.makeToast("Please Check Your Internet Connection")
        } else {
            let params: [String: String] = [
                "getBusinessListings":  "1",
                "lat":                  String(mylat),
                "lng":                  String(mylng),
                "cat":                  cat
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
                                let myMarkersGetArr = json["blist"];
                                
                                if (Int(self.selectedCategory)! < 0) {
                                    //User Marker Data
                                    for (_, object) in myMarkersGetArr {
                                        //Init Marker Class
                                        let myMarker = MarkerBus();
                                        myMarker.id     = object["id"].string!;
                                        myMarker.name   = object["name"].string!;
                                        
                                        myMarker.lat    = Double(object["lat"].string!)!;
                                        myMarker.long   = Double(object["lng"].string!)!;
                                        
                                        myMarker.checkedIn  = object["checked"].rawString()!;
                                        
                                        myMarker.rating     = object["rating"].rawString()!;
                                        myMarker.numRating  = object["num"].rawString()!;
                                        
                                        myMarker.details    = object["umdetails"].string!;
                                        
                                        //Add to Array
                                        self.myMarkersArray.append(myMarker);
                                        
                                        //Add Marker to Map Markers Array
                                        let mMarker = GMSMarker();
                                        mMarker.position = CLLocationCoordinate2D(
                                            latitude: Double(object["lat"].string!)!,
                                            longitude: Double(object["lng"].string!)!);
                                        mMarker.title = object["name"].string!;
                                        mMarker.map = self.mapView;
                                        
                                        self.mapMarkers.append(mMarker);
                                    }
                                } else {
                                    //Business Marker Data
                                    for (_, object) in myMarkersGetArr {
                                        //Init Marker Class
                                        let myMarker = MarkerBus();
                                        myMarker.id     = object["id"].string!;
                                        myMarker.name   = object["name"].string!;
                                        
                                        myMarker.lat    = Double(object["lat"].string!)!;
                                        myMarker.long   = Double(object["lng"].string!)!;
                                        
                                        myMarker.cat    = object["cat"].string!;
                                        myMarker.logo   = object["logo"].string!;
                                        
                                        myMarker.checkedIn  = object["checked"].rawString()!;
                                        
                                        myMarker.rating     = object["rating"].rawString()!;
                                        myMarker.numRating  = object["num"].rawString()!;
                                        
                                        //Add to Array
                                        self.myMarkersArray.append(myMarker);
                                        
                                        //Add Marker to Map Markers Array
                                        let mMarker = GMSMarker();
                                        mMarker.position = CLLocationCoordinate2D(
                                            latitude: Double(object["lat"].string!)!,
                                            longitude: Double(object["lng"].string!)!);
                                        mMarker.title = object["name"].string!;
                                        mMarker.map = self.mapView;
                                        
                                        self.mapMarkers.append(mMarker);
                                    }
                                }
                            }
                        }
                    }
                });
            
        }
    }
    
    //Marker Class
    class MarkerBus {
        var id:         String = "";
        var name:       String = "";
        
        var lat:        CLLocationDegrees = 0.0;
        var long:       CLLocationDegrees = 0.0;
        
        var cat:        String = "";
        var logo:       String = "";
        
        var checkedIn:  String = "";
        
        var rating:     String = "";
        var numRating:  String = "";
        
        var details:    String = "";
    }

    //NAVBAR ICONS
    
    //Create Custom Marker
    @IBAction func myCreateCustomMarkerButton(_ sender: Any) {
        if (createMarker == false) {
            createMarker = true;
            self.view.makeToast("Your Marker")
            self.navigationController?.navigationBar.backgroundColor = UIColor.red;
            mapView.clear();
            
            //Add Custom Marker
            let myMarker = GMSMarker();
            myMarker.position = CLLocationCoordinate2D(latitude: Double(mylat), longitude: Double(mylng));
            myMarker.title = "My Custom Marker"
            myMarker.map = self.mapView;
            mapView.animate(toLocation: myMarker.position);
            mapView.selectedMarker = myMarker;
        } else {
            createMarker = false;
            self.navigationController?.navigationBar.backgroundColor = UIColor.white;
            mapView.clear();
            selectedCategory = "0";
            populateMap(cat: "0");
            self.view.makeToast("All Categories")
        }
    }
    
    //Refresh
    @IBAction func btnRefreshMap(_ sender: Any) {
        self.view.makeToast("Refreshing Map")
        //populateMap(cat: "0");
        determineMyCurrentLocation();
    }
    
    //Select Category
    @IBAction func btnFilterCats(_ sender: Any) {
        self.openViewControllerBasedOnIdentifier("CategoryViewController");
    }

}

