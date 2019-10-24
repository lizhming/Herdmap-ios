//
//  SettingsViewController.swift
//  MyApp7
//
//  Created by Muhammad Bilal on 25/09/2017.
//  Copyright © 2017 Herdmaps. All rights reserved.
//

import UIKit
import Fusuma
import Alamofire
import SwiftyJSON
import Toast_Swift
import SwiftValidator

class SettingsViewController: UIViewController, ValidationDelegate {





    @IBOutlet weak var myProfilePic: UIImageView!
    
    @IBOutlet weak var txtCurrPass: UITextField!
    @IBOutlet weak var txtPass1: UITextField!
    @IBOutlet weak var txtPass2: UITextField!

    
    @IBOutlet weak var lblError: UILabel!
    
    let validator = Validator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getUserProfile();
        
        //Listeners from Others Controlelrs
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(refresh),
                                               name: NSNotification.Name(rawValue: "newPicture"),
                                               object: nil);
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(RegisterViewController.hideKeyboard)));
        
        validator.styleTransformers(success:{ (validationRule) -> Void in
            print("here")
            // clear error label
            validationRule.errorLabel?.isHidden = true
            validationRule.errorLabel?.text = ""
            if let textField = validationRule.field as? UITextField {
                textField.layer.borderColor = UIColor.green.cgColor
                textField.layer.borderWidth = 0.5
                
            }
        }, error:{ (validationError) -> Void in
            print("error")
            validationError.errorLabel?.isHidden = false
            validationError.errorLabel?.text = validationError.errorMessage
            if let textField = validationError.field as? UITextField {
                textField.layer.borderColor = UIColor.red.cgColor
                textField.layer.borderWidth = 1.0
            }
        });
        
        validator.registerField(txtCurrPass, errorLabel: lblError, rules: [RequiredRule(), MinLengthRule(length: 3)])
        validator.registerField(txtPass1, errorLabel: lblError, rules: [RequiredRule(), MinLengthRule(length: 3)])
        validator.registerField(txtPass2, errorLabel: lblError, rules: [RequiredRule(), MinLengthRule(length: 3)])
    }
    
    func refresh() {
        self.viewDidLoad()
        self.viewWillAppear(true);
    }
    
    @IBAction func btnUpdatePassword(_ sender: Any) {
        if (txtPass1.text == txtPass2.text) {
            //Password Match
            validator.validate(self)
        } else {
            //Do not Match
            lblError.text = "Passwords Do Not Match!";
        }
    }
    
    func validationFailed(_ errors: [(Validatable, ValidationError)]) {
        lblError.text = "Validation Failed, Please Check Your Fields";
    }
    
    func validationSuccessful() {
        let cpass: String = txtCurrPass.text!;
        let npass: String = txtPass2.text!;
        
        if (myUtils.isConnectedToNetwork()) {
            let params: [String: String] = [
                "updateUserPassword":       "1",
                "cpass":                    cpass,
                "cpass":                    npass,
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
                            self.view.makeToast("Password Successfully Changed")
                        } else {
                            self.view.makeToast("Invalid Password, No Changes Made")
                        }
                    }
                });
            
        } else {
            self.view.makeToast("Please Check Your Internet Connection")
        }
    }

    func hideKeyboard(){
        self.view.endEditing(true)
    }
    
    func getUserProfile() {
        if (myUtils.isConnectedToNetwork()) {
            let params: [String: String] = [
                "getUserProfile":     "1",
                "uid":                UserDefaults.standard.string(forKey: "uid")!
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
                            self.myProfilePic.downloadedFrom(link: json["profile"].rawString()!);
                        }
                    }
                });
            
        } else {
            self.view.makeToast("Please Check Your Internet Connection")
        }
    }
    
    //Take Picture
    @IBAction func btnUpdateProfilePicture(_ sender: Any) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "PictureViewController") as! PictureViewController
        self.present(newViewController, animated: true, completion: nil)
    }

}
