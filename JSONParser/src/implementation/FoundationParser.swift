//
//  FoundationParser.swift
//  JSONParser
//
//  Created by Lukas Schmidt on 11.04.16.
//  Copyright © 2016 Lukas Schmidt. All rights reserved.
//

import Foundation

public struct FoundationParser {
    
    public init() {}
    
    public func parse<Result: JSONParsable>(container: AnyObject, keyPath: String?) throws -> Result {
        func parseIt(typedContainer: Dictionary<String, AnyObject>) throws -> Result {
            let trowableDict = ThrowableDictionary(dictionary: typedContainer)
            return try Result(JSON: trowableDict)
        }
        return try parse(container, keyPath: keyPath, parseFunction: parseIt)
    }
    
    public func parse<Result: DictionaryLiteralConvertible where Result.Value: JSONParsable>(container: AnyObject, keyPath: String?) throws -> Result {
        func parseIt(typedContainer: Dictionary<String, Dictionary<String, AnyObject>>) throws -> Result {
            var result = Dictionary<String, Result.Value>()
            for (_, (key, dictionary)) in typedContainer.enumerate() {
                let trowableDict = ThrowableDictionary(dictionary: dictionary)
                let element = try Result.Value(JSON: trowableDict)
                result[key] = element
            }
            return result as! Result
        }
        
       return try parse(container, keyPath: keyPath, parseFunction: parseIt)
    }
    
    public func parse<T: _ArrayType where T.Element: JSONParsable>(container: AnyObject, keyPath: String?) throws -> T {
        func parseIt(typedContainer: Array<Dictionary<String, AnyObject>>) throws -> T {
            let result: Array<T.Element> = try typedContainer.map{ jsonObj in
                let trowableDict = ThrowableDictionary(dictionary: jsonObj)
                return try T.Element(JSON: trowableDict)
            }
            return result as! T
        }
        
        return try parse(container, keyPath: keyPath, parseFunction: parseIt)
    }
    
    public func parseFoundationObject<T>(data: AnyObject, keyPath: String?) throws -> T {
        if let rootDictionary = data as? [String: AnyObject], let keyPath = keyPath where !keyPath.isEmpty {
            if let targetData = getValueForKeyPathFromDictionary(rootDictionary, keyPath: keyPath), let typedTargetData = targetData as? T {
                return typedTargetData
            }else {
                throw ParseError.MissingKey(keyPath ?? "Root keypath")
            }
        }
        
        if let targetData = data as? T {
            return targetData
        }
        throw ParseError.InvalidValue(keyPath ?? "Root keypath", String(data.self))
    }
    
    public func getValueForKeyPathFromDictionary(dictionary: Dictionary<String, AnyObject>, keyPath: String) -> AnyObject? {
        let paths = keyPath.componentsSeparatedByString(".")
        var dict: Dictionary<String, AnyObject>? = dictionary
        for(i, path) in paths.enumerate() {
            guard let value = dict?[path] else {
                return nil
            }
            guard let dictValue = value as? Dictionary<String, AnyObject> else {
                if i == paths.count - 1 {
                     return value
                }
               continue
            } 
            dict = dictValue
        }
        
        return dict
    }
    
    public func parse<Result, Container>(container: AnyObject, keyPath: String?, parseFunction: (Container) throws -> (Result)) throws -> Result {
        let object = try parseFoundationObject(container, keyPath: keyPath) as AnyObject
        if let primitive = object as? Result {
            return primitive
        }
        if let object = object as? Container {
            return try parseFunction(object)
        }
        throw ParseError.InvalidValue(keyPath ?? "Root keypath", String(container.self))
    }
}