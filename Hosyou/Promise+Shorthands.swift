//
//  Promise+Shorthands.swift
//  Hosyou
//
//  Created by Florent Vilmart on 16-11-06.
//  Copyright © 2016 Florent Vilmart. All rights reserved.
//

extension Promise {

    /**
     Continuation method that will be triggered only if the promise succeeds

     Any previous error will be rethrown down to the next error handler, and ignored if
     another error is yeilded

     - Parameter resolver: an resolve callback that will be called when the promise is resolved
     - Returns: a new promise, typed with the type returned by the resolver
     */
    @discardableResult
    public func then<U>(_ resolver: ((T) throws -> U)?) -> Promise<U> {
        return then(resolver, { throw $0 })
    }

    /**
     Continuation method that will be triggered only if the promise succeeds

     Any previous error will be rethrown down to the next error handler, and ignored if
     another error is yeilded

     - Parameter resolver: an resolve callback that will be called when the promise is resolved
     - Returns: a new promise, typed with the type of the promise returned by the resolver
     */
    @discardableResult
    public func then<U>(_ resolver: ((T) throws -> Promise<U>)?) -> Promise<U> {
        return then(resolver, { throw $0 })
    }

    /**
     Continuation method that will be triggered only if the promise succeeds

     Any previous error will be rethrown down to the next error handler, and ignored if
     another error is yeilded

     - Parameter resolver: an resolve callback that will be called when the promise is resolved
     - Returns: a new promise, typed with the current type of the promise, optional
     */
    @discardableResult
    public func then(_ resolver: ((T) throws -> Void)?) -> Promise<T?> {
        return then(resolver, { throw $0 })
    }

    /**
     Continuation method that will be triggered only if the promise fails

     Any previous error will available in the callback making it a nice handler to catch errors.

     - Parameter resolver: an resolve callback that will be called when the promise gets rejected
     - Returns: a new promise, typed with the current type of the promise, optional
     */
    @discardableResult
    public func fail<U>(_ resolver: ((Error) throws -> U)?) -> Promise<U> {
        return then(nil, resolver)
    }

    /**
     Continuation method that will be triggered only if the promise fails

     Any previous error will available in the callback making it a nice handler to catch errors.

     - Parameter resolver: an resolve callback that will be called when the promise gets rejected
     - Returns: a new promise, typed with the current type of the promise, optional
     */
    @discardableResult
    public func fail<U>(_ resolver: ((Error) throws -> Promise<U>)?) -> Promise<U> {
        return then(nil, resolver)
    }

    /**
     Continuation method that will be triggered only if the promise fails

     Any previous error will available in the callback making it a nice handler to catch errors.

     - Parameter resolver: an resolve callback that will be called when the promise gets rejected
     - Returns: a new promise, typed with the current type of the promise, optional
     */
    @discardableResult
    public func fail(_ resolver: ((Error) throws -> Void)?) -> Promise<T?> {
        return then(nil, resolver)
    }
}
