//
//  Promise+Foundation.swift
//  Hosyou
//
//  Created by Florent Vilmart on 16-11-06.
//  Copyright © 2016 Florent Vilmart. All rights reserved.
//

import Foundation

#if !NO_FOUNDATION

extension URLSession {
    typealias URLSessionDataTaskCallback = (URLSessionDataTask?) -> ()
    public func p_dataTask(with request: URLRequest,
                           dataTask callback: URLSessionDataTaskCallback = {_ in })
        -> Promise<(Data, URLResponse)> {
            return Promise { (resolve, reject) in
                var task: URLSessionDataTask?
                task = self.dataTask(with: request, completionHandler: { (data, response, error) in
                    if let data = data,
                        let response = response {
                        resolve((data, response))
                    } else if let error = error {
                        reject(error)
                    }
                    task = nil
                })
                task?.resume()
                callback(task)
            }
    }
}

#endif
