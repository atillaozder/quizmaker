
import UIKit

/// :nodoc:
extension UIButton {
    convenience init(image: String) {
        self.init(type: .system)
        let image = UIImage(imageLiteralResourceName: image)
        self.setImage(image, for: .normal)
        self.tintColor = .lightGray
        self.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
    }
}

/// :nodoc:
extension UIView {
    
    func fillSafeArea(spacing: UIEdgeInsets = .zero, size: CGSize = .zero) {
        guard let superView = superview else { return }
        translatesAutoresizingMaskIntoConstraints = false
        
        var safeArea = superView.layoutMarginsGuide
        if #available(iOS 11, *) {
            safeArea = superView.safeAreaLayoutGuide
        }
        
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: spacing.left),
            topAnchor.constraint(equalTo: safeArea.topAnchor, constant: spacing.top),
            bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: spacing.bottom),
            trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: spacing.right)
            ])
        
        if size.height != 0 {
            heightAnchor.constraint(equalToConstant: size.height).isActive = true
        }
        
        if size.width != 0 {
            widthAnchor.constraint(equalToConstant: size.width).isActive = true
        }
    }
    
    func fillSuperView(spacing: UIEdgeInsets = .zero, size: CGSize = .zero) {
        guard let superView = superview else { return }
        translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: superView.leadingAnchor, constant: spacing.left),
            topAnchor.constraint(equalTo: superView.topAnchor, constant: spacing.top),
            bottomAnchor.constraint(equalTo: superView.bottomAnchor, constant: spacing.bottom),
            trailingAnchor.constraint(equalTo: superView.trailingAnchor, constant: spacing.right)
            ])
        
        if size.height != 0 {
            heightAnchor.constraint(equalToConstant: size.height).isActive = true
        }
        
        if size.width != 0 {
            widthAnchor.constraint(equalToConstant: size.width).isActive = true
        }
    }
    
    func setAnchors(top: NSLayoutYAxisAnchor?,
                    bottom: NSLayoutYAxisAnchor?,
                    leading: NSLayoutXAxisAnchor?,
                    trailing: NSLayoutXAxisAnchor?,
                    spacing: UIEdgeInsets = .zero,
                    size: CGSize = .zero) {
        
        translatesAutoresizingMaskIntoConstraints = false
        if let top = top {
            topAnchor.constraint(equalTo: top, constant: spacing.top).isActive = true
        }
        
        if let bottom = bottom {
            bottomAnchor.constraint(equalTo: bottom, constant: spacing.bottom).isActive = true
        }
        
        if let leading = leading {
            leadingAnchor.constraint(equalTo: leading, constant: spacing.left).isActive = true
        }
        
        if let trailing = trailing {
            trailingAnchor.constraint(equalTo: trailing, constant: spacing.right).isActive = true
        }
        
        if size.height != 0 {
            heightAnchor.constraint(equalToConstant: size.height).isActive = true
        }
        
        if size.width != 0 {
            widthAnchor.constraint(equalToConstant: size.width).isActive = true
        }
    }
    
    func setCenter() {
        guard let superView = superview else { return }
        translatesAutoresizingMaskIntoConstraints = false
        centerXAnchor.constraint(equalTo: superView.safeAreaLayoutGuide.centerXAnchor).isActive = true
        centerYAnchor.constraint(equalTo: superView.safeAreaLayoutGuide.centerYAnchor).isActive = true
    }
    
    func setHeightConstraint(constant: CGFloat, priority: Float) {
        let constraint = heightAnchor.constraint(equalToConstant: constant)
        constraint.priority = .init(priority)
        constraint.isActive = true
    }
    
    func setHeightConstraint(equalTo: NSLayoutDimension, multiplier: CGFloat = 1, priority: Float) {
        let constraint = heightAnchor.constraint(equalTo: equalTo, multiplier: multiplier)
        constraint.priority = .init(priority)
        constraint.isActive = true
    }
    
    func roundCorners(_ corners: UIRectCorner,
                      radius: CGFloat,
                      withBorder: Bool = false,
                      borderColor: UIColor = UIColor(red: 102, green: 102, blue: 102)) {
        
        let maskPath = UIBezierPath(roundedRect: bounds,
                                    byRoundingCorners: corners,
                                    cornerRadii: CGSize(width: radius, height: radius))
        
        layer.mask?.removeFromSuperlayer()
        let shape = CAShapeLayer()
        shape.path = maskPath.cgPath
        layer.mask = shape
        
        if withBorder {
            addBorderLayer(maskPath: maskPath, borderColor: borderColor)
        }
    }
    
    func addBorderLayer(maskPath: UIBezierPath, borderColor: UIColor) {
        layer.sublayers?.removeAll()
        let border = CAShapeLayer()
        border.path = maskPath.cgPath
        border.fillColor = UIColor.clear.cgColor
        border.strokeColor = borderColor.cgColor
        border.lineWidth = 3.0
        border.frame = bounds
        layer.addSublayer(border)
    }
    
    static func errorWrapperView(forLabel label: UILabel) -> UIView {
        let wrapper = UIView()
        wrapper.translatesAutoresizingMaskIntoConstraints = false
        wrapper.heightAnchor.constraint(equalToConstant: 20).isActive = true
        wrapper.addSubview(label)
        wrapper.isHidden = true
        label.fillSuperView()
        return wrapper
    }
    
    static func uiStackView(arrangedSubviews: [UIView],
                            _ distribution: UIStackView.Distribution,
                            _ alignment: UIStackView.Alignment,
                            _ axis: NSLayoutConstraint.Axis,
                            _ spacing: CGFloat) -> UIStackView {
        
        let stackView = UIStackView(arrangedSubviews: arrangedSubviews)
        stackView.distribution = distribution
        stackView.alignment = alignment
        stackView.axis = axis
        stackView.spacing = spacing
        return stackView
    }
}

/// :nodoc:
extension UILabel {
    
    static func uiLabel(_ numberOfLines: Int = 0,
                        _ lineBreakMode: NSLineBreakMode = .byWordWrapping,
                        _ text: String?,
                        _ textAlignment: NSTextAlignment = .natural,
                        _ textColor: UIColor? = nil,
                        _ font: UIFont,
                        _ adjustFontSizeCategory: Bool = true,
                        _ userInteraction: Bool = false) -> UILabel {
        let label = UILabel()
        label.numberOfLines = numberOfLines
        label.lineBreakMode = lineBreakMode
        label.textAlignment = textAlignment
        label.text = text
        label.textColor = textColor
        label.font = font
        label.adjustsFontForContentSizeCategory = adjustFontSizeCategory
        label.isUserInteractionEnabled = userInteraction
        return label
    }
    
    static func uiTitleLabel(text: String) -> UILabel {
        return UILabel.uiLabel(0, .byWordWrapping, text, .left, .black, .preferredFont(forTextStyle: .subheadline), true, false)
    }
    
    static func uiErrorLabel() -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center
        label.textColor = .red
        label.font = UIFont.preferredFont(forTextStyle: .caption2)
        label.adjustsFontForContentSizeCategory = true
        return label
    }
}

