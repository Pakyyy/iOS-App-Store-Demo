//
//  Dynamic.swift
//  AppStoreDemo
//
//  Created by Patrick Tang on 8/7/2021.
//

import Foundation

class Dynamic<T> {
    
    typealias Listener = (T) -> ()
    
    var listener: Listener?
    var value: T {
        didSet {
            self.fire()
        }
    }
    
    init(_ value: T) {
        self.value = value
    }
    
    func bind(_ listener: Listener?) {
        self.listener = listener
    }
    
    func bindAndFire(_ listener: Listener?) {
        self.listener = listener
        listener?(value)
    }
    
    internal func fire() {
        self.listener?(value)
    }
    
}
