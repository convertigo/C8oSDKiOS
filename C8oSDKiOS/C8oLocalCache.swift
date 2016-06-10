//
//  C8oLocalCache.swift
//  C8oSDKiOS
//
//  Created by Charles Grimont on 18/02/2016.
//  Copyright © 2016 Convertigo. All rights reserved.
//

import Foundation

public class C8oLocalCache: NSObject {
	public static var PARAM: String = "__localCache"
	
	public class Priority {
		
		var isAvailable: (c8o: C8o) -> (Bool)
		
		public static var SERVER: Priority = Priority(isAvailable: { (c8o) -> (Bool) in
			return true
		})
		public static var LOCAL: Priority = Priority(isAvailable: { (c8o) -> (Bool) in
			return true
		})
		
		public init (isAvailable: (c8o: C8o) -> (Bool)) {
			self.isAvailable = isAvailable
		}
		
	}
	
	internal var priority: C8oLocalCache.Priority?
	internal var ttl: Int
	internal var enabled: Bool
	
	/**

	 Example usage:
	 @see http://www.convertigo.com/document/convertigo-client-sdk/programming-guide/ for more information.
	 @param priority : String
	 @param ttl : Int
	 @param enabled : Bool

	 */
	public init(priority: Priority?, ttl: Int = -1, enabled: Bool = true) throws {
		if (priority == nil) {
			throw C8oException(message: "Local Cache priority cannot be null")
		}
		self.priority = priority
		self.ttl = ttl
		self.enabled = enabled
	}
}
