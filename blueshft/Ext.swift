//
//  Ext.swift
//  blueshft
//
//  Created by Kenny Schlagel on 11/30/15.
//  Copyright © 2015 Kenny Schlagel. All rights reserved.
//

import Foundation


extension String {
    var toProper:String {
        var result = lowercaseString
        result.replaceRange(startIndex...startIndex, with: String(self[startIndex]).capitalizedString)
        return result
    }
    
    var isEmail: Bool {
        do {
            let regex = try NSRegularExpression(pattern: "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$", options: .CaseInsensitive)
            return regex.firstMatchInString(self, options: NSMatchingOptions(rawValue: 0), range: NSMakeRange(0, self.characters.count)) != nil
        } catch {
            return false
        }
    }
}


extension UIView {
    class func loadFromNibNamed(nibNamed: String, bundle: NSBundle? = nil) -> UIView? {
        return UINib(nibName: nibNamed, bundle: bundle).instantiateWithOwner(nil, options: nil).first as? UIView
    }
    
    func addTopBorderWithColor(color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.CGColor
        border.frame = CGRectMake(0, 0, self.frame.size.width, width)
        self.layer.addSublayer(border)
    }
    
    func addRightBorderWithColor(color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.CGColor
        border.frame = CGRectMake(self.frame.size.width - width, 0, width, self.frame.size.height)
        self.layer.addSublayer(border)
    }
    
    func addBottomBorderWithColor(color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.CGColor
        border.frame = CGRectMake(0, self.frame.size.height - width, self.frame.size.width, width)
        self.layer.addSublayer(border)
    }
    
    func addLeftBorderWithColor(color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.CGColor
        border.frame = CGRectMake(0, 0, width, self.frame.size.height)
        self.layer.addSublayer(border)
    }
}

extension UIColor {
    class func blueshftBlue () -> UIColor {
        return UIColor(red: 31/255, green: 125/255, blue: 177/255, alpha: 1)
    }
}