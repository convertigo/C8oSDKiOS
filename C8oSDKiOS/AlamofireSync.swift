//
//  AlamofireSync.swift
//  C8oSDKiOS
//
//  Created by Charles Grimont on 02/03/2016.
//  Copyright © 2016 Convertigo. All rights reserved.
//

import Foundation
import Alamofire
extension Request {
    public func response() -> (request: NSURLRequest?, response: NSHTTPURLResponse?, data: NSData?, error: NSError?) {
        let semaphore = dispatch_semaphore_create(0)
        var result: (request: NSURLRequest?, response: NSHTTPURLResponse?, data: NSData?, error: NSError?)!
        self.response(completionHandler: { request, response, data, error in
            result = (
                request: request,
                response: response,
                data: data,
                error: error
            )
            dispatch_semaphore_signal(semaphore);
        })
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        return result
    }
    
    public func responseData() -> Response<NSData, NSError> {
        let semaphore = dispatch_semaphore_create(0)
        var result: Response<NSData, NSError>!
        self.responseData({ response in
            result = response
            dispatch_semaphore_signal(semaphore);
        })
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        return result
    }
    
    public func responseJSON(options options: NSJSONReadingOptions = .AllowFragments) -> Response<AnyObject, NSError> {
        let semaphore = dispatch_semaphore_create(0)
        var result: Response<AnyObject, NSError>!
        self.responseJSON(options: options, completionHandler: {response in
            result = response
            dispatch_semaphore_signal(semaphore);
        })
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        return result
    }
    
    public func responseString(encoding encoding: NSStringEncoding? = nil) -> Response<String, NSError> {
        let semaphore = dispatch_semaphore_create(0)
        var result: Response<String, NSError>!
        self.responseString(encoding: encoding, completionHandler: { response in
            result = response
            dispatch_semaphore_signal(semaphore);
        })
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        return result
    }
    
    public func responsePropertyList(options options: NSPropertyListReadOptions = NSPropertyListReadOptions()) -> Response<AnyObject, NSError> {
        let semaphore = dispatch_semaphore_create(0)
        var result: Response<AnyObject, NSError>!
        self.responsePropertyList(options: options, completionHandler: { response in
            result = response
            dispatch_semaphore_signal(semaphore);
        })
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        return result
    }
}
