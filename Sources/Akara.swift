//
//  Akara.swift
//  DemoCurl
//
//  Created by Tang Tianyong on 8/15/16.
//  Copyright © 2016 Tianyong Tang. All rights reserved.
//

import Foundation
import Surl

private final
class WriteData {
    var header = [Int8]()
    var body   = [Int8]()

    init() {}
}

private
typealias CurlCallback = @convention(c) (
    input  : UnsafeMutablePointer<Int8>,
    size   : Int,
    nmemb  : Int,
    output : UnsafeMutablePointer<Void>) -> Int

private
let headerFunction: CurlCallback = { (input, size, nmemb, output) -> Int in
    let realSize = size * nmemb

    guard realSize > 0 else { return 0 }

    let writeData = unsafeBitCast(output, to: WriteData.self)
    var pointer   = input

    for _ in 0..<realSize {
        writeData.header.append(pointer.pointee)
        pointer = pointer.successor()
    }

    return realSize
}

private
let writeFunction: CurlCallback = { (input, size, nmemb, output) -> Int in
    let realSize = size * nmemb

    guard realSize > 0 else { return 0 }

    let writeData = unsafeBitCast(output, to: WriteData.self)
    var pointer   = input

    for _ in 0..<realSize {
        writeData.body.append(pointer.pointee)
        pointer = pointer.successor()
    }

    return realSize
}

private
func headerName(string: String) -> String? {
    if let range = string.range(of: ":") {
        return string.substring(to: range.lowerBound).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }

    return nil
}

private
func headerValue(string: String) -> String? {
    if let range = string.range(of: ":") {
        return string.substring(from: range.upperBound).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }

    return nil
}
private
func parseHeader(string: String) -> [String: String] {
    var headers: [String: String] = [:]
    let headerLines = string.components(separatedBy: "\r\n")

    headerLines.forEach { (line) in
        if let name = headerName(string: line) {
            headers[name] = headerValue(string: line) ?? ""
        }
    }

    return headers
}

public
func perform(_ request: Request) -> Result {
    let curl      = request.curl
    let writeData = WriteData()
    let output    = unsafeBitCast(writeData, to: UnsafeMutablePointer<Void>.self)

#if os(Linux)
    curl_easy_setopt_pointer(curl, CURLOPT_FILE, output)
    curl_easy_setopt_pointer(curl, CURLOPT_WRITEHEADER, output)
#else
    curl_easy_setopt_pointer(curl, CURLOPT_WRITEDATA, output)
    curl_easy_setopt_pointer(curl, CURLOPT_HEADERDATA, output)
#endif

    curl_easy_setopt_func(curl, CURLOPT_WRITEFUNCTION, unsafeBitCast(writeFunction, to: curl_func.self))
    curl_easy_setopt_func(curl, CURLOPT_HEADERFUNCTION, unsafeBitCast(headerFunction, to: curl_func.self))

    let code = curl_easy_perform(curl)

    /* Add null to the end of string. */
    writeData.body.append(0)
    writeData.header.append(0)

    if code == CURLE_OK {
        var code = 0
        curl_easy_getinfo_long(curl, CURLINFO_RESPONSE_CODE, &code)

        let body     = String(cString: writeData.body, encoding: String.Encoding.utf8) ?? ""
        let header   = String(cString: writeData.header, encoding: String.Encoding.utf8) ?? ""
        let headers  = parseHeader(string: header)
        let response = Response(code: code, headers: headers, body: body)

        return .success(response: response)
    } else {
        let message = String(cString: curl_easy_strerror(code), encoding: String.Encoding.utf8) ?? ""
        let error   = Error(code: Int(code.rawValue), message: message)

        return .failure(error: error)
    }
}
