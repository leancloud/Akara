import Foundation
import XCTest
@testable import Akara

class AkaraTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
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


    static var allTests : [(String, (AkaraTests) -> () throws -> Void)] {
        return [
            ("testExample", testExample),
        ]
    }
}
