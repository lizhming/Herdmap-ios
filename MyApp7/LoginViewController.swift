//
//  LoginViewController.swift
//  MyApp7
//
//  Created by Muhammad Bilal on 24/09/2017.
//  Copyright © 2017 Herdmaps. All rights reserved.
//

import UIKit
import Material
import SwiftValidator
import Alamofire
import SwiftyJSON
import Toast_Swift

class LoginViewController: UIViewController, ValidationDelegate {

    @IBOutlet weak var txtEmailAdress: TextField!
    @IBOutlet weak var txtPassword: TextField!
    
    @IBOutlet weak var lblError: UILabel!
    
    let validator = Validator();
    let defaults = UserDefaults.standard
    
    var indicator: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        txtEmailAdress.textColor = UIColor.white;
        txtEmailAdress.placeholderActiveColor = UIColor.white;
        txtEmailAdress.dividerActiveColor = UIColor.white;
        
        txtPassword.textColor = UIColor.white;
        txtPassword.placeholderActiveColor = UIColor.white;
        txtPassword.dividerActiveColor = UIColor.white;
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(LoginViewController.hideKeyboard)));
        
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
        
        validator.registerField(txtEmailAdress, errorLabel: lblError, rules: [RequiredRule(), EmailRule()])
        validator.registerField(txtPassword, errorLabel: lblError, rules: [RequiredRule(), MinLengthRule(length: 3)])
        
        //Progress Dialog
        indicator.frame = CGRect(x: 0.0, y: 0.0, width: 40.0, height: 40.0)
        indicator.center = view.center
        view.addSubview(indicator)
        indicator.bringSubview(toFront: view)
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        
    }
    

    
    @IBAction func btnLogin(_ sender: Any) {
        validator.validate(self);
        
    }

    func validationSuccessful() {
        indicator.startAnimating()
        
        if myUtils.isConnectedToNetwork(){
            
            let email   = txtEmailAdress.text;
            let pass    = txtPassword.text;
            
            //Name, Email, Pass, Token, DTYPE
            let params: [String: String] = [
                "attemptLogin": "1",
                "email":    email!,
                "pass":     pass!
            ];
            
            Alamofire.request(myUtils.APIURL, method: .post, parameters: params, encoding: URLEncoding.default, headers: nil).validate(statusCode: 200..<600).responseJSON { (response) in
                if response.result.value != nil {
                    //print(response.result.value);
                    
                    let json = JSON(response.result.value!);
                    //print(json["success"]);
                    print(json);
                    
                    if (json["success"].number == 0) {
                        //Invalid
                        self.lblError.isHidden = false;
                        self.lblError.text = "Incorrect Credentials, Check Again";
                    } else {
                        //Registeration Successfull
                        self.view.makeToast("Login Successful")
                        
                        //Init UserDefaults
                        self.defaults.set(json["uid"].rawString(),      forKey: "uid");
                        self.defaults.set(json["name"].rawString(),     forKey: "name");
                        self.defaults.set(json["email"].rawString(),    forKey: "email");
                        self.defaults.set(json["profile"].rawString(),    forKey: "profile");
                        
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "loginSuccessful"), object: self)
                        self.navigationController?.popToRootViewController(animated: true)
                    }
                    
                    self.indicator.stopAnimating();
                }
            }
            
            
            
        } else {
            print("Internet Connection not Available!")
            createAlert(mTitle: "Error Connection", mMsg: "Please Check Your Internet Connection, Unable to Connect to Server at this time.")
            
        }
        
    }
    
    func createAlert(mTitle: String, mMsg: String) {
        let alert = UIAlertController(title: mTitle, message: mMsg, preferredStyle: UIAlertControllerStyle.alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(defaultAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func validationFailed(_ errors:[(Validatable, ValidationError)]) {
        lblError.text = "Validation Failed, Please Check Your Fields";
    }
    
    func hideKeyboard(){
        self.view.endEditing(true)
    }

}
