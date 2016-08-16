import XCTest
@testable import Akara

class AkaraTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        XCTAssertEqual(Akara().text, "Hello, World!")
    }


    static var allTests : [(String, (AkaraTests) -> () throws -> Void)] {
        return [
            ("testExample", testExample),
        ]
    }
}
