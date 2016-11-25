//
//  ThrowableDictionary.swift
//  JSONParser
//
//  Created by Lukas Schmidt on 25.03.16.
//  Copyright © 2016 Lukas Schmidt. All rights reserved.
//

import Foundation

public struct ThrowableDictionary {
    public let dictionary: Dictionary<String, Any>
    let parser = FoundationParser()
    
    public init(dictionary: Dictionary<String, Any>) {
        self.dictionary = dictionary
    }
    
    public func valueFor<T: JSONParsable>(keyPath: String? = nil) throws -> T {
        
        return try parser.parse( dictionary as Any, keyPath: keyPath)
    }
    
    public func valueFor<T: Collection>(keyPath: String) throws -> T where T._Element: JSONParsable {
        return try parser.parse( dictionary as Any, keyPath: keyPath)
    }
    
    public func valueFor<T: ExpressibleByDictionaryLiteral>(keyPath: String) throws -> T where T.Value: JSONParsable {
        return try parser.parse( dictionary as Any, keyPath: keyPath)
    }
}
