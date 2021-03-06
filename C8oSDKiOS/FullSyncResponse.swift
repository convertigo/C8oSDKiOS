//
//  FullSyncResponse.swift
//  C8oSDKiOS
//
//  Created by Charles Grimont on 31/03/2016.
//  Copyright © 2016 Convertigo. All rights reserved.
//

import Foundation

internal class FullSyncResponse {
	
	fileprivate static var fullSyncResponsesInstance: FullSyncResponse = FullSyncResponse()
	
	internal static let RESPONSE_KEY_OK: String = "ok";
	
	internal static let RESPONSE_KEY_DOCUMENT_ID: String = "id";
	
	internal static let RESPONSE_KEY_DOCUMENT_REVISION: String = "rev";
	
}

open class FullSyncAbstractResponse: NSObject {
	fileprivate var operationStatus: Bool?
	
	fileprivate init(operationStatus: Bool) {
		self.operationStatus = operationStatus
	}
	
	func getProperties() -> Dictionary<String, NSObject> {
		var properties: Dictionary<String, NSObject> = Dictionary<String, NSObject>()
        properties[FullSyncResponse.RESPONSE_KEY_OK] = self.operationStatus! as NSObject
		return properties
	}
	
}

internal class FullSyncDefaultResponse: FullSyncAbstractResponse {
	override init(operationStatus: Bool) {
		super.init(operationStatus: operationStatus)
	}
}

internal class FullSyncDocumentOperationResponse: FullSyncAbstractResponse {
	internal var documentId: String?
	internal var documentRevision: String?
	
	internal init(documentId: String, documentRevision: String, operationStatus: Bool) {
		super.init(operationStatus: operationStatus)
		self.documentId = documentId
		self.documentRevision = documentRevision
	}
	
	override internal func getProperties() -> Dictionary<String, NSObject> {
		var properties: Dictionary<String, NSObject> = super.getProperties()
        properties[FullSyncResponse.RESPONSE_KEY_DOCUMENT_ID] = self.documentId! as NSObject
        properties[FullSyncResponse.RESPONSE_KEY_DOCUMENT_REVISION] = self.documentRevision! as NSObject
		return properties
	}
	
}
