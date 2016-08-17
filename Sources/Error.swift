//
//  Error.swift
//  DemoCurl
//
//  Created by Tang Tianyong on 8/16/16.
//  Copyright © 2016 Tianyong Tang. All rights reserved.
//

import Foundation

/**
 Request error.

 A request may return an error in some cases,
 for example, when network is unavailable, server not found, etc.
 */
public struct Error {
    /// The error code, defined by cURL.
    public let code: Int

    /// The detail reason of error.
    public let message: String

    init(code: Int, message: String) {
        self.code    = code
        self.message = message
    }
}
