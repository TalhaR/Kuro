//
//  UIViewHelper.swift
//  Kuro
//
//  Created by Talha Rahman on 11/19/20.
//

import UIKit

extension UIView {
    func stretchViewBoundsByAddingConstraints(ofParent parent: UIView) {
        self.topAnchor.constraint(equalTo: parent.topAnchor).isActive = true
        self.bottomAnchor.constraint(equalTo: parent.bottomAnchor).isActive = true
        self.leadingAnchor.constraint(equalTo: parent.leadingAnchor).isActive = true
        self.trailingAnchor.constraint(equalTo: parent.trailingAnchor).isActive = true
    }
    
    func stretchViewBoundsByAddingConstraints(ofParent parent: UIView, withOffset offset: CGFloat) {
        self.topAnchor.constraint(equalTo: parent.topAnchor, constant: offset).isActive = true
        self.bottomAnchor.constraint(equalTo: parent.bottomAnchor, constant: -offset).isActive = true
        self.leadingAnchor.constraint(equalTo: parent.leadingAnchor, constant: offset).isActive = true
        self.trailingAnchor.constraint(equalTo: parent.trailingAnchor, constant: -offset).isActive = true
    }
    
    func stretchViewBoundsByAddingConstraints(ofParent parent: UIView, withHorizontalOffset horizontal: CGFloat, withVertical vertical: CGFloat) {
        self.topAnchor.constraint(equalTo: parent.topAnchor, constant: vertical).isActive = true
        self.bottomAnchor.constraint(equalTo: parent.bottomAnchor, constant: -vertical).isActive = true
        self.leadingAnchor.constraint(equalTo: parent.leadingAnchor, constant: horizontal).isActive = true
        self.trailingAnchor.constraint(equalTo: parent.trailingAnchor, constant: -horizontal).isActive = true
    }
}
