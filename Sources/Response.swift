//
//  Response.swift
//  DemoCurl
//
//  Created by Tang Tianyong on 8/15/16.
//  Copyright © 2016 Tianyong Tang. All rights reserved.
//

import Foundation

public struct Response {
    public let code: Int
    public let headers: [String: String]
    public let body: String

    init(code: Int, headers: [String: String], body: String) {
        self.code    = code
        self.headers = headers
        self.body    = body
    }
}
