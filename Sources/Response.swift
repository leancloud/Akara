//
//  Response.swift
//  DemoCurl
//
//  Created by Tang Tianyong on 8/15/16.
//  Copyright © 2016 Tianyong Tang. All rights reserved.
//

import Foundation

/**
 Response of requset.

 This struct represents server's response.
 */
public struct Response {
    /// The HTTP code.
    public let code: Int

    /// The HTTP headers.
    public let headers: [String: String]

    /// The HTTP body.
    public let body: String

    init(code: Int, headers: [String: String], body: String) {
        self.code    = code
        self.headers = headers
        self.body    = body
    }
}
