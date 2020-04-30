//
//  MapEntity.swift
//  VejdirektoratetSDK
//
//  Created by Daniel Andersen on 12/09/2019.
//  Copyright © 2019 Vejdirektoratet. All rights reserved.
//

import Foundation
import MapKit

public class MapEntity : Entity {
    public enum MapType : String {
        case marker = "MARKER"
        case polyline = "POLYLINE"
        case polygon = "POLYGON"
    }

    public let type: MapType
    public let style: MapStyle
    
    init(data: NSDictionary, type: MapType, style: MapStyle) {
        self.type = type
        self.style = style

        super.init(data: data)
    }
    
    internal class MapValidator : EntityValidator {
        override func validate(data: NSDictionary) throws {
            try super.validate(data: data)

            try DictionaryValidator(fields: [
                "type": ValueValidator<String>()
            ]).validate(data: data)
        }
    }
}
    
public class MapMarker : MapEntity {
    public let center: CLLocationCoordinate2D
    
    internal static func fromEntity(data: NSDictionary) throws -> MapMarker {
        try MarkerValidator().validate(data: data)
        return MapMarker(data: data)
    }

    init(data: NSDictionary) {
        self.center = CLLocationCoordinate2D.fromDictionary(coordinateDict: data["center"] as! NSDictionary)

        super.init(data: data,
                   type: MapType.marker,
                   style: try! MapStyle.fromEntity(data: data["style"] as! NSDictionary))
    }
    
    internal class MarkerValidator : MapValidator {
        override func validate(data: NSDictionary) throws {
            try super.validate(data: data)
            try DictionaryValidator(fields: [
                "center": DictionaryValidator(fields: [
                    "lat": ValueValidator<NSNumber>(),
                    "lng": ValueValidator<NSNumber>()]),
                "style": MapStyle.validator
            ]).validate(data: data)
        }
    }
}
    
public class MapPolyline : MapEntity {
    public var points: [CLLocationCoordinate2D]!
    
    internal static func fromEntity(data: NSDictionary) throws -> MapPolyline {
        try PolylineValidator().validate(data: data)
        return MapPolyline(data: data)
    }

    init(data: NSDictionary) {
        self.points = []
        for point in data["points"] as! NSArray {
            self.points.append(CLLocationCoordinate2D.fromDictionary(coordinateDict: point as! NSDictionary))
        }

        super.init(data: data,
                   type: MapType.polyline,
                   style: try! MapStyle.fromEntity(data: data["style"] as! NSDictionary))
    }
    
    internal class PolylineValidator : MapValidator {
        override func validate(data: NSDictionary) throws {
            try super.validate(data: data)

            try DictionaryValidator(fields: [
                "points": ArrayValidator(validator: DictionaryValidator(fields: [
                    "lat": ValueValidator<NSNumber>(),
                    "lng": ValueValidator<NSNumber>()])),
                "style": MapStyle.validator
            ]).validate(data: data)
        }
    }
}

public class MapPolygon : MapEntity {
    public var points: [CLLocationCoordinate2D]!
    
    internal static func fromEntity(data: NSDictionary) throws -> MapPolygon {
        try PolygonValidator().validate(data: data)
        return MapPolygon(data: data)
    }
    
    init(data: NSDictionary) {
        self.points = []
        for point in data["points"] as! NSArray {
            self.points.append(CLLocationCoordinate2D.fromDictionary(coordinateDict: point as! NSDictionary))
        }
        
        super.init(data: data,
                   type: MapType.polygon,
                   style: try! MapStyle.fromEntity(data: data["style"] as! NSDictionary))
    }
    
    internal class PolygonValidator : MapValidator {
        override func validate(data: NSDictionary) throws {
            try super.validate(data: data)
            
            try DictionaryValidator(fields: [
                "points": ArrayValidator(validator: DictionaryValidator(fields: [
                    "lat": ValueValidator<NSNumber>(),
                    "lng": ValueValidator<NSNumber>()])),
                "style": MapStyle.validator
            ]).validate(data: data)
        }
    }
}

public class MapStyle {
    public let id: String!
    public let icon: String?
    public let dashed: Bool!
    public let strokeWidth: Double!
    public let zIndex: Int!
    #if canImport(UIKit)
    public let dashColor: UIColor!
    public let fillColor: UIColor!
    public let strokeColor: UIColor!
    #else
    public let dashColor: NSColor!
    public let fillColor: NSColor!
    public let strokeColor: NSColor!
    #endif
    
    internal static func fromEntity(data: NSDictionary) throws -> MapStyle {
        try StyleValidator().validate(data: data)
        return MapStyle(data: data)
    }

    init(data: NSDictionary) {
        self.id = data["id"]! as? String
        self.icon = data["icon"]! as? String
        self.dashed = (data["dashed"]! as! NSNumber).boolValue
        self.strokeWidth = (data["strokeWidth"]! as! NSNumber).doubleValue
        self.zIndex = (data["zIndex"]! as! NSNumber).intValue
        #if canImport(UIKit)
        self.dashColor = UIColor.colorWithHexString(hexString: data["dashColor"]! as! String)
        self.fillColor = UIColor.colorWithHexString(hexString: data["fillColor"]! as! String)
        self.strokeColor = UIColor.colorWithHexString(hexString: data["strokeColor"]! as! String)
        #else
        self.dashColor = NSColor.colorWithHexString(hexString: data["dashColor"]! as! String)
        self.fillColor = NSColor.colorWithHexString(hexString: data["fillColor"]! as! String)
        self.strokeColor = NSColor.colorWithHexString(hexString: data["strokeColor"]! as! String)
        #endif
    }
    
    internal class StyleValidator : BaseValidator {
        override func validate(data: NSDictionary) throws {
            try super.validate(data: data)
            
            try MapStyle.validator.validate(data: data)
        }
    }
    
    internal static let validator = DictionaryValidator(fields: [
        "id": ValueValidator<String>(),
        "icon": ValueValidator<String>(optional: true),
        "dashColor": ValueValidator<String>(),
        "dashed": ValueValidator<NSNumber>(),
        "fillColor": ValueValidator<String>(),
        "strokeColor": ValueValidator<String>(),
        "strokeWidth": ValueValidator<NSNumber>(),
        "zIndex": ValueValidator<NSNumber>()
    ])
}
