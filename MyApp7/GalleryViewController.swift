//
//  GalleryViewController.swift
//  MyApp7
//
//  Created by Muhammad Bilal on 23/09/2017.
//  Copyright © 2017 Herdmaps. All rights reserved.
//

import UIKit
import Toast_Swift
import Alamofire
import SwiftyJSON

class GalleryViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {

    var bid: String = "0";
    var imageData: [String] = [String]()
    var imageCounter: Int = 0

    @IBOutlet weak var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        populateImage();
    }
    
    func populateImage() {
        if (myUtils.isConnectedToNetwork()) {
            
            let params: [String: String] = [
                "getGallery":  "1",
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
                            
                            let myGalleryArray = json["gallery"]
                            
                            for (_, object) in myGalleryArray {
                                self.imageData.append(object["image"].string!);
                                print(object["image"].string!);
                            }
                            
                            
                        }
                        self.collectionView.reloadData()
                    }
                });
        } else {
            self.view.makeToast("Please Check Your Internet Connection")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "ImageZoomViewController") as! ImageZoomViewController
        newViewController.imageURL = imageData[indexPath.row];
        self.present(newViewController, animated: true, completion: nil)
        
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1;
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 90, height: 90)
    }
    
    @available(iOS 6.0, *)
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as! MyCustomImageCell
        //var currImage:String = ""
        //_ = self.imageData[self.imageCounter]
        self.imageCounter += 1
        if self.imageCounter >= self.imageData.count {
            self.imageCounter = 0
        }
        
        cell.image.imageFromServerURL(urlString: imageData[indexPath.row]);
        return cell
    }
    
    @available(iOS 6.0, *)
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageData.count;
    }

}
