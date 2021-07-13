//
//  UIView+Extensions.swift
//  AppStoreDemo
//
//  Created by Patrick Tang on 10/7/2021.
//

import UIKit

extension UIView {
    
    func addRoundedCorners() {
        layer.cornerRadius = 15
    }
    
    func addCircleCorners() {
        layer.cornerRadius = bounds.height / 2.0
    }
    
}
