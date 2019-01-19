//
//  FilterOperation.swift
//  CFT_TestProject
//
//  Created by Alexander on 27/11/2018.
//  Copyright © 2018 Alexander. All rights reserved.
//

import Foundation

final class FilterOperation: Operation {
    
    var action: () -> Void
    
    override init() {
        action = { }
        super.init()
    }
    
    override func main() {
        if isCancelled {
            return
        }
        action()
    }
}
