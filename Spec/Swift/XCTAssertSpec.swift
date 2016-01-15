import Cedar
import XCTest

class XCTAssertSpec: CDRSpec {
    override func declareBehaviors() {
        describe("XCTAssert calls in a Swift Cedar spec") {
            it("should allow a passing assertion") {
                XCTAssertEqual(1, 1)
            }

            it("should allow a failing assertion") {
                expectFailureWithMessage("XCTAssertEqual failed: (\"Optional(1)\") is not equal to (\"Optional(2)\") - Failure") {
                    XCTAssertEqual(1, 2, "Failure")
                }
            }
        }
    }
}
