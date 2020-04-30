//
//  BaseEntity.swift
//  VejdirektoratetSDK
//
//  Created by Daniel Andersen on 06/09/2019.
//  Copyright © 2019 Vejdirektoratet. All rights reserved.
//

import Foundation

public class Entity {
    public enum EntityType : String {
        case Traffic
        case RoadWork
        case RoadSegment
    }

    public let entityType: EntityType
    public let tag: String

    internal static let entityTypeDict = [
        "latextraffic": EntityType.Traffic,
        "latexroadwork": EntityType.RoadWork,
        "vd.geo.inrix.segment": EntityType.RoadSegment
    ]

    init(data: NSDictionary) {
        self.entityType = Entity.entityTypeFromString(data["entityType"]! as! String)!
        self.tag = data["tag"] as! String
    }

    internal static func entityTypeFromString(_ entityTypeString: String) -> EntityType? {
        return Entity.entityTypeDict[entityTypeString]
    }
}

internal class BaseValidator {
    init() {
    }
    
    func validate(data: NSDictionary) throws {
    }
}

internal class EntityValidator : BaseValidator {
    override func validate(data: NSDictionary) throws {
        try super.validate(data: data)

        try DictionaryValidator(fields: [
            "entityType": ValueValidator<String>(validValues: Array(Entity.entityTypeDict.keys)),
            "tag": ValueValidator<String>()
        ]).validate(data: data)
    }
}
