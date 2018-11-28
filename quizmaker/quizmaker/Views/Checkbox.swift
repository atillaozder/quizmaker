import UIKit

class CheckBox: UIButton {

    let checkedImage: UIImage = UIImage(imageLiteralResourceName: "checkbox_checked")
    let uncheckedImage: UIImage  = UIImage(imageLiteralResourceName: "checkbox_unchecked")
    
    var isChecked: Bool = false {
        didSet{
            if isChecked == true {
                self.setImage(checkedImage, for: .normal)
            } else {
                self.setImage(uncheckedImage, for: .normal)
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}