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

class HosyouDispatch: QuickSpec {
    override func spec() {
        describe("async") {
            it("should resolve asynchronously") {
                var called = false
                waitUntil(timeout: 5.0) { done in
                    let promise = Promise(value: 1, delay: 0.1)
                    promise.then {
                        called = true
                        expect($0).to(equal(1))
                        done()
                    }
                    expect(called).to(equal(false))
                }
                expect(called).to(equal(true))
            }

            it("handles an event emitter") {
                var called = 0
                waitUntil(timeout: 5.0) { done in
                    var cancelHandler = {}
                    Promise(emittingAtInterval: 0.2, event: { () -> Int in
                        return 0
                    }, cancel: &cancelHandler)
                    .then { _ in
                        called = called+1
                        if called == 3 {
                            cancelHandler()
                            done()
                        }
                    }
                }
                expect(called).to(equal(3))
            }

            it("handles an event emitter that throws") {
                var called = 0
                var errorCalls = 0
                var successCalls = 0
                waitUntil(timeout: 5.0) { done in
                    var cancelHandler = {}
                    Promise(emittingAtInterval: 0.4, event: { () -> Int in
                        if called % 2 == 0 {
                            throw MockError()
                        }
                        return called
                    }, cancel: &cancelHandler)
                    .then({ _ in
                        successCalls = successCalls + 1
                        called = called + 1
                    }, { _ in
                        errorCalls = errorCalls + 1
                        called = called + 1
                        if called == 3 {
                            cancelHandler()
                            done()
                        }
                    })
                }
                expect(successCalls).to(equal(1))
                expect(errorCalls).to(equal(2))
                expect(called).to(equal(3))
            }

            it("handles queue switching") {
                let queue = DispatchQueue.global(qos: .background)
                var called = false
                waitUntil(timeout: 5.0) { done in
                    Promise(value: 1, delay: 0, queue: queue)
                        .on(queue: .main).then { _ in
                        expect(Thread.current == .main).to(equal(true))
                        called = true
                        done()
                        return
                    }
                    return
                }
                expect(called).to(equal(true))
            }

            it("handles queue switching with error") {
                let queue = DispatchQueue.global(qos: .background)
                var called = false
                waitUntil(timeout: 5.0) { done in
                    Promise(value: 1, delay: 0, queue: queue).then { _ in
                        throw MockError()
                    }.on(queue: .main).then({ _ in
                        fail("Should not succeed")
                        done()
                        return
                    }, { _ in
                        expect(Thread.current == Thread.main).to(equal(true))
                        called = true
                        done()
                        return
                    })
                }
                 expect(called).to(equal(true))
            }

            it("awaits") {
                let value = try? await {
                    Promise(value: 1, delay: 0.5, queue: .global(qos: .background))
                }
                expect(value).to(equal(1))
            }

            it("awaits with error") {
                do {
                    _ = try await {
                        Promise(value: 1, delay: 0.5, queue: .global(qos: .background)).then { _ in
                            throw MockError()
                        }
                    }
                    fail("Should have thrown an error")
                } catch let err {
                    expect(err is MockError).to(equal(true))
                }
            }

            it("awaits with timeout") {
                do {
                    _ = try await(timeout: .seconds(1)) {
                        Promise(value: 1, delay: 2.0, queue: .global(qos: .background)).then { _ in
                            throw MockError()
                        }
                    }
                    fail("Should have thrown an error")
                } catch let err {
                    expect(err is TimeoutError).to(equal(true))
                }
            }
        }
    }
}
