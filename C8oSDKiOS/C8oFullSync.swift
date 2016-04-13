//
//  C8oFullSync.swift
//  C8oSDKiOS
//
//  Created by Charles Grimont on 18/02/2016.
//  Copyright © 2016 Convertigo. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

import CouchbaseLite


internal class C8oFullSync
{
    public static var FULL_SYNC_URL_PATH : String = "/fullsync/";
    /// <summary>
    /// The project requestable value to execute a fullSync request.
    /// </summary>
    public static var FULL_SYNC_PROJECT : String = "fs://";
    public static var FULL_SYNC__ID : String = "_id";
    public static var FULL_SYNC__REV : String = "_rev";
    public static var FULL_SYNC__ATTACHMENTS : String = "_attachments";
    
    public static var FULL_SYNC_DDOC_PREFIX : String = "_design";
    public static var FULL_SYNC_VIEWS : String = "views";
    
    internal var c8o : C8o?;
    internal var fullSyncDatabaseUrlBase : String?
    internal var localSuffix : String?;
    
    internal init(c8o : C8o)
    {
        self.c8o = c8o;
        fullSyncDatabaseUrlBase = c8o.endpointConvertigo + C8oFullSync.FULL_SYNC_URL_PATH;
        localSuffix = (c8o.fullSyncLocalSuffix != nil) ? c8o.fullSyncLocalSuffix : "_device";
    }

    
    internal func handleFullSyncRequest(parameters : Dictionary<String, NSObject>, listener : C8oResponseListener)throws ->NSObject?
    {
        // Checks if this is really a fullSync request (even if this is normally already checked)
        var projectParameterValue = try! C8oUtils.peekParameterStringValue(parameters, name: C8o.ENGINE_PARAMETER_PROJECT, exceptionIfMissing: true);
        
        if (!projectParameterValue!.hasPrefix(C8oFullSync.FULL_SYNC_PROJECT))
        {
            throw C8oException(message: C8oExceptionMessage.invalidParameterValue(projectParameterValue!, details: "its don't start with " + C8oFullSync.FULL_SYNC_PROJECT));
        }

        // Gets the sequence parameter to know which fullSync requestable to use
        var fullSyncRequestableValue : String = try! C8oUtils.peekParameterStringValue(parameters, name: C8o.ENGINE_PARAMETER_SEQUENCE, exceptionIfMissing: true)!;
        var fullSyncRequestable : FullSyncEnum.FullSyncRequestable? = FullSyncEnum.FullSyncRequestable.getFullSyncRequestable(fullSyncRequestableValue);
        if (fullSyncRequestable == nil)
        {
            throw C8oException(message: C8oExceptionMessage.invalidParameterValue(C8o.ENGINE_PARAMETER_PROJECT, details: C8oExceptionMessage.unknownValue("fullSync requestable", value: fullSyncRequestableValue)));
        }
        
        // Gets the database name if this is not specified then if takes the default database name
        var index1 = projectParameterValue!.startIndex.advancedBy(C8oFullSync.FULL_SYNC_PROJECT.characters.count)
        var databaseName : String? = projectParameterValue!.substringFromIndex(index1)
        if (databaseName!.length < 1)
        {
            databaseName = c8o!.defaultDatabaseName;
            if (databaseName == nil)
            {
                throw C8oException(message: C8oExceptionMessage.invalidParameterValue(C8o.ENGINE_PARAMETER_PROJECT, details: C8oExceptionMessage.missingValue("fullSync database name")));
            }
        }
        
        var response : NSObject?;
        do
        {
            response = try fullSyncRequestable!.handleFullSyncRequest(self, databaseName: databaseName!, parameters: parameters, c8oResponseListener: listener);
        }
        catch let e as C8oException
        {
            throw  C8oException(message: C8oExceptionMessage.FullSyncRequestFail(), exception: e);
        }
        
        if (response == nil)
        {
            throw C8oException(message: C8oExceptionMessage.couchNullResult());
        }

        response = handleFullSyncResponse(response!,listener:  listener);
        return response;
    }
    
  internal func handleFullSyncResponse(var response : AnyObject, listener : C8oResponseListener)->NSObject
    {
        /*if (response is JSON)
        {
            if (listener is C8oResponseXmlListener)
            {
                //response = C8oFullSyncTranslator.FullSyncJsonToXml(response as JSON);
            }
        }*/
        
        return response as! NSObject;
    }
    

    /*internal func handleGetDocumentRequest(fullSyncDatatbaseName : String, docid : String, parameters : Dictionary<String, NSObject>)throws ->CBLDocument
    {
        fatalError("Must Override")
    }

  internal func handleDeleteDocumentRequest(fullSyncDatatbaseName : String, docid :  String, parameters : Dictionary<String, NSObject>)throws ->FullSyncDocumentOperationResponse?//Task<object>
    {
        fatalError("Must Override")
    }
    

    
  internal func handlePostDocumentRequest(fullSyncDatatbaseName : String, fullSyncPolicy : FullSyncEnum.FullSyncPolicy, parameters : Dictionary<String, NSObject>)throws->NSObject?//Task<object>
    {
        fatalError("Must Override")
    }
    

    
  internal func handleAllDocumentsRequest(DatatbaseName : String, parameters : Dictionary<String, NSObject>)throws ->NSObject?//->Task<object>
    {
        fatalError("Must Override")
    }

    
    internal func handleGetViewRequest(databaseName : String, ddocName : String?, viewName : String?, parameters : Dictionary<String, NSObject>)throws->CBLQueryEnumerator?//->Task<object>
    {
        fatalError("Must Override")
    }
    

    
    internal func handleSyncRequest(databaseName : String, parameters : Dictionary<String, NSObject>, c8oResponseListener : C8oResponseListener)throws->VoidResponse?//->Task<object>
    {
        fatalError("Must Override")
    }
    
    internal func handleReplicatePullRequest(databaseName : String, parameters : Dictionary<String, NSObject>, c8oResponseListener : C8oResponseListener)throws->VoidResponse?//->Task<object>
    {
        fatalError("Must Override")
    }
    
    internal func handleReplicatePushRequest(databaseName : String, parameters : Dictionary<String, NSObject>, c8oResponseListener : C8oResponseListener)throws->VoidResponse?//->Task<object>
    {
        fatalError("Must Override")
    }
    
    
    internal func handleResetDatabaseRequest(databaseName : String)throws->FullSyncDefaultResponse?{
        fatalError("Must Override")
    }

    internal func handleCreateDatabaseRequest(databaseName : String)throws->FullSyncDefaultResponse?{
        fatalError("Must Override")
    }
    

    internal func handleDestroyDatabaseRequest(databaseName : String)throws->FullSyncDefaultResponse?//->Task<object>
    {
        fatalError("Must Override")
    }
    

    internal func getResponseFromLocalCache(c8oCallRequestIdentifier : String)throws->NSObject?//->Task<C8oLocalCacheResponse>
    {
        fatalError("Must Override")
    }
    

    internal func saveResponseToLocalCache(c8oCallRequestIdentifier : String, localCacheResponse : NSObject?/*C8oLocalCacheResponse*/)throws->NSObject?//->Task
    {
        fatalError("Must Override")
    }*/
    

    internal static func isFullSyncRequest(requestParameters : Dictionary<String, NSObject>)->Bool
    {
        // Check if there is one parameter named "__project" and if its value starts with "fs://"
        if let parameterValue : String = C8oUtils.getParameterStringValue(requestParameters, name: C8o.ENGINE_PARAMETER_PROJECT, useName: false){
            return parameterValue.hasPrefix(C8oFullSync.FULL_SYNC_PROJECT);
        }
            return false;
       

    }
}