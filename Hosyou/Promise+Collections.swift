//
//  Promise+Collections.swift
//  Hosyou
//
//  Created by Florent Vilmart on 16-11-06.
//  Copyright © 2016 Florent Vilmart. All rights reserved.
//


import Foundation

extension Promise {
    public static func all<T>(promises: [Promise<T>]) -> Promise<[T]> {
        let promise = Promise<[T]>()
        var cnt = promises.count
        var results: [T?] = Array(repeating: nil, count: cnt)
        var rejected = false

        let handle = { (idx: Int) -> ((Any?) -> Void) in
            return {
                // throw on the 1st error
                if let err = $0 as? Error {
                    promise.reject(error: err)
                    rejected = true
                }
                if let val = $0 as? T {
                    results[idx] = val
                }
                cnt -= 1
                if cnt <= 0 && !rejected {
                    promise.resolve(value: results.flatMap({ $0 }))
                }
            }
        }
        promises.enumerated().forEach {
            let h = handle($0)
            $1.then(h, h)
        }
        return promise
    }
}
