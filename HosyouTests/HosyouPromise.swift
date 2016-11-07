//
//  HosyouTests.swift
//  HosyouTests
//
//  Created by Florent Vilmart on 16-11-06.
//  Copyright © 2016 Florent Vilmart. All rights reserved.
//

import XCTest
@testable import Hosyou
import Quick
import Nimble

class MockError: Error {}

class HosyouPromiseSpec: QuickSpec {
    override func spec() {
        describe("promise resolution") {
            it("should handle base promise") {
                let promise = Promise(1)
                var val: Int?
                promise.then {
                    val = $0
                    return
                }
                expect(val).to(equal(1))
            }

            it("should handle base promise synchronously") {
                let promise = Promise<Int>()
                var val: Int?
                promise.then {
                    val = $0
                    return
                }
                promise.resolve(value: 1)
                expect(val).to(equal(1))
            }

            it("should chain synchronous promises") {
                let promise = Promise<Int>()
                var done = false
                promise.then { (val) -> Promise<Int> in
                    expect(val).to(equal(1))
                    return Promise(2)
                }.then {
                    expect($0).to(equal(2))
                    done = true
                    return
                }
                promise.resolve(value: 1)
                expect(done).to(equal(true))
            }

            it("should chain synchronous promises with raw types") {
                let promise = Promise<Int>()
                var done = false
                promise.then { (val) -> Int in
                    expect(val).to(equal(1))
                    return 2
                }.then {
                    expect($0).to(equal(2))
                    done = true
                    return
                }
                promise.resolve(value: 1)
                expect(done).to(equal(true))
            }

            it("should handle errors") {
                let promise = Promise<Int>()
                var errored = false
                promise.then { (val) -> Promise<Int> in
                    expect(val).to(equal(1))
                    return Promise(MockError())
                }.then({ _ in
                    fail("Should not be reached")
                    return
                }, { err in
                    errored = true
                    expect(err is MockError).to(equal(true))
                    return
                })
                promise.resolve(value: 1)
                expect(errored).to(equal(true))
            }

            it("should handle errors thrown") {
                let promise = Promise<Int>()
                var errored = false
                promise.then { (val) -> Promise<Int> in
                    expect(val).to(equal(1))
                    throw MockError()
                }.then({ _ in
                    fail("Should not be reached")
                    return
                }).then({ _ in
                    fail("Should not be reached")
                    return
                }).fail { err in
                    errored = true
                    expect(err is MockError).to(equal(true))
                    return
                }.then({ _ in
                    return
                }, { err in
                    fail("Should not be reached")
                    return
                })
                promise.resolve(value: 1)
                expect(errored).to(equal(true))
            }

            it("should handle errors thrown") {
                let promise = Promise<Int>()
                var errored = false
                promise.then { (val) -> Promise<Int> in
                    expect(val).to(equal(1))
                    throw MockError()
                }.then({ _ -> Int in
                    fail("Should not be reached")
                    return 1
                }).then({ _ -> Int in
                    fail("Should not be reached")
                    return 1
                }).fail { err -> Int in
                    errored = true
                    expect(err is MockError).to(equal(true))
                    return 1
                }.then({ _ in
                    return
                }, { err in
                    fail("Should not be reached")
                    return
                })
                promise.resolve(value: 1)
                expect(errored).to(equal(true))
            }

            it("should handle errors thrown") {
                let promise = Promise<Int>()
                var errored = false
                promise.then { (val) -> Promise<Int> in
                    expect(val).to(equal(1))
                    throw MockError()
                }.then({ _ -> Promise<Int> in
                    fail("Should not be reached")
                    return Promise(1)
                }).then({ _ -> Promise<Int> in
                    fail("Should not be reached")
                    return Promise(1)
                }).fail { err -> Promise<Int> in
                    errored = true
                    expect(err is MockError).to(equal(true))
                    return Promise(1)
                }.then({ _ in
                    return
                }, { err in
                    fail("Should not be reached")
                    return
                })
                promise.resolve(value: 1)
                expect(errored).to(equal(true))
            }

            it("should handle errors when passed") {
                let promise = Promise<Int>()
                var errored = false
                promise.then({ _ in
                    fail("Should not be reached")
                    return
                }, { err in
                    errored = true
                    expect(err is MockError).to(equal(true))
                    return
                })
                promise.reject(error: MockError())
                expect(errored).to(equal(true))
            }

            it("should support Promise with CB initialization") {
                var called = false
                Promise<Int>({ (resolve, reject) in
                    resolve(1)
                }).then {
                    called = true
                    expect($0).to(equal(1))
                    return
                }
                expect(called).to(equal(true))
            }

            it("should support Error throwing with CB initialization") {
                var called = false
                Promise<Int>({ (resolve, reject) in
                    throw MockError()
                }).then({ _ in
                    fail("Should not be reached")
                    return
                }, { err in
                    called = true
                    expect(err is MockError).to(equal(true))
                    return
                })
                expect(called).to(equal(true))
            }
        }
    }
}
