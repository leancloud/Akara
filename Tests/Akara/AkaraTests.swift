import Foundation
import XCTest
@testable import Akara

class AkaraTests: XCTestCase {
    func testGet() {
        let url     = URL(string: "https://api.leancloud.cn/1.1/ping")
        let request = Request(url: url!)
        let result  = Akara.perform(request)

        switch result {
        case .success(let response):
            XCTAssertTrue(response.body.contains("pong"))
        case .failure:
            XCTFail()
        }
    }

    func testPost() {
        let url     = URL(string: "https://httpbin.org/post")
        let request = Request(url: url!)

	let parameters: [String: Any] = [
            "foo": "bar",
            "baz": [
                "aaa": "bbb"
            ]
        ]

        request.addParameters(parameters, encoding: .json)
        let result  = Akara.perform(request)

        switch result {
        case .success(let response):
            XCTAssertTrue(response.body.contains("foo") && response.body.contains("bbb"))
        case .failure:
            XCTFail()
        }
    }


    static var allTests : [(String, (AkaraTests) -> () throws -> Void)] {
        return [
            ("testGet", testGet), ("testPost", testPost)
        ]
    }
}
