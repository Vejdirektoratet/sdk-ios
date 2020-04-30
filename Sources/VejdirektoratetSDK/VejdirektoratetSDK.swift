//
//  VejdirektoratetSDK.swift
//  VejdirektoratetSDK
//
//  Created by Daniel Andersen on 05/09/2019.
//  Copyright © 2019 Vejdirektoratet. All rights reserved.
//

import MapKit

public class VejdirektoratetSDK {
    
    /**
     *
     * An enum describing the available entity types
     * [TRAFFIC] traffic events
     * [ROADWORK] roadwork events
     * [TRAFFIC_DENSITY] congestion level of road segments
     * [WINTER_DEICING] deicing status of road segments
     * [WINTER_CONDITION] condition of road segments with respect to slipperiness
     */
    public enum EntityType : String, CaseIterable {
        case Traffic = "traffic"
        case RoadWork = "roadworks"
        case TrafficDensity = "trafficdensity"
        case WinterDeicing = "winterdeicing"
        case WinterCondition = "wintercondition"
    }
    
    /**
     * An enum describing the available view types
     *
     * [LIST] returns entities suitable for non-map representation
     * [MAP] returns entities suitable for map representation
     */
    public enum ViewType {
        case List
        case Map
    }

    /**
     * A method to request entities
     *
     * @param entityTypes the desired EntityType's to be returned in the callback
     * @param region the region from which to get entities (optional)
     * @param zoom Google-like zoom level to determine the detail level (optional)
     * @param viewType the desired ViewType for which to display the entities
     * @param apiKey the API key should be acquired from https://nap.vd.dk/
     * @param completion the callback method which will receive the entities in form of a HTTP.Result
     * @return HTTP.Request returns a cancellable request
     */
    @discardableResult
    public static func request(entityTypes: [EntityType], region: MKCoordinateRegion? = nil, zoom: Int? = nil, viewType: ViewType, apiKey: String, completion: @escaping (HTTP.Result) -> Void) -> HTTP.Request {
        Feed().request(entityTypes: entityTypes, region: region, zoom: zoom, viewType: viewType, apiKey: apiKey, completion: completion)
    }

    /**
     * Method for requesting a specific entity from its tag
     *
     * @param tag the tag of the entity
     * @param viewType the desired ViewType for which to display the entity
     * @param apiKey the API key should be acquired from https://nap.vd.dk/
     * @param completion the callback method which will receive the result of the request in form of a HTTP.Result
     * @return HTTP.Request returns a cancellable request
     */
    @discardableResult
    public static func requestEntity(tag: String, viewType: ViewType, apiKey: String, completion: @escaping (HTTP.Result) -> Void) -> HTTP.Request {
        Feed().requestEntity(tag: tag, viewType: viewType, apiKey: apiKey, completion: completion)
    }

    /**
     * Method to request continous updates on entities
     *
     * @param entityTypes the desired EntityType's to be returned in the callback
     * @param region the region from which to get entities (optional)
     * @param zoom Google-like zoom level to determine the detail level (optional)
     * @param viewType the desired ViewType for which to display the entities
     * @param apiKey the API key should be acquired from https://nap.vd.dk/
     * @param callback the callback method which will receive the entities in form of a SSE.EntityChange
     * @return SSE.Request returns a cancellable request
     */
    @discardableResult
    public static func sync(entityTypes: [EntityType], region: MKCoordinateRegion? = nil, zoom: Int? = nil, viewType: ViewType, apiKey: String, callback: @escaping (SSE.EntityChange) -> Void) -> SSE.Request {
        Feed().sync(entityTypes: entityTypes, region: region, zoom: zoom, viewType: viewType, apiKey: apiKey, callback: callback)
    }
}
