//
//  ThreadSafeInt.swift
//  CFT_TestProject
//
//  Created by Alexander on 27/11/2018.
//  Copyright © 2018 Alexander. All rights reserved.
//

import Foundation

final class ThreadSafeInt {
    
    private var internalInt = 0
    private let queue = DispatchQueue(label: "ThreadSafeInt",
                                      attributes: .concurrent)
    
    var int: Int {
        get {
            var result = 0
            queue.sync { [weak self] in
                result = self?.internalInt ?? 0
            }
            return result
        }
        set {
            queue.async(flags: .barrier) { [weak self] in
                self?.internalInt = newValue
            }
        }
    }
}
