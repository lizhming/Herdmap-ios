//
//  MenuViewController.swift
//  AKSwiftSlideMenu
//
//  Created by Ashish on 21/09/15.
//  Copyright (c) 2015 Kode. All rights reserved.
//

import UIKit
import FontAwesome_swift
import SDWebImage

protocol SlideMenuDelegate {
    func slideMenuItemSelectedAtIndex(_ index : Int32)
}

class MenuViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var tblMenuOptions : UITableView!
    @IBOutlet var btnCloseMenuOverlay : UIButton!
    var arrayMenuOptions = [Dictionary<String,String>]()
    var btnMenu : UIButton!
    var delegate : SlideMenuDelegate?

    //Profile Section
    @IBOutlet weak var myProfileImage: UIImageView!
    @IBOutlet weak var myUserFullName: UILabel!
    @IBOutlet weak var myLoginBackgroundImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tblMenuOptions.separatorStyle = .none
        tblMenuOptions.tableFooterView = UIView()
        
        myProfileImage.layer.cornerRadius = myProfileImage.frame.size.width/2
        myProfileImage.clipsToBounds = true
        
        self.view.backgroundColor = UIColor.clear
        self.view.isOpaque = false

    }
    
    
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if (UserDefaults.standard.string(forKey: "uid") == nil) {
            //Logged Out
            updateArrayMenuOptions();
        } else {
            //Logged In
            updateArrayMenuOptionsLoggedIn();
            myUserFullName.text = UserDefaults.standard.string(forKey: "name");
            myLoginBackgroundImage.image = UIImage(named: "headerloggedin");
            myProfileImage.imageFromServerURL(urlString: UserDefaults.standard.string(forKey: "profile")!);
        }
        
    }
    
    func updateArrayMenuOptionsLoggedIn(){
        arrayMenuOptions.append(["title":"Home", "icon":"fa-home"])
        
        arrayMenuOptions.append(["title":"My Friends", "icon":"fa-users"])
        arrayMenuOptions.append(["title":"My Markers", "icon":"fa-map-marker"])
        arrayMenuOptions.append(["title":"My Subscriptions", "icon":"fa-clock-o"])
        
        arrayMenuOptions.append(["title":"Help", "icon":"fa-question-circle"])
        arrayMenuOptions.append(["title":"Settings", "icon":"fa-cog"])
        arrayMenuOptions.append(["title":"Logout", "icon":"fa-sign-out"])
        
        tblMenuOptions.reloadData()
    }
    
    func updateArrayMenuOptions(){
        arrayMenuOptions.append(["title":"Home", "icon":"fa-home"])
        
        arrayMenuOptions.append(["title":"Log in", "icon":"fa-sign-in"])
        arrayMenuOptions.append(["title":"Register", "icon":"fa-registered"])
        
        arrayMenuOptions.append(["title":"Help", "icon":"fa-question-circle"])
        
        tblMenuOptions.reloadData()
    }
    
    @IBAction func onCloseMenuClick(_ button:UIButton!){
        btnMenu.tag = 0
        
        if (self.delegate != nil) {
            var index = Int32(button.tag)
            if(button == self.btnCloseMenuOverlay){
                index = -1
            }
            delegate?.slideMenuItemSelectedAtIndex(index)
        }
        
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.view.frame = CGRect(x: -UIScreen.main.bounds.size.width, y: 0, width: UIScreen.main.bounds.size.width,height: UIScreen.main.bounds.size.height)
            self.view.layoutIfNeeded()
            self.view.backgroundColor = UIColor.clear
            }, completion: { (finished) -> Void in
                self.view.removeFromSuperview()
                self.removeFromParentViewController()
        })
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cellMenu")!
        
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.layoutMargins = UIEdgeInsets.zero
        cell.preservesSuperviewLayoutMargins = false
        cell.backgroundColor = UIColor.clear
        
        let lblTitle : UILabel = cell.contentView.viewWithTag(101) as! UILabel
        let imgIcon : UIImageView = cell.contentView.viewWithTag(100) as! UIImageView
        
        imgIcon.image = UIImage.fontAwesomeIcon(code: arrayMenuOptions[indexPath.row]["icon"]!, textColor: UIColor.gray, size: CGSize(width: 30, height: 30));
        
        lblTitle.text = arrayMenuOptions[indexPath.row]["title"]!
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let btn = UIButton(type: UIButtonType.custom)
        btn.tag = indexPath.row
        self.onCloseMenuClick(btn)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayMenuOptions.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    
}
