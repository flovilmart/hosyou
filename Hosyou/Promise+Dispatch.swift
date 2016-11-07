//
//  Promise+Dispatch.swift
//  Hosyou
//
//  Created by Florent Vilmart on 16-11-06.
//  Copyright © 2016 Florent Vilmart. All rights reserved.
//


import Foundation

let awaitDispatchQueue = DispatchQueue(label: "com.promise.await")

extension Promise {
    public convenience init(value: T, delay: TimeInterval, queue: DispatchQueue = .main) {
        self.init()
        queue.asyncAfter(deadline: DispatchTime.now() + .milliseconds(Int(delay * 1000))) {
            self.resolve(value: value)
        }
    }

    public convenience init(emittingAtInterval interval: TimeInterval,
                            event: @escaping ((Void) throws -> T),
                            cancel: inout ()->()) {
        self.init()
        let source = DispatchSource.makeTimerSource()
        source.setEventHandler {
            do {
                let value = try event()
                self.resolve(value: value)
            } catch let e {
                self.reject(error: e)
            }
        }
        source.scheduleRepeating(deadline: .now(),
                                 interval: .milliseconds(Int(interval*1000)))
        cancel = {
            source.cancel()
        }
        source.resume()
    }
}

extension Promise {

    @discardableResult
    public func on(queue: DispatchQueue) -> Promise<T> {
        func async<A, T>(_ queue: DispatchQueue, _ promise: Promise<T>) -> (A) -> Promise<T> {
            return { (val: A) -> Promise<T> in
                queue.async {
                    if let val = val as? T {
                        promise.resolve(value: val)
                    } else if let val = val as? Error {
                        promise.reject(error: val)
                    }
                }
                return promise
            }
        }
        let promise = Promise<T>()
        then(async(queue, promise), async(queue, promise))
        return promise
    }
}

struct TimeoutError: Error {
    let timeout: DispatchTimeInterval
}

public func await<T>(on queue: DispatchQueue = awaitDispatchQueue,
                     timeout: DispatchTimeInterval = .seconds(10),
                     _ promise: @escaping () -> (Promise<T>)) throws -> T {
    var result: T? = nil
    var error: Error!
    let semaphore = DispatchSemaphore(value: 0)
    Promise(true).on(queue: queue).then({ _ -> Promise<T> in
        promise()
    }).then({
        result = $0
        semaphore.signal()
    }, {
        error = $0
        semaphore.signal()
    })

    switch semaphore.wait(timeout: .now() + timeout) {
    case .success:
        guard let result = result else {
            throw error
        }
        return result
    case .timedOut:
        throw TimeoutError(timeout: timeout)
    }
}
