//
//  RegisterViewController.swift
//  MyApp7
//
//  Created by Muhammad Bilal on 24/09/2017.
//  Copyright © 2017 Herdmaps. All rights reserved.
//

import UIKit
import SwiftValidator
import Alamofire
import SwiftyJSON
import Toast_Swift
import Firebase

class RegisterViewController: UIViewController, ValidationDelegate {

    @IBOutlet weak var txtFirstName: UITextField!
    @IBOutlet weak var txtEmailAddress: UITextField!
    @IBOutlet weak var txtPass1: UITextField!
    @IBOutlet weak var txtPass2: UITextField!
    
    @IBOutlet weak var lblError: UILabel!
    
    let validator = Validator()
    var indicator: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray);

    //DEBUG ~ FIXING TOKEN
    var deviceToken = "1";
    let dtype       = "1"; //IOS DEVICE
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        //FCM Token
        deviceToken = InstanceID.instanceID().token()!;
        
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
        })
        
        validator.registerField(txtFirstName, errorLabel: lblError , rules: [RequiredRule(), FullNameRule()])
        validator.registerField(txtEmailAddress, errorLabel: lblError, rules: [RequiredRule(), EmailRule()])
        validator.registerField(txtPass1, errorLabel: lblError, rules: [RequiredRule(), MinLengthRule(length: 3)])
        validator.registerField(txtPass2, errorLabel: lblError, rules: [RequiredRule(), MinLengthRule(length: 3)])
        
        //Progress Dialog
        indicator.frame = CGRect(x: 0.0, y: 0.0, width: 40.0, height: 40.0)
        indicator.center = view.center
        view.addSubview(indicator)
        indicator.bringSubview(toFront: view)
        UIApplication.shared.isNetworkActivityIndicatorVisible = true;
    }

    @IBAction func btnSubmit(_ sender: Any) {
        indicator.startAnimating()
        
        if (txtPass1.text == txtPass2.text) {
            //Password Match
            validator.validate(self)
        } else {
            //Do not Match
            lblError.text = "Passwords Do Not Match!";
        }
    }
    
    func validationSuccessful() {
        if myUtils.isConnectedToNetwork(){
            let name    = txtFirstName.text;
            let email   = txtEmailAddress.text;
            let pass    = txtPass1.text;
            
            //Name, Email, Pass, Token, DTYPE
            let params: [String: String] = [
                "registerNewUser": "1",
                "name":     name!,
                "email":    email!,
                "pass":     pass!,
                "dtype":    dtype,
                "token":    deviceToken
            ];
            
            Alamofire.request(myUtils.APIURL, method: .post, parameters: params, encoding: URLEncoding.default, headers: nil).validate(statusCode: 200..<600).responseJSON { (response) in
                if response.result.value != nil {
                    let json = JSON(response.result.value!);
                    if (json["success"].number == 0) {
                        //Email Already Exists
                        self.txtEmailAddress.layer.borderColor = UIColor.red.cgColor
                        self.txtEmailAddress.layer.borderWidth = 1.0
                        
                        self.lblError.isHidden = false;
                        self.lblError.text = "Email Address already Registered!";
                    } else {
                        //Registeration Successfull
                        self.view.makeToast("Registeration Successful")
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
    
    func validationFailed(_ errors: [(Validatable, ValidationError)]) {
        lblError.text = "Validation Failed, Please Check Your Fields";
    }
    
    func createAlert(mTitle: String, mMsg: String) {
        let alert = UIAlertController(title: mTitle, message: mMsg, preferredStyle: UIAlertControllerStyle.alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(defaultAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func hideKeyboard(){
        self.view.endEditing(true)
    }


}
