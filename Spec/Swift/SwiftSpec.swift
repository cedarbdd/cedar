import Cedar

#if !EXCLUDE_SWIFT_SPECS

/// A very simple function for making assertions since Cedar provides no
/// matchers usable from Swift
private func expectThat(value: Bool, file: String = __FILE__, line: UInt = __LINE__) {
    if !value {
        CDRSpecFailure.specFailureWithReason("Expectation failed", fileName: file, lineNumber: Int32(line)).raise()
    }
}

private var globalValue__: String?

/// This mirrors `SpecSpec`
class SwiftSpecSpec: CDRSpec {
    override func declareBehaviors() {
        describe("SwiftSpec") {
            beforeEach {
//                NSLog("=====================> I should run before all specs.")
            }

            afterEach {
//                NSLog("=====================> I should run after all specs.")
            }

            describe("a nested spec") {
                beforeEach {
//                    NSLog("=====================> I should run only before the nested specs.")
                }

                afterEach {
//                    NSLog("=====================> I should run only after the nested specs.")
                }

                it("should also run") {
//                    NSLog("=====================> Nested spec")
                }

                it("should also also run") {
//                    NSLog("=====================> Another nested spec")
                }
            }

            context("a nested spec (context)") {
                beforeEach {
//                    NSLog("=====================> I should run only before the nested specs.")
                }

                afterEach {
//                    NSLog("=====================> I should run only after the nested specs.")
                }

                it("should also run") {
//                    NSLog("=====================> Nested spec")
                }

                it("should also also run") {
//                    NSLog("=====================> Another nested spec")
                }
            }

            it("should run") {
//                NSLog("=====================> Spec")
            }

            it("should be pending", PENDING)
            it("should also be pending", nil)
            xit("should also be pending (xit)") {}

            describe("described specs should be pending", PENDING)
            describe("described specs should also be pending", nil)
            xdescribe("xdescribed specs should be pending") {}
            
            context("contexted specs should be pending", PENDING)
            context("contexted specs should also be pending", nil)
            xcontext("xcontexted specs should be pending") {};
            
            describe("empty describe blocks should be pending") {}
            context("empty context blocks should be pending") {}
        }

        describe("subjectAction") {
            var value: Int = 0

            subjectAction { value = 5 }

            beforeEach {
                value = 100
            }

            it("should run after the beforeEach") {
                expectThat(value == 5)
            }

            describe("in a nested describe block") {
                beforeEach {
                    value = 200
                }

                it("should run after all the beforeEach blocks") {
                    expectThat(value == 5)
                }
            }
        }

        describe("a describe block") {
            beforeEach {
                globalValue__ = nil
            }

            describe("that contains a beforeEach in a shared example group") {
                itShouldBehaveLike("a describe context that contains a beforeEach in a Swift shared example group")

                it("should not run the shared beforeEach before specs outside the shared example group") {
                    expectThat(globalValue__ == nil)
                }
            }

            describe("that passes a value to the shared example context") {
                beforeEach {
                    globalValue__ = "something"
                    CDRSpecHelper.specHelper().sharedExampleContext["value"] = globalValue__
                }

                itShouldBehaveLike("a Swift shared example group that receives a value in the context")
            }

            describe("that passes a value in-line to the shared example context") {
                beforeEach {
                    globalValue__ = "something"
                }

                expectThat(globalValue__ == nil)
                itShouldBehaveLike("a Swift shared example group that receives a value in the context") {
                    $0["value"] = globalValue__
                }
            }

            itShouldBehaveLike("a Swift shared example group that contains a failing spec")
        }

        describe("a describe block that tries to include a shared example group that doesn't exist") {
            expectExceptionWithReason("Unknown shared example group with description: 'a unicorn'") {
                itShouldBehaveLike("a unicorn")
            }
        }
    }
}

class SharedExampleGroupPoolForSwiftSpecs: CDRSharedExampleGroupPool {
    override func declareSharedExampleGroups() {
        sharedExamplesFor("a describe context that contains a beforeEach in a Swift shared example group") { _ in
            beforeEach {
                expectThat(CDRSpecHelper.specHelper().sharedExampleContext.count == 0)
                globalValue__ = ""
            }

            it("should run the shared beforeEach before specs inside the shared example group") {
                expectThat(globalValue__ != nil)
            }
        }

        sharedExamplesFor("a Swift shared example group that receives a value in the context") { context in
            it("should receive the values set in the global shared example context") {
                expectThat((context["value"] as? String) == globalValue__)                  
            }
        }

        sharedExamplesFor("a Swift shared example group that contains a failing spec") { _ in
            it("should fail in the expected fashion") {
                expectFailureWithMessage("Expectation failed") {
                    expectThat("wibble" == "wobble")
                }
            }
        }
    }
}

#endif
