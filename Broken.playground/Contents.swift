//: Playground - noun: a place where people can play

import UIKit

//
//  Promise.swift
//  Hosyou
//
//  Created by Florent Vilmart on 16-11-06.
//  Copyright © 2016 Florent Vilmart. All rights reserved.
//

import Foundation

private enum State<T> {
    // swiftlint:disable type_name
    case pending
    case resolved(T)
    case rejected(Error)
    // swiftlint:enable type_name
}

internal func callOut<U>(_ callbacks: [(U) -> ()], _ value: U) {
    callbacks.forEach { $0(value) }
}

internal func makeContinuation<U, V, W>(promise: Promise<V>,
                               _ resolver: ((U) throws -> W)?) -> (U) -> () {

    let resolve = { (value: U) in
        let resolution = try resolver?(value)
        if let resolution = resolution as? Promise<V> {
            resolution.then(promise.resolve, promise.reject)
        } else if let resolution = resolution as? V {
            promise.resolve(value: resolution)
        }
    }

    return { value in
        do {
            try resolve(value)
        } catch let e {
            promise.reject(error: e)
        }
    }
}

public class Promise<T> {

    private typealias Resolver = (T) -> ()
    private typealias Errorer = (Error) -> ()
    private var state: State<T> = .pending
    private var resolvers = [Resolver]()
    private var errorers = [Errorer]()

    /**
     Creates a new Promise that is neither resolved nor rejected

     Call promise.resolve() or promise.reject() to seal the fate of the promise.

     - Returns: a new non-resolved promise
     */
    public init() {}

    /**
     Creates a new Promise with a value of type T

     - Parameter value: the value which the Promise resolved to
     - Returns: a new Promise<T>
     */
    public init(_ value: T) {
        resolve(value: value)
    }

    /**
     Creates a new rejected Promise

     - Parameter error: Error the error that will be available in rejection handlers
     - Returns: a new Promise<T>
     */
    public init(_ error: Error) {
        reject(error: error)
    }
    /**
     Creates a new Promise with resolution callbacks

     - Parameter callback: a closure with two arguments,
     a resolution function and a rejection function
     - Parameter resolve: A closure to call to indicate the promise was resolved
     - Parameter reject: A closure to call to indicate your promise was rejected
     - Parameter result: The result of type T to pass to the resolve callback
     - Parameter error: The error to pass to the reject callback to reject the promise
     - Returns: a new Promise<T> that will resolve when either resolve or reject are called
     */
    public convenience init(_ callback: (_ resolve: @escaping (_ result: T) -> (),
        _ reject: @escaping (_ error: Error) -> ())
        throws -> ()) {
        self.init()
        do {
            try callback(self.resolve, self.reject)
        } catch let error {
            reject(error: error)
        }
    }

    /**
     Resolves the promise

     - Parameter value: The result of the promise
     - Returns: Void
     */
    public func resolve(value newValue: T) {
        state = .resolved(newValue)
        callOut(resolvers, newValue)
    }

    /**
     Rejects the Promise

     This will cause the rejection handlers to be called with the error

     - Parameter error: The error for the promise
     - Returns: Void
     */
    public func reject(error: Error) {
        state = .rejected(error)
        callOut(errorers, error)
    }

    /**
     Continuation method

     - Parameter resolver: a resolver callback that will be called when the promise is resolved
     - Parameter errorer: an error callback that will be called when the promise is rejected
     - Parameter result: the result of the current promise
     - Parameter error: the error for a failed promise
     - Returns: a new promise, that will resolve when the resolver or the errorer will return.
     */
    @discardableResult
    public func then<U>(_ resolver: ((_ result: T) throws -> U)?,
                     _ errorer: ((_ error: Error) throws -> U)?) -> Promise<U> {
        let promise = Promise<U>()
        then(makeContinuation(promise: promise, resolver),
             makeContinuation(promise: promise, errorer))
        return promise
    }

    /**
     Continuation method

     - Parameter resolver: a resolver callback that will be called when the promise is resolved
     - Parameter errorer: an error callback that will be called when the promise is rejected
     - Returns: a new promise, that will resolve when either
     the Promise<U> returned by the resolver or the errorer will resolve
     */
    @discardableResult
    public func then<U>(_ resolver: ((T) throws -> Promise<U>)?,
                     _ errorer: ((Error) throws -> Promise<U>)?) -> Promise<U> {
        let promise = Promise<U>()
        then(makeContinuation(promise: promise, resolver),
             makeContinuation(promise: promise, errorer))
        return promise
    }

    /**
     Continuation method

     - Parameter resolver: a resolver callback that will be called when the promise is resolved
     - Parameter errorer: an error callback that will be called when the promise is rejected
     - Returns: a new promise, that will resolve when the current promise resolves
     */
    @discardableResult
    public func then(_ resolver: ((T) throws -> ())?,
                     _ errorer: ((Error) throws -> ())? = nil) -> Promise<T?> {
        return then({ (res) -> T? in
            try resolver?(res)
            return nil
        }, { (err) -> T? in
            try errorer?(err)
            return nil
        })
    }

    private func then(_ resolver: @escaping (T) -> (), _ errorer: @escaping (Error) -> ()) {
        switch state {
        case .resolved(let value):
            resolver(value)
            break
        case .rejected(let error):
            errorer(error)
        default:
            break
        }
        resolvers.append(resolver)
        errorers.append(errorer)
    }
}


let p = Promise("String").then({ (val) -> Promise<String> in
    return Promise("OtherString")
}, nil)
