//
//  Request.swift
//  DemoCurl
//
//  Created by Tang Tianyong on 8/15/16.
//  Copyright © 2016 Tianyong Tang. All rights reserved.
//

import Foundation
import Surl

/**
 HTTP Request.
 */
public final class Request: NSObject, NSCopying {
    /// Request URL.
    public var url: URL

    /// HTTP method.
    public var method = "GET"

    /// HTTP headers.
    public var headers: [String: String] = [:]

    /// HTTP body.
    ///
    /// - note: The HTTP body and parameters that encoded into body are mutually exclusive -
    ///         only one can be set on a given request.
    public var body: Data?

    /// Request timeout, in millisecond. If <= 0, it never times out.
    public var timeout: TimeInterval = 0

    /// Curl object.
    var curl: UnsafeMutablePointer<Void>? {
        let curl = curl_easy_init()

        /* Set Request URL. */

        curl_easy_setopt_string(curl, CURLOPT_URL, url.absoluteString)

        /* Apply HTTP method. */

        let method = self.method.uppercased()

        switch method {
        case "GET":
            curl_easy_setopt_long(curl, CURLOPT_HTTPGET, 1)
        case "POST":
            curl_easy_setopt_long(curl, CURLOPT_HTTPPOST, 1)
        default:
            curl_easy_setopt_string(curl, CURLOPT_CUSTOMREQUEST, method);
        }

        /* Set HTTP headers. */

        var header_list: UnsafeMutablePointer<curl_slist>? = nil

        headers.forEach { (fieldName, value) in
            header_list = curl_slist_append(header_list, "\(fieldName): \(value)")
        }

        curl_easy_setopt_slist(curl, CURLOPT_HTTPHEADER, header_list);

        /* Set HTTP body. */

        if let body = body, body.count > 0 {
            let utf8 = String.Encoding.utf8.rawValue
            let cstring = NSString(data: body, encoding: utf8)?.cString(using: utf8)

            curl_easy_setopt_string(curl, CURLOPT_POSTFIELDS, cstring)
        }

        /* Set request timeout. */

        if (timeout > 0) {
            curl_easy_setopt_long(curl, CURLOPT_TIMEOUT_MS, Int(timeout))
        }

        return curl
    }

    /**
     Initialize request with URL.
     */
    public init(url: URL) {
        self.url = url
    }

    public func copy(with zone: NSZone? = nil) -> AnyObject {
        let request = Request(url: url)

        request.method  = method
        request.headers = headers
        request.body    = body

        return request
    }

    /**
     Set parameters for request.

     - note: This method may alter `url` or `body` according to encoding.
     */
    public func addParameters(_ parameters: [String: Any], encoding: ParameterEncoding) {
        var bridged: [String: AnyObject] = [:]

        #if os(OSX)
            parameters.forEach { bridged["\($0)"] = $1 as? AnyObject }
        #else
            parameters.bridge().forEach { bridged["\($0)"] = $1 }
        #endif

        encoding.encode(self, parameters: bridged)
    }
}
