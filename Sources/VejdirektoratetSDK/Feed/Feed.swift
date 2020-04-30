//
//  Feed.swift
//  VejdirektoratetSDK
//
//  Created by Daniel Andersen on 05/09/2019.
//  Copyright © 2019 Vejdirektoratet. All rights reserved.
//

import Foundation
import MapKit
import Alamofire

public class Feed {
    public enum RequestError {
        case ServerError(errorCode: Int?, message: String?)
    }
    
    internal static let baseSnapshotUrl = [
        VejdirektoratetSDK.ViewType.List: "https://data.vd-nap.dk/api/v2/list/snapshot",
        VejdirektoratetSDK.ViewType.Map: "https://data.vd-nap.dk/api/v2/map/snapshot",
    ]

    internal static let baseEntityUrl = [
        VejdirektoratetSDK.ViewType.List: "https://data.vd-nap.dk/api/v2/list/entity",
        VejdirektoratetSDK.ViewType.Map: "https://data.vd-nap.dk/api/v2/map/entity",
    ]

    internal func request(entityTypes: [VejdirektoratetSDK.EntityType], region: MKCoordinateRegion?, zoom: Int? = nil, viewType: VejdirektoratetSDK.ViewType = VejdirektoratetSDK.ViewType.List, apiKey: String, completion: @escaping (HTTP.Result) -> Void) -> HTTP.Request {
        let url = self.urlWithParameters(baseUrl: Feed.baseSnapshotUrl[viewType]!, entityTypes: entityTypes, region: region, zoom: zoom, viewType: viewType, apiKey: apiKey)
        return HTTP().request(url: url, viewType: viewType) { (result) in
            completion(result)
        }
    }

    internal func requestEntity(tag: String, viewType: VejdirektoratetSDK.ViewType = VejdirektoratetSDK.ViewType.List, apiKey: String, completion: @escaping (HTTP.Result) -> Void) -> HTTP.Request {
        let url = self.urlWithParameters(baseUrl: Feed.baseEntityUrl[viewType]!, tag: tag, viewType: viewType, apiKey: apiKey)
        return HTTP().request(url: url, viewType: viewType) { (result) in
            completion(result)
        }
    }

    internal static func mapEntities(entities: [Any], viewType: VejdirektoratetSDK.ViewType) -> [Entity] {
        var models: [Entity] = []
        for entity in entities {
            guard let mappedEntity = Feed.mapEntity(entity: entity as! NSDictionary, viewType: viewType) else {
                continue
            }
            models.append(mappedEntity)
        }
        return models
    }
    
    internal static func mapEntity(entity: NSDictionary, viewType: VejdirektoratetSDK.ViewType) -> Entity? {
        switch viewType {
        case .List:
            return Feed.mapListEntity(entity)
        case .Map:
            return Feed.mapMapEntity(entity)
        }
    }
    
    internal static func mapListEntity(_ entity: NSDictionary) -> Entity? {
        guard let entityType = entity["entityType"] as? String else { return nil }
        
        do {
            switch entityType {
            case "latextraffic":
                return try ListEntity.Traffic.fromEntity(data: entity)
            case "latexroadwork":
                return try ListEntity.Roadwork.fromEntity(data: entity)
            default:
                return nil
            }
        } catch {
            return nil
        }
    }

    internal static func mapMapEntity(_ entity: NSDictionary) -> Entity? {
        guard let typeString = entity["type"] as? String else { return nil }
        guard let mapType = MapEntity.MapType(rawValue: typeString) else { return nil }
        
        do {
            switch mapType {
            case .marker:
                return try MapMarker.fromEntity(data: entity)
            case .polyline:
                return try MapPolyline.fromEntity(data: entity)
            case .polygon:
                return try MapPolygon.fromEntity(data: entity)
            }
        } catch {
            return nil
        }
    }

    internal func urlWithParameters(baseUrl: String, entityTypes: [VejdirektoratetSDK.EntityType], region: MKCoordinateRegion? = nil, zoom: Int? = nil, viewType: VejdirektoratetSDK.ViewType, apiKey: String) -> String {
        var queryItems = [URLQueryItem]()

        // Entity types
        var typesString = ""
        var typesDelimiter = ""
        for entityType in entityTypes {
            typesString = "\(typesString)\(typesDelimiter)\(entityType.rawValue)"
            typesDelimiter = ","
        }
        queryItems.append(URLQueryItem(name: "types", value: typesString))

        // Region
        if region != nil {
            let southWestLatitude = region!.center.latitude - (region!.span.latitudeDelta / 2.0)
            let southWestLongitude = region!.center.longitude - (region!.span.longitudeDelta / 2.0)
            let northEastLatitude = region!.center.latitude + (region!.span.latitudeDelta / 2.0)
            let northEastLongitude = region!.center.longitude + (region!.span.longitudeDelta / 2.0)

            queryItems.append(URLQueryItem(name: "sw", value: "\(southWestLatitude),\(southWestLongitude)"))
            queryItems.append(URLQueryItem(name: "ne", value: "\(northEastLatitude),\(northEastLongitude)"))
        }
        
        // Zoom
        if viewType == .Map && zoom != nil {
            queryItems.append(URLQueryItem(name: "zoom", value: "\(zoom!)"))
        }

        // API key
        queryItems.append(URLQueryItem(name: "api_key", value: "\(apiKey)"))

        // Build URL
        var urlComponents = URLComponents(string: baseUrl)!
        urlComponents.queryItems = queryItems
        
        return urlComponents.url!.absoluteString
    }

    internal func urlWithParameters(baseUrl: String, tag: String, viewType: VejdirektoratetSDK.ViewType, apiKey: String) -> String {
        var queryItems = [URLQueryItem]()

        // Tag
        queryItems.append(URLQueryItem(name: "tag", value: "\(tag)"))

        // API key
        queryItems.append(URLQueryItem(name: "api_key", value: "\(apiKey)"))

        // Types
        queryItems.append(URLQueryItem(name: "types", value: VejdirektoratetSDK.EntityType.allCases.map { $0.rawValue }.joined(separator: ",")))

        // Build URL
        var urlComponents = URLComponents(string: baseUrl)!
        urlComponents.queryItems = queryItems
        
        return urlComponents.url!.absoluteString
    }
}
