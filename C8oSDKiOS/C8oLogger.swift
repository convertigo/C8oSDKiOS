//
//  C8oLogger.swift
//  C8oSDKiOS
//
//  Created by Charles Grimont on 05/02/2016.
//  Copyright © 2016 Convertigo. All rights reserved.
//

import Foundation
import CoreFoundation
import SwiftyJSON
import Fuzi
import AEXML



public class C8oLogger
{
    private let RE_FORMAT_TIME : NSRegularExpression =  try! NSRegularExpression(pattern: "(\\d*?)(?:,|.)(\\d{3}).*", options: [])
    //*** Constants ***//
    
    
    
    private static var LOG_TAG :String  = "c8o";
    private static var LOG_INTERNAL_PREFIX :String = "[c8o] ";
    
    
    
    static let  REMOTE_LOG_LIMIT : Int = 100;
    
    
    private static var JSON_KEY_REMOTE_LOG_LEVEL  : String = "remoteLogLevel";
    private static var JSON_KEY_TIME  : String = "time";
    private static var JSON_KEY_LEVEL  : String = "level";
    private static var JSON_KEY_MESSAGE  : String = "msg";
    private static var JSON_KEY_LOGS  : String = "logs";
    private static var JSON_KEY_ENV  : String = "env";
    
    /** Attributes */
    
    private var remoteLogUrl : String?;
    private var remoteLogs : Queue<JSON>?
    private var alreadyRemoteLogging : [Bool]?;
    private var remoteLogLevel : C8oLogLevel?;
    private var uidRemoteLogs :String?;
    private var startTimeRemoteLog : NSDate?;
    
    private var c8o : C8o;
    
    private var env : String
    
    internal init(c8o :C8o)
    {
        self.c8o = c8o;
        
        remoteLogUrl = self.c8o.EndpointConvertigo + "/admin/services/logs.Add";
        remoteLogs = Queue<JSON>();
        alreadyRemoteLogging = [Bool]()
        alreadyRemoteLogging?.append(false)
        
        remoteLogLevel = C8oLogLevel.TRACE;
        
        let currentTime = NSDate();
        startTimeRemoteLog = currentTime;
        uidRemoteLogs = C8oTranslator.DoubleToHexString(C8oUtils.GetUnixEpochTime(currentTime)!);
        let envJSON : JSON = ["uid" : uidRemoteLogs!, "uuid" : c8o.DeviceUUID, "project" : c8o.EndpointProject]
        env = String(envJSON)
    }
    
    private func IsLoggableRemote(logLevel : C8oLogLevel?) ->Bool
    {
        return c8o.LogRemote && logLevel != nil && C8oLogLevel.TRACE.priority <= remoteLogLevel!.priority && remoteLogLevel!.priority <= logLevel!.priority;
    }
    
    private func IsLoggableConsole(logLevel : C8oLogLevel?) ->Bool
    {
        return logLevel != nil && C8oLogLevel.TRACE.priority <= c8o.LogLevelLocal.priority && c8o.LogLevelLocal.priority <= logLevel!.priority;
    }
    
    /** Basics log */
    public func CanLog(logLevel : C8oLogLevel) ->Bool
    {
        return IsLoggableConsole(logLevel) || IsLoggableRemote(logLevel);
    }
    
    public var IsFatal : Bool
        {
        get { return CanLog(C8oLogLevel.FATAL); }
    }
    
    public var IsError : Bool
        {
        get { return CanLog(C8oLogLevel.ERROR); }
    }
    
    public var IsWarn  : Bool
        {
        get { return CanLog(C8oLogLevel.WARN); }
    }
    
    public var IsInfo  : Bool
        {
        get { return CanLog(C8oLogLevel.INFO); }
    }
    
    public var IsDebug  : Bool
        {
        get { return CanLog(C8oLogLevel.DEBUG); }
    }
    
    public var IsTrace  : Bool
        {
        get { return CanLog(C8oLogLevel.TRACE); }
    }
    
    internal func Log(logLevel: C8oLogLevel, var message:String , exception: C8oSDKiOS.C8oException?! = nil) ->Void
    {
        let isLogConsole : Bool = IsLoggableConsole(logLevel);
        let isLogRemote : Bool = IsLoggableRemote(logLevel);
        
        if (isLogConsole || isLogRemote)
        {
            if (exception != nil)
            {
                message += "\n" + String(exception)
            }
            
            let time : String = String(NSDate().timeIntervalSinceDate(startTimeRemoteLog!))
            //let stringLevel : String = remoteLogLevel[logLevel]
            
            if (isLogRemote)
            {
                remoteLogs!.enqueue(JSON(
                    [C8oLogger.JSON_KEY_TIME : time,
                        C8oLogger.JSON_KEY_LEVEL : logLevel.name,
                        C8oLogger.JSON_KEY_MESSAGE : message
                    ]));
                LogRemote();
            }
            
            if (isLogConsole)
            {
                debugPrint("(" + time + ") [" + logLevel.name + "] " + message)
                
            }
        }
    }
    
    public func Fatal(message: String, exceptions: C8oSDKiOS.C8oException? = nil) ->Void
    {
        Log(C8oLogLevel.FATAL, message: message, exception: exceptions);
    }
    
    public func Error(message: String, exceptions: C8oSDKiOS.C8oException?  = nil) -> Void
    {
        Log(C8oLogLevel.ERROR, message: message, exception: exceptions);
    }
    
    public func Warn(message: String, exceptions: C8oSDKiOS.C8oException?  = nil) -> Void
    {
        Log(C8oLogLevel.WARN, message: message, exception: exceptions);
    }
    
    public func Info(message: String, exceptions: C8oSDKiOS.C8oException? = nil) -> Void
    {
        Log(C8oLogLevel.INFO, message: message, exception: exceptions);
    }
    
    public func Debug(message: String, exceptions: C8oSDKiOS.C8oException?  = nil) -> Void
    {
        Log(C8oLogLevel.DEBUG, message: message, exception: exceptions);
    }
    
    public func Trace(message: String, exceptions: C8oSDKiOS.C8oException?  = nil) -> Void
    {
        Log(C8oLogLevel.TRACE, message: message, exception: exceptions);
    }
    
    internal func _Log(logLevel : C8oLogLevel, messages : String, exceptions : C8oSDKiOS.C8oException?)->Void
    {
        if (c8o.LogC8o)
        {
            Log(logLevel, message: C8oLogger.LOG_INTERNAL_PREFIX + messages, exception: exceptions);
        }
    }
    
    internal func _Fatal(message: String, exceptions: C8oSDKiOS.C8oException?) -> Void
    {
        _Log(C8oLogLevel.FATAL, messages: message, exceptions: exceptions);
    }
    
    internal func _C8oException(message: String, exceptions:C8oSDKiOS.C8oException?) -> Void
    {
        _Log(C8oLogLevel.ERROR, messages: message, exceptions: exceptions);
    }
    
    internal func _Warn(message: String, exceptions: C8oSDKiOS.C8oException?) -> Void
    {
        _Log(C8oLogLevel.WARN, messages: message, exceptions: exceptions);
    }
    
    internal func _Info(message: String, exceptions: C8oSDKiOS.C8oException?) -> Void
    {
        _Log(C8oLogLevel.INFO, messages: message, exceptions: exceptions);
    }
    
    internal func _Debug(message: String, exceptions: C8oSDKiOS.C8oException?) -> Void
    {
        _Log(C8oLogLevel.DEBUG, messages: message, exceptions: exceptions);
    }
    
    internal func _Trace(message: String, exceptions: C8oSDKiOS.C8oException?) -> Void
    {
        _Log(C8oLogLevel.TRACE, messages: message, exceptions: exceptions);
    }
    
    internal func LogRemote() ->Void
    {
        var canLog : Bool  = false;
        let condition : NSCondition = NSCondition()
        
        condition.lock()
        
        // If there is no another thread already logging AND there is at least one log
        canLog = !alreadyRemoteLogging![0] && remoteLogs!.Count() > 0;
        if (canLog)
        {
            alreadyRemoteLogging![0] = true;
        }
        
        condition.unlock()
        
        if(canLog)
        {
            let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
            dispatch_async(dispatch_get_global_queue(priority, 0)){
                
                // Take logs in the queue and add it to a json array
                var count : Int = 0;
                let listSize : Int = self.remoteLogs!.Count();
                var logsArray = Array<JSON>()
                
                while (count < listSize && count < C8oLogger.REMOTE_LOG_LIMIT)
                {
                    logsArray.append(self.remoteLogs!.dequeue()!);
                    count++;
                }
                
                // Initializes request paramters
                var uidS: String =  "{\"uid\":\""
                uidS += self.uidRemoteLogs!
                uidS += "\"}";
                var parameters = Dictionary<String, NSObject>();
                parameters =
                    
                    [C8oLogger.JSON_KEY_LOGS: String(logsArray),
                        C8oLogger.JSON_KEY_ENV: self.env,
                        C8o.ENGINE_PARAMETER_DEVICE_UUID: self.c8o.DeviceUUID]
                ;
                
                var jsonResponse : JSON;
                do
                {
                    let webResponse : (data : NSData?, error : NSError?) = self.c8o.httpInterface!.HandleRequest(self.remoteLogUrl!, parameters: parameters);
                    if(webResponse.error != nil){
                        self.c8o.LogRemote = false;
                        if (self.c8o.LogOnFail != nil)
                        {
                            self.c8o.LogOnFail!(exception: C8oException(message: C8oExceptionMessage.RemoteLogFail(), exception: webResponse.error!), parameters: nil);
                        }
                        return
                    }
                    else{
                        jsonResponse = C8oTranslator.DataToJson(webResponse.data!)!
                    }
                    
                }
                catch let e as NSError
                {
                    
                }
                
                var logLevelResponse = jsonResponse[C8oLogger.JSON_KEY_REMOTE_LOG_LEVEL];
                
                if (logLevelResponse != nil)
                {
                    var logLevelResponseStr : String = logLevelResponse.stringValue
                    var c8oLogLevel = C8oLogLevel.GetC8oLogLevel(logLevelResponseStr);
                    
                    if (c8oLogLevel != nil)
                    {
                        self.remoteLogLevel = c8oLogLevel!;
                    }
                    
                    condition.lock()
                    self.alreadyRemoteLogging![0] = false;
                    condition.unlock()
                    self.LogRemote();
                    
                }
            };
                
                /*dispatch_async(dispatch_get_main_queue()){
                   
                };*/
        }
    }
    /** Others log */
    
    
    internal func LogMethodCall(methodName : String, parameters : NSObject...)-> Void
    {
        if (c8o.LogC8o && IsDebug)
        {
            var methodCallLogMessage : String = "Method call : " + methodName;
            if (IsTrace && parameters.count > 0)
            {
                methodCallLogMessage += "\n" + String(parameters);
                _Trace(methodCallLogMessage, exceptions: nil);
                
            }
            else
            {
                _Debug(methodCallLogMessage, exceptions: nil);
            }
        }
    }
    
    
    internal func LogC8oCall(url : String, parameters : Dictionary<String, NSObject>)->Void
    {
        if (c8o.LogC8o && IsDebug)
        {
            var c8oCallLogMessage : String = "C8o call : " + url;
            
            if (parameters.count > 0)
            {
                c8oCallLogMessage += "\n" + String(parameters);
            }
            
            _Debug(c8oCallLogMessage, exceptions: nil);
        }
    }
    
    
    internal func LogC8oCallXMLResponse(response : AEXMLDocument, url: String, parameters : Dictionary<String, NSObject>)-> Void
    {
        LogC8oCallResponse(C8oTranslator.XmlToString(response)!, responseType: "XML", url: url, parameters: parameters);
    }
    
    
    internal func LogC8oCallJSONResponse(response : JSON, url : String, parameters : Dictionary<String, NSObject>)-> Void
    {
        //LogC8oCallResponse(C8oTranslator.JsonToString(response), "JSON", url, parameters);
    }
    
    internal func LogC8oCallResponse(responseStr : String, responseType : String, url: String, parameters : Dictionary<String, NSObject>)-> Void
    {
        if(c8o.LogC8o && IsTrace)
        {
            var c8oCallResponseLogMessage : String = "C8o call " + responseType + " response : " + url;
            
            if (parameters.count > 0)
            {
                //c8oCallResponseLogMessage += "\n" + JsonConvert.SerializeObject(parameters);
            }
            
            c8oCallResponseLogMessage += "\n" + responseStr;
            
            _Trace(c8oCallResponseLogMessage, exceptions: nil);
        }
    }
}

public class C8oLogLevel
{
    //
    private static var JSON_KEY_REMOTE_LOG_LEVEL  : String = "remoteLogLevel";
    //
    
    internal static var NULL : C8oLogLevel = C8oLogLevel(name: "", priority: 0);
    public static var  NONE : C8oLogLevel = C8oLogLevel(name: "none", priority: 1);
    public static var TRACE : C8oLogLevel = C8oLogLevel(name: "trace", priority: 2);
    public static var DEBUG : C8oLogLevel = C8oLogLevel(name: "debug", priority: 3);
    public static var INFO : C8oLogLevel = C8oLogLevel(name: "info", priority: 4);
    public static var WARN : C8oLogLevel = C8oLogLevel(name: "warn", priority: 5);
    public static var ERROR : C8oLogLevel = C8oLogLevel(name: "error", priority: 6);
    public static var FATAL : C8oLogLevel = C8oLogLevel(name: "fatal", priority: 7);
    
    internal static var C8O_LOG_LEVELS : [C8oLogLevel] = [ NULL, NONE, TRACE, DEBUG, INFO, WARN, ERROR, FATAL ];
    
    internal var name : String;
    internal var priority: Int;
    
    private init(name : String, priority : Int)
    {
        self.name = name;
        self.priority = priority;
    }
    
    internal static func GetC8oLogLevel(name : String) ->C8oLogLevel?
    {
        for c8oLogLevel in C8oLogLevel.C8O_LOG_LEVELS
        {
            if (c8oLogLevel.name == name)
            {
                return c8oLogLevel;
            }
        }
        return nil;
    }
}
