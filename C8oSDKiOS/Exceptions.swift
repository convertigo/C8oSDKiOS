//
//  Exceptions.swift
//  C8oSDKiOS
//
//  Created by Charles Grimont on 18/02/2016.
//  Copyright © 2016 Convertigo. All rights reserved.
//

import Foundation


public class C8oException : NSError
{
    public static let NSC8oErrorDomain : String = "com.convertigo.clientsdk.exception.C8oException"
    
    public init( message : String, exception : NSError?){
        
       super.init(domain: C8oException.NSC8oErrorDomain, code: exception!.code, userInfo: [NSLocalizedFailureReasonErrorKey: message])
        
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private static func FilterMessage(var message : String, exception : NSError)->String
    {
        
        if (exception is C8oException)
        {
            message = String(exception) + " | " + message;
        }
        return message;
    }
    
    private static func FilterException(exception : NSError)->NSError
    {
    /*if (exception is C8oException)
    {
    return null;
    }*/
    return exception;
    }
}

public class C8oHttpException : NSError
{
    public init(message : String, innerException : NSError)
    {
        super.init(domain: "com.convertigo.C8o.Error", code: C8oCode.C8oHttpException.rawValue as Int, userInfo: [NSLocalizedFailureReasonErrorKey: message])
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public class C8oRessourceNotFoundException : NSError
{
    public init(message : String, innerException : NSError)
    {
        super.init(domain: "com.convertigo.C8o.Error", code: C8oCode.C8oRessourceNotFoundException.rawValue as Int, userInfo: [NSLocalizedFailureReasonErrorKey: message])
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public class C8oUnavailableLocalCacheException : NSError
{
    
    public init(message : String, innerException : NSError)
    {
        super.init(domain: "com.convertigo.C8o.Error", code: C8oCode.C8oUnavailableLocalCacheException.rawValue as Int, userInfo: [NSLocalizedFailureReasonErrorKey: message])
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }}

public enum C8oError : ErrorType {
    
    case InvalidArgument(String)
    case ArgumentException(String)
    case C8oException(String)
    case ArgumentNilException(String)
    
    }

public enum C8oCode: Int {
    case C8oUnavailableLocalCacheException  = -6000
    case C8oRessourceNotFoundException      = -6001
    case C8oHttpException                   = -6002
    case InvalidArgument                    = -6003
    case ArgumentException                  = -6004
    case C8oException                       = -6005
    
}


         