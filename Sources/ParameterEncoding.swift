//
//  ParameterEncoding.swift
//
//  Copyright (c) 2014-2016 Alamofire Software Foundation (http://alamofire.org/)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation

/**
 Parameter encodings.

 Used to specify the way in which a set of parameters are applied to a URL request.

 - url:             Creates a query string to be set as or appended to any existing URL query for `GET`, `HEAD`,
                    and `DELETE` requests, or set as the body for requests with any other HTTP method. The
                    `Content-Type` HTTP header field of an encoded request with HTTP body is set to
                    `application/x-www-form-urlencoded; charset=utf-8`. Since there is no published specification
                    for how to encode collection types, the convention of appending `[]` to the key for array
                    values (`foo[]=1&foo[]=2`), and appending the key surrounded by square brackets for nested
                    dictionary values (`foo[bar]=baz`).

 - urlEncodedInURL: Creates query string to be set as or appended to any existing URL query. Uses the same
                    implementation as the `.url` case, but always applies the encoded result to the URL.

 - json:            Uses `JSONSerialization` to create a JSON representation of the parameters object, which is
                    set as the body of the request. The `Content-Type` HTTP header field of an encoded request is
                    set to `application/json`.
 */
public enum ParameterEncoding {
    case url
    case urlEncodedInURL
    case json

    /**
     Encode parameters into request.

     - parameter request:    The request to have parameters applied.
     - parameter parameters: The parameters to apply.
     */
    public func encode(_ request: Request, parameters: [String: AnyObject]?) {
        guard let parameters = parameters else {
            return
        }

        switch self {
        case .url,
             .urlEncodedInURL:

            /**
             Convert parameters to query string.

             - parameter parameters: The parameters to be converted.

             - returns: The query string.
             */
            func query(_ parameters: [String: AnyObject]) -> String {
                var components: [(String, String)] = []

                for key in parameters.keys.sorted(by: <) {
                    let value = parameters[key]!
                    components += queryComponents(fromKey: key, value: value)
                }

                return (components.map { "\($0)=\($1)" } as [String]).joined(separator: "&")
            }

            /**
             Check if parameters can be encoded into URL for given method.

             - parameter method: The HTTP method.
             */
            func encodesParametersInURL(with method: String) -> Bool {
                switch self {
                case .urlEncodedInURL:
                    return true
                default:
                    break
                }

                let method = method.uppercased()

                switch method {
                case "GET",
                     "HEAD",
                     "DELETE":
                    return true
                default:
                    return false
                }
            }

            let method = request.method

            if encodesParametersInURL(with: method) {
                if
                    var URLComponents = URLComponents(url: request.url, resolvingAgainstBaseURL: false),
                    !parameters.isEmpty
                {
                    let percentEncodedQuery = (URLComponents.percentEncodedQuery.map { $0 + "&" } ?? "") + query(parameters)
                    URLComponents.percentEncodedQuery = percentEncodedQuery
                    request.url = URLComponents.url!
                }
            } else {
                if request.headers["Content-Type"] == nil {
                    request.headers["Content-Type"] = "application/x-www-form-urlencoded; charset=utf-8"
                }

                request.body = query(parameters).data(
                    using: String.Encoding.utf8,
                    allowLossyConversion: false
                )
            }
        case .json:
            let options = JSONSerialization.WritingOptions()

            #if os(OSX)
                let JSONObject = parameters
            #else
                let JSONObject = parameters.bridge()
            #endif

            let data = try! JSONSerialization.data(withJSONObject: JSONObject, options: options)

            if request.headers["Content-Type"] == nil {
                request.headers["Content-Type"] = "application/json"
            }

            request.body = data
        }
    }

    /// Creates percent-escaped, URL encoded query string components from the given key-value pair using recursion.
    ///
    /// - parameter key:   The key of the query component.
    /// - parameter value: The value of the query component.
    ///
    /// - returns: The percent-escaped, URL encoded query string components.
    public func queryComponents(fromKey key: String, value: AnyObject) -> [(String, String)] {
        var components: [(String, String)] = []

        if let dictionary = value as? [String: AnyObject] {
            for (nestedKey, value) in dictionary {
                components += queryComponents(fromKey: "\(key)[\(nestedKey)]", value: value)
            }
        } else if let array = value as? [AnyObject] {
            for value in array {
                components += queryComponents(fromKey: "\(key)[]", value: value)
            }
        } else {
            components.append((escape(key), escape("\(value)")))
        }

        return components
    }

    /// Returns a percent-escaped string following RFC 3986 for a query string key or value.
    ///
    /// RFC 3986 states that the following characters are "reserved" characters.
    ///
    /// - General Delimiters: ":", "#", "[", "]", "@", "?", "/"
    /// - Sub-Delimiters: "!", "$", "&", "'", "(", ")", "*", "+", ",", ";", "="
    ///
    /// In RFC 3986 - Section 3.4, it states that the "?" and "/" characters should not be escaped to allow
    /// query strings to include a URL. Therefore, all "reserved" characters with the exception of "?" and "/"
    /// should be percent-escaped in the query string.
    ///
    /// - parameter string: The string to be percent-escaped.
    ///
    /// - returns: The percent-escaped string.
    public func escape(_ string: String) -> String {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="

        // rdar://26850776
        // Crash in Xcode 8 Seed 1 when trying to mutate a CharacterSet with remove
        var allowedCharacterSet = NSMutableCharacterSet.urlQueryAllowed
        allowedCharacterSet.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")

        #if os(Linux)
            let result = string.bridge().stringByAddingPercentEncodingWithAllowedCharacters(allowedCharacterSet) ?? string
        #else
            let result = string.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) ?? string
        #endif

        return result
    }
}
