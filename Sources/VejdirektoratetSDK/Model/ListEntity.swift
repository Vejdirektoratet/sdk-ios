//
//  ListEntity.swift
//  VejdirektoratetSDK
//
//  Created by Daniel Andersen on 06/09/2019.
//  Copyright © 2019 Vejdirektoratet. All rights reserved.
//

import Foundation
import MapKit

public class ListEntity : Entity {
    public let timestamp: Date
    public let heading: String
    public let description: String
    public let bounds: MKCoordinateRegion?

    override init(data: NSDictionary) {
        self.timestamp = Date.fromIso8601String(dateString: data["timestamp"] as! String)!
        self.heading = data["heading"] as! String
        self.description = data["description"] as! String
        self.bounds = MKCoordinateRegion.fromDictionary(data["bounds"])

        super.init(data: data)
    }
    
    public class Traffic : ListEntity {
        internal static func fromEntity(data: NSDictionary) throws -> Traffic {
            try TrafficValidator().validate(data: data)
            return Traffic(data: data)
        }

        internal class TrafficValidator : ListValidator {
            override func validate(data: NSDictionary) throws {
                try super.validate(data: data)
            }
        }
    }

    public class Roadwork : ListEntity {
        internal static func fromEntity(data: NSDictionary) throws -> Roadwork {
            try RoadworkValidator().validate(data: data)
            return Roadwork(data: data)
        }
        
        internal class RoadworkValidator : ListValidator {
            override func validate(data: NSDictionary) throws {
                try super.validate(data: data)
            }
        }
    }

    internal class ListValidator : EntityValidator {
        override func validate(data: NSDictionary) throws {
            try super.validate(data: data)

            try DictionaryValidator(fields: [
                "timestamp": TimestampValidator(),
                "heading": ValueValidator<String>(),
                "description": ValueValidator<String>(),
                "bounds": DictionaryValidator(optional: true, fields: [
                    "southWest": DictionaryValidator(fields: [
                        "lat": ValueValidator<NSNumber>(),
                        "lng": ValueValidator<NSNumber>()
                    ]),
                    "northEast": DictionaryValidator(fields: [
                        "lat": ValueValidator<NSNumber>(),
                        "lng": ValueValidator<NSNumber>()
                    ])
                ])
            ]).validate(data: data)
        }
    }
}
