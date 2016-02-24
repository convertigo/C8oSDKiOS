//
//  C8oExceptionListener.swift
//  C8oSDKiOS
//
//  Created by Charles Grimont on 17/02/2016.
//  Copyright © 2016 Convertigo. All rights reserved.
//

import Foundation


public class C8oExceptionListener
{
    public var OnException :  (Dictionary<NSException, Dictionary<String, NSObject>>?)->()
    
    init(OnException : (params : Dictionary<NSException, Dictionary<String, NSObject>>?)->())
    {
        self.OnException = OnException;
    }
}