import UIKit

class IWUserMarkerInfo: UIView {

    @IBOutlet weak var myTitle: UILabel!
    @IBOutlet weak var myDetails: UILabel!
    @IBOutlet weak var myCheckedIn: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func loadView() -> IWUserMarkerInfo{
        let infoWindow = Bundle.main.loadNibNamed("IWUserMarkerInfo", owner: self, options: nil)?[0] as! IWUserMarkerInfo
        return infoWindow;
    }

}
