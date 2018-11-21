
import UIKit

extension UIColor {
    
    convenience init(red: Int, green: Int, blue: Int) {
        self.init(red: CGFloat(red)/255, green: CGFloat(green)/255, blue: CGFloat(blue)/255, alpha: 1)
    }
    
    convenience init(hex: Int) {
        self.init(red: (hex >> 16) & 0xff, green: (hex >> 8) & 0xff, blue: hex & 0xff)
    }
    
    enum AppColors: RawRepresentable {
        case main
        case bar
        case imageBackground
        case complementary
        
        typealias RawValue = UIColor
        
        var rawValue: UIColor {
            switch self {
            case .main:
                return UIColor(red: 255, green: 23, blue: 68)
            case .bar:
                return UIColor(red: 63, green: 63, blue: 63)
            case .imageBackground:
                return UIColor(red: 211, green: 211, blue: 211)
            case .complementary:
                return UIColor(red: 23, green: 184, blue: 255)
            }
        }
        
        init?(rawValue: UIColor) {
            return nil
        }
    }
}
