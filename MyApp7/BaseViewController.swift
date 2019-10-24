import UIKit
import Toast_Swift

class BaseViewController: UIViewController, SlideMenuDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Menu Loading")
    }
    
    func slideMenuItemSelectedAtIndex(_ index: Int32) {
        let _ : UIViewController = self.navigationController!.topViewController!
        if (UserDefaults.standard.string(forKey: "uid") == nil) {
            switch(index){
                case 0:
                    print("Home\n");
                    self.openViewControllerBasedOnIdentifier("ViewController")
                    break;
                case 1: //Login
                    print("Login");
                    self.openViewControllerBasedOnIdentifier("LoginViewController")
                    break;
                case 2:
                    print("Register");
                    self.openViewControllerBasedOnIdentifier("RegisterViewController")
                    break;
                case 3: //Help
                    print("FAQs");
                    self.openViewControllerBasedOnIdentifier("HelpViewController")
                    break;
                default:
                    print("default\n", terminator: "")
            }
        } else {
            switch(index){
            case 0: //Home
                print("Home\n");
                self.openViewControllerBasedOnIdentifier("ViewController");
                break;
            case 1: //My Friends
                self.openViewControllerBasedOnIdentifier("FriendsListViewController");
                break;
            case 2: //My Markers
                print("My Markers");
                self.openViewControllerBasedOnIdentifier("MyUserMarkersViewController");
                break;
            case 3: //My Markers
                print("My Subscriptions");
                self.openViewControllerBasedOnIdentifier("MySubsViewController");
                break;
            case 4: //FAQs
                print("FAQs");
                self.openViewControllerBasedOnIdentifier("HelpViewController");
                break;
            case 5: //Settings
                print("Settings");
                self.openViewControllerBasedOnIdentifier("SettingsViewController");
                break;
            case 6: //Logout
                UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
                UserDefaults.standard.synchronize();
                self.viewDidLoad()
                self.viewWillAppear(true)
                break;
            default:
                print("default\n", terminator: "")
            }
        }
    }
    
    func openViewControllerBasedOnIdentifier(_ strIdentifier:String){
        let destViewController : UIViewController = self.storyboard!.instantiateViewController(withIdentifier: strIdentifier)
        
        let topViewController : UIViewController = self.navigationController!.topViewController!
        
        if (topViewController.restorationIdentifier! == destViewController.restorationIdentifier!){
            print("Same VC")
        } else {
            self.navigationController!.pushViewController(destViewController, animated: true)
        }
    }
    
    func addSlideMenuButton(){
        let btnShowMenu = UIButton(type: UIButtonType.system)
        btnShowMenu.setImage(self.defaultMenuImage(), for: UIControlState())
        btnShowMenu.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        btnShowMenu.addTarget(self, action: #selector(BaseViewController.onSlideMenuButtonPressed(_:)), for: UIControlEvents.touchUpInside)
        let customBarItem = UIBarButtonItem(customView: btnShowMenu)
        self.navigationItem.leftBarButtonItem = customBarItem;
    }

    func defaultMenuImage() -> UIImage {
        var defaultMenuImage = UIImage()
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 30, height: 22), false, 0.0)
        
        UIColor.black.setFill()
        UIBezierPath(rect: CGRect(x: 0, y: 3, width: 30, height: 1)).fill()
        UIBezierPath(rect: CGRect(x: 0, y: 10, width: 30, height: 1)).fill()
        UIBezierPath(rect: CGRect(x: 0, y: 17, width: 30, height: 1)).fill()
        
        UIColor.white.setFill()
        UIBezierPath(rect: CGRect(x: 0, y: 4, width: 30, height: 1)).fill()
        UIBezierPath(rect: CGRect(x: 0, y: 11,  width: 30, height: 1)).fill()
        UIBezierPath(rect: CGRect(x: 0, y: 18, width: 30, height: 1)).fill()
        
        defaultMenuImage = UIGraphicsGetImageFromCurrentImageContext()!
        
        UIGraphicsEndImageContext()
       
        return defaultMenuImage;
    }
    
    @objc func onSlideMenuButtonPressed(_ sender : UIButton){
        if (sender.tag == 10)
        {
            // To Hide Menu If it already there
            self.slideMenuItemSelectedAtIndex(-1);
            
            sender.tag = 0;
            
            let viewMenuBack : UIView = view.subviews.last!
            
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                var frameMenu : CGRect = viewMenuBack.frame
                frameMenu.origin.x = -1 * UIScreen.main.bounds.size.width
                viewMenuBack.frame = frameMenu
                viewMenuBack.layoutIfNeeded()
                viewMenuBack.backgroundColor = UIColor.clear
                }, completion: { (finished) -> Void in
                    viewMenuBack.removeFromSuperview()
            })
            
            return
        }
        
        sender.isEnabled = false
        sender.tag = 10
        
        let menuVC : MenuViewController = self.storyboard!.instantiateViewController(withIdentifier: "MenuViewController") as! MenuViewController
        menuVC.btnMenu = sender
        menuVC.delegate = self
        self.view.addSubview(menuVC.view)
        self.addChildViewController(menuVC)
        menuVC.view.layoutIfNeeded()
        
        
        menuVC.view.frame=CGRect(x: 0 - UIScreen.main.bounds.size.width, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height);
        
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            menuVC.view.frame=CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height);
            sender.isEnabled = true
            }, completion:nil)
    }
    
    
}
