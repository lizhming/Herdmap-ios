import UIKit
import Cosmos

class IWBusinessMarker: UIView {

    @IBOutlet weak var myCompName: UILabel!
    @IBOutlet weak var myCategory: UILabel!
    
    @IBOutlet weak var myRating: CosmosView!
    @IBOutlet weak var myRatingText: UILabel!
    @IBOutlet weak var mySubs: UILabel!
    
    @IBOutlet weak var myLogo: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func loadView() -> IWBusinessMarker{
        let infoWindow = Bundle.main.loadNibNamed("IWBusinessMarker", owner: self, options: nil)?[0] as! IWBusinessMarker
        return infoWindow;
    }

}
