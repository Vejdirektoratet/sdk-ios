//
//  EntityValidator.swift
//  VejdirektoratetSDK
//
//  Created by Daniel Andersen on 11/09/2019.
//  Copyright © 2019 Vejdirektoratet. All rights reserved.
//

import Foundation

internal enum ValidationError: Error {
    case incorrectValue(expectedValues: Any, actualValue: Any?)
    case incorrectType(expectedType: Any, actualType: Any, data: Any?)
    case missingRequiredValue(data: Any?)
    case missingRequiredField(fieldName: String, data: Any?)
    case illegalDateFormat(data: Any?)
}

internal protocol Validator {
    func validate(data: Any?) throws;
}

internal class ValueValidator<T: Equatable> : Validator {
    var optional: Bool
    var validValues: [T]?
    
    init(optional: Bool = false, validValues: [T]? = nil) {
        self.optional = optional
        self.validValues = validValues
    }

    func validate(data: Any?) throws {
        
        // Check if entity is empty
        if data == nil || data! is NSNull {
            if self.optional {
                return
            }
            throw ValidationError.missingRequiredValue(data: data)
        }

        // Check type
        if !(data! is T) {
            throw ValidationError.incorrectType(expectedType: T.self, actualType: type(of: data!), data: data)
        }
        
        // Check values
        if self.validValues != nil {
            var found = false
            for value in self.validValues! {
                if value == (data! as! T) {
                    found = true
                }
            }
            if !found {
                throw ValidationError.incorrectValue(expectedValues: self.validValues!, actualValue: data)
            }
        }
    }
}

internal class TimestampValidator : ValueValidator<String> {
    override func validate(data: Any?) throws {
        try super.validate(data: data)

        // Validate date format
        if data != nil {
            let dateString = data as! String
            if Date.fromIso8601String(dateString: dateString) == nil {
                throw ValidationError.illegalDateFormat(data: data)
            }
        }
    }
}

internal class DictionaryValidator : ValueValidator<NSDictionary> {
    var fields: [String: Validator]
    
    init(optional: Bool = false, fields: [String: Validator]) {
        self.fields = fields
        super.init(optional: optional)
    }
    
    override func validate(data: Any?) throws {
        try super.validate(data: data)
        
        if data != nil && !(data is NSNull) {
            let dict = data as! NSDictionary

            for (fieldName, validator) in self.fields {
                do {
                    try validator.validate(data: dict[fieldName])
                } catch ValidationError.missingRequiredValue {
                    throw ValidationError.missingRequiredField(fieldName: fieldName, data: data)
                }
            }
        }
    }
}

internal class ArrayValidator : ValueValidator<NSArray> {
    var ignoreInvalidEntries: Bool
    var validator: Validator
    
    init(optional: Bool = false, ignoreInvalidEntries: Bool = false, validator: Validator) {
        self.ignoreInvalidEntries = ignoreInvalidEntries
        self.validator = validator
        super.init(optional: optional)
    }
    
    override func validate(data: Any?) throws {
        try super.validate(data: data)

        if ignoreInvalidEntries {
            return
        }
        
        if data != nil {
            for fieldData in data as! NSArray {
                try self.validator.validate(data: fieldData)
            }
        }
    }
}
