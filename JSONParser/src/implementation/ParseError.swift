//
//  ParseError.swift
//  JSONParser
//
//  Created by Lukas Schmidt on 22.05.16.
//  Copyright © 2016 Lukas Schmidt. All rights reserved.
//  Based on John Sundell Unboxer - https://github.com/JohnSundell/Unbox
//

import Foundation

public enum ParseError: Error, CustomStringConvertible {
    public var description: String {
        let baseDescription = "[JSON Parser error] "
        
        switch self {
        case .missingKey(let key):
            return baseDescription + "Missing key (\(key))"
        case .invalidValue(let key, let valueDescription):
            return baseDescription + "Invalid value (\(valueDescription)) for key (\(key))"
        case .invalidData:
            return baseDescription + "Invalid Data"
        }
    }
    
    /// Thrown when a required key was missing in an unboxed dictionary. Contains the missing key.
    case missingKey(String)
    /// Thrown when a required key contained an invalid value in an unboxed dictionary. Contains the invalid
    /// key and a description of the invalid data.
    case invalidValue(String, String)
    /// Thrown when a piece of data (Data) could not be unboxed because it was considered invalid
    case invalidData
}
