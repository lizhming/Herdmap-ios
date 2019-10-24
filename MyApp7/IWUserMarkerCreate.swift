import UIKit

class IWUserMarkerCreate: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func loadView() -> IWUserMarkerCreate{
        let infoWindow = Bundle.main.loadNibNamed("IWUserMarkerCreate", owner: self, options: nil)?[0] as! IWUserMarkerCreate
        return infoWindow;
    }

}
