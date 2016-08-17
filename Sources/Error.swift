//
//  Error.swift
//  DemoCurl
//
//  Created by Tang Tianyong on 8/16/16.
//  Copyright © 2016 Tianyong Tang. All rights reserved.
//

import Foundation

public class Error {
    public let code: Int
    public let message: String

    init(code: Int, message: String) {
        self.code    = code
        self.message = message
    }
}
