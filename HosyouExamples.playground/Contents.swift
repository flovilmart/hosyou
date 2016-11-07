//: Playground - noun: a place where people can play

import UIKit
import Hosyou

//: [Previous](@previous)

import Foundation
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

let str = "Hello World!"
struct SomeError: Error {}

let p = Promise<Int>()

p.then {
    print("1 \($0)")
}
p.then {
    print("2 \($0)")
}
print("Will resolve")
p.resolve(value: 10)
p.then {
    print("3 \($0)")
}
p.then {
    print("4 \($0)")
}

p.resolve(value: 20)
//
//let p = Promise(value: 10).then({ (value) -> Int in
// return 2
//}, nil)
//
//let p2: Promise<String> = Promise(value: 10).then({ (value) -> Promise<Int> in
//    return .resolved(2)
//}).then({ _ -> String in
//    return ""
//}).then({ (value) -> Promise<String> in
//    return .resolved("Hello!")
//})
//
//let p1: Promise<String> =  Promise(value: 10).then({ val -> String in
//    return "Some"
//})
//
//let pn = p1.then({ (val) -> Void in
//    print("Val")
//    return
//}, nil)
//
//p1.then({ (val) -> Void in
//    print("Val")
//}, nil)
//
//let prom = Promise(value: 10).then({ (value) -> Promise<Int> in
//    return Promise<Int>(error: SomeError())
//}).then({ (val) -> Promise<Int> in
//    //
//    print("THEN: \(val)")
//    return .resolved(val)
//}, { err -> Promise<Int> in
//    print("ERR: \(err)")
//    return .resolved(0)
//}).then({ (val) -> Promise<Int> in
//    print("Val \(val)")
//    return Promise(value: 20)
//}).then({ (value) -> Promise<Int> in
//    print("Value \(value)")
//    return Promise<Int>.resolved(0).then({ (val) -> Int in
//        print("val \(val)")
//        return 1
//    }).then({ (val) -> Int in
//        print("val \(val)")
//        return 3
//    }).then({ (val) -> Int in
//        print("val \(val)")
//        return 4
//    }).then({ (val) -> Int in
//        print("val \(val)")
//        return 5
//    })
//}).then({ (val) -> Int in
//    print("Final! \(val)")
//    return 9
//}).then({ (value: Int) -> String in
//    return "Hello!"
//}).then({ _ in
//    return 2.0
//}).then({ _ in
//    return ["key": "value"]
//}).then({ (val) -> Void in
//    print("\(val)")
//    return
//}).then({ (val) -> Void in
//    print("\(val)")
//    return
//}).then({ (value) -> Promise<String> in
//    print("\(value)")
//    return .resolved("dsad")
//})
//
//let pVoid = Promise(value: 10).then({ (value) in
//    print("Fiest Then")
//    return
//}).then({ (val) -> Promise<String> in
//    print("Other THen")
//    return .resolved("String")
//})
//
//var promise = Promise<Int> { (resolve, reject) in
//    resolve(0)
//}.then({
//    print($0)
//    return
//}).then({ (val) -> Promise<Int> in
//    print("\(val)")
//    return Promise.resolved(0)
//})
//
//
//
///*.then { (val:Int) -> Int in
// print("VAL: \(val)")
// return val
// }*/
//
//let pAl = Promise<[Int?]>.all(promises: [Promise(value: 2), Promise(value: nil)])
////
//pAl.then({ (res:[Int?]) -> Void in
//    print("Values: \(res)")
//    return
//})
//
//let pal2 = Promise<[Int]>.all(promises: [Promise(value: 2), Promise(error: SomeError()), Promise(value: 3)])
//pal2.then({ (res:[Int]) -> Void in
//    print("Values: \(res)")
//    return
//}, {
//    print("\($0)")
//    return
//})
//
//var c = 0;
//var cancel: () -> () = {}
//let emitter = Promise(emittingAtInterval: 1, event: { () -> Int in
//    c = c+1
//    if c == 10 {
//        cancel()
//    }
//    return c
//}, cancel: &cancel)
////
//emitter.then({
//    print("\($0)")
//    return
//})
////struct SomeError: Error {}
//
//promise = Promise<Int>()
//
//promise.fail({ (err) -> Promise<Any>? in
//    print("FAILED!")
//    return nil
//})
//
//promise.then({ val -> Promise<Float> in
//    print("\(val)")
//    return Promise(value: 20.0)
//}).then({ val -> Promise<Bool> in
//    print("Valu2 \(val)")
//    return Promise(value: true)
//})
//
//promise.resolve(value: 10)
//promise.then({ (val) -> Promise<NSObject> in
//    print("After \(val)")
//    promise.reject(error: SomeError())
//    return Promise(value: NSObject())
//})
//
//Promise(value: 10, delay: 1).then({ _ in
//    print("Value!")
//    return
//}).then({ _ -> Promise<Int> in
//    print("OK!")
//    return Promise(value: 1000, delay: 1)
//}).then({
//    print("Value Aggain \($0)")
//    return
//})

typealias SomeTuple = (Int, Int)
Promise<SomeTuple>((1,3)).then({ (a,b) in
    print("\(a), \(b)")
    throw SomeError()
}).then({ (val) -> SomeTuple in
    print("AVal")
    return (2,3)
}, {
    print("\($0)")
    return (4,5)
}).on(queue: .main).then { (val) -> Void in
    print("\(val)")
    return
    }.then {
        return (1,2)
    }.then { (val) -> String in
        return "Hello!"
}

Promise(1).then { _ in
    throw SomeError()
}.then { _ in
    return
}.then({ _ in
    return
}, { err in
    print("\(err)")
    return
})

print("Done!")

let delayed: Int? = try? await(timeout: .seconds(3)) {
    Promise(value: 1, delay: 2, queue: DispatchQueue(label: "delayqueue"))
}


print("delayed \(delayed)")
let r = try? await { Promise(value: 1, delay: 2, queue: DispatchQueue(label: "delayqueue")) }

print("AWAIT OK!!")
//print("\(res)")
print("Thread \(Thread.current)")

let urlRequest = URLRequest(url: URL(string: "http://google.com")!)

let r2: (Data, URLResponse)? = try? await {
    URLSession.shared.p_dataTask(with: urlRequest)
}


//
//Promise(value: 1).then {_ -> Error in
//    return SomeError()
//}.fail { _ in
//    print("Fail")
//    return nil
//}.then { val -> Void in
//    print("\(val)")
//    return
//}
