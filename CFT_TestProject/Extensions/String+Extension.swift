//
//  String+Extension.swift
//  CFT_TestProject
//
//  Created by Alexander on 18/11/2018.
//  Copyright © 2018 Alexander. All rights reserved.
//

import Foundation

extension String {
    /**
     method returns localized string with default comment and self name
     - returns: localized string
     */
    func localized() -> String {
        let localizedString = NSLocalizedString(self,
                                                comment: "")
        return localizedString
    }
}
