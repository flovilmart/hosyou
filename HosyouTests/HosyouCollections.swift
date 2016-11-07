//
//  HosyouTests.swift
//  HosyouTests
//
//  Created by Florent Vilmart on 16-11-06.
//  Copyright © 2016 Florent Vilmart. All rights reserved.
//

@testable import Hosyou
import Quick
import Nimble

class HosyouCollections: QuickSpec {
    override func spec() {
        describe("collections") {
            it("resolve with all values") {
                Promise<Int>.all(promises: [Promise(2), Promise(1)]).then { (res: [Int]) in
                    expect(res[0]).to(equal(2))
                    expect(res[1]).to(equal(1))
                    return
                }
            }

            it("fails when one fails") {
                Promise<Int>.all(promises: [Promise(2), Promise(MockError()), Promise(1)]).then({ (res: [Int]) in
                    fail("should not")
                    return
                }, { err in
                    expect(err is MockError).to(equal(true))
                })
            }
        }
    }
}
