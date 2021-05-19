//
//  Extensions.swift
//  nSoft
//
//  Created by TIGER on 2019/12/28.
//  Copyright © 2019 Xing. All rights reserved.
//

import Foundation
import UIKit
import SkyFloatingLabelTextField
import CommonCrypto

fileprivate var disclosureButtonAction: (() -> Void)?

extension SkyFloatingLabelTextField {
    
    func add(disclosureButton button: UIButton, action: @escaping (() -> Void)) {
        let selector = #selector(disclosureButtonPressed)
        if disclosureButtonAction != nil, let previousButton = rightView as? UIButton {
            previousButton.removeTarget(self, action: selector, for: .touchUpInside)
        }
        disclosureButtonAction = action
        button.addTarget(self, action: selector, for: .touchUpInside)
        rightView = button
    }
    
    func extendType() {
        self.rightViewMode = .whileEditing
        self.isSecureTextEntry = true
        self.autocapitalizationType = .none
        
        let disclosureButton = UIButton(type: .custom)
        disclosureButton.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: 20, height: 20))
        
        let normalImage = UIImage(named: "hidden_password")
        let selectedImage = UIImage(named: "show_password")
        disclosureButton.setImage(normalImage, for: .normal)
        disclosureButton.setImage(selectedImage, for: .selected)
        self.add(disclosureButton: disclosureButton) {
            disclosureButton.isSelected = !disclosureButton.isSelected
            self.resignFirstResponder()
            self.isSecureTextEntry = !self.isSecureTextEntry
            self.becomeFirstResponder()
        }
    }
    
    @objc fileprivate func disclosureButtonPressed() {
        disclosureButtonAction?()
    }
}

extension String {
    func md5() -> String {
        let str = self.cString(using: String.Encoding.utf8)
        let strLen = CUnsignedInt(self.lengthOfBytes(using: String.Encoding.utf8))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<UInt8>.allocate(capacity: 16)
        CC_MD5(str!, strLen, result)
        let hash = NSMutableString()
        for i in 0 ..< digestLen {
            hash.appendFormat("%02x", result[i])
        }
        free(result)
        return String(format: hash as String)
    }
    
    func isValidEmail() -> Bool {
        // here, `try!` will always succeed because the pattern is valid
        let regex = try! NSRegularExpression(pattern: "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$", options: .caseInsensitive)
        return regex.firstMatch(in: self, options: [], range: NSRange(location: 0, length: count)) != nil
    }
}

extension SkyFloatingLabelTextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}

extension Formatter {
    static let withSeparator: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.groupingSeparator = ","
        formatter.numberStyle = .decimal
        return formatter
    }()
}

extension Numeric {
    var formattedWithSeparator: String {
        return Formatter.withSeparator.string(for: self) ?? ""
    }
}

extension Date {

    /// Returns a Date with the specified amount of components added to the one it is called with
    func add(years: Int = 0, months: Int = 0, days: Int = 0, hours: Int = 0, minutes: Int = 0, seconds: Int = 0) -> Date? {
        let components = DateComponents(year: years, month: months, day: days, hour: hours, minute: minutes, second: seconds)
        return Calendar.current.date(byAdding: components, to: self)
    }

    /// Returns a Date with the specified amount of components subtracted from the one it is called with
    func subtract(years: Int = 0, months: Int = 0, days: Int = 0, hours: Int = 0, minutes: Int = 0, seconds: Int = 0) -> Date? {
        return add(years: -years, months: -months, days: -days, hours: -hours, minutes: -minutes, seconds: -seconds)
    }
    
    var millisecondsSince1970:Int64 {
        return Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }

    init(milliseconds:Int64) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }
}

extension UIView {
   func createTopDottedLine(width: CGFloat, color: CGColor) {
      let caShapeLayer = CAShapeLayer()
      caShapeLayer.strokeColor = color
      caShapeLayer.lineWidth = width
                caShapeLayer.lineDashPattern = [4, 2]
      let cgPath = CGMutablePath()
      let cgPoint = [CGPoint(x: 0, y: 0), CGPoint(x: self.frame.width, y: 0)]
      cgPath.addLines(between: cgPoint)
      caShapeLayer.path = cgPath
      layer.addSublayer(caShapeLayer)
   }
    
    func createBottomDottedLine(width: CGFloat, color: CGColor) {
          let caShapeLayer = CAShapeLayer()
          caShapeLayer.strokeColor = color
          caShapeLayer.lineWidth = width
                    caShapeLayer.lineDashPattern = [4, 2]
          let cgPath = CGMutablePath()
          let cgPoint = [CGPoint(x: 0, y: 40), CGPoint(x: self.frame.width, y: 40)]
          cgPath.addLines(between: cgPoint)
          caShapeLayer.path = cgPath
          layer.addSublayer(caShapeLayer)
       }
    
    func createLeftDottedLine(height: CGFloat, color: CGColor) {
          let caShapeLayer = CAShapeLayer()
          caShapeLayer.strokeColor = color
          caShapeLayer.lineWidth = height
                    caShapeLayer.lineDashPattern = [4, 2]
          let cgPath = CGMutablePath()
          let cgPoint = [CGPoint(x: 0, y: 0), CGPoint(x: 0, y: 40)]
          cgPath.addLines(between: cgPoint)
          caShapeLayer.path = cgPath
          layer.addSublayer(caShapeLayer)
       }
}

