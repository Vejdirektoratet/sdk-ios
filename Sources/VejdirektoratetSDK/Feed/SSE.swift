//
//  SSE.swift
//  VejdirektoratetSDK
//
//  Created by Daniel Andersen on 18/12/2019.
//  Copyright © 2019 Vejdirektoratet. All rights reserved.
//

import Foundation
import MapKit
import EventSource

public class SSE {
    public enum EntityChange {
        case entitiesCleared
        case entitiesAdded(entities: [Entity])
        case entitiesUpdated(entities: [Entity])
        case entitiesRemoved(tags: [String])
    }
    
    public class Request {
        var eventSource: EventSource?

        init(eventSource: EventSource) {
            self.eventSource = eventSource
        }
        
        deinit {
            self.cancel()
        }

        public func cancel() {
            self.eventSource?.disconnect()
            self.eventSource = nil
        }
    }

    internal func request(url: String, viewType: VejdirektoratetSDK.ViewType, callback: @escaping (EntityChange) -> Void) -> Request {
        let eventSource = EventSource(url: URL(string: url)!)

        eventSource.onMessage { id, event, data in
            SSE.handleMessage(id: id, event: event, data: data, viewType: viewType, callback: callback)
        }

        eventSource.onComplete { statusCode, reconnect, error in
            debugPrint("SSE disconnected!")
            guard reconnect ?? false else { return }

            let retryTime = eventSource.retryTime
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(retryTime)) {
                debugPrint("Retrying SSE connection!")
                eventSource.connect()
            }
        }

        callback(EntityChange.entitiesCleared)
        
        eventSource.connect()

        return Request(eventSource: eventSource)
    }
    
    private static func handleMessage(id: String?, event: String?, data: String?, viewType: VejdirektoratetSDK.ViewType, callback: (EntityChange) -> Void) {
        if data == nil {
            return
        }

        guard let utf8Data = data?.data(using: String.Encoding.utf8) else { return }
        guard let jsonDict = try? JSONSerialization.jsonObject(with: utf8Data, options: JSONSerialization.ReadingOptions.allowFragments) as? NSDictionary else { return }
        guard let type = jsonDict["type"] as? String else { return }
        
        if type.lowercased() == "clear" {
            callback(EntityChange.entitiesCleared)
        }

        if type.lowercased() == "new" {
            if let changedEntities = jsonDict["new"] as? NSArray {
                SSE.handleChangedMessage(entities: changedEntities, viewType: viewType, callback: callback)
            }
        }

        if type.lowercased() == "changed" {
            if let changedEntities = jsonDict["changed"] as? NSArray {
                SSE.handleChangedMessage(entities: changedEntities, viewType: viewType, callback: callback)
            }
        }

        if type.lowercased() == "deleted" {
            if let deletedEntities = jsonDict["deleted"] as? NSArray {
                SSE.handleDeletedMessage(entities: deletedEntities, viewType: viewType, callback: callback)
            }
        }
    }
    
    private static func handleAddedMessage(entities: NSArray, viewType: VejdirektoratetSDK.ViewType, callback: (EntityChange) -> Void) {
        let mappedEntities = SSE.mapEntitiesFromWrappedList(entities: entities, viewType: viewType)
        if mappedEntities.count == 0 {
            return
        }
        
        callback(EntityChange.entitiesAdded(entities: mappedEntities))
    }

    private static func handleChangedMessage(entities: NSArray, viewType: VejdirektoratetSDK.ViewType, callback: (EntityChange) -> Void) {
        let mappedEntities = SSE.mapEntitiesFromWrappedList(entities: entities, viewType: viewType)
        if mappedEntities.count == 0 {
            return
        }
        
        callback(EntityChange.entitiesUpdated(entities: mappedEntities))
    }
    
    private static func handleDeletedMessage(entities: NSArray, viewType: VejdirektoratetSDK.ViewType, callback: (EntityChange) -> Void) {
        var tags = [String]()
        for entity in entities {
            guard let tag = entity as? String else { continue }
            tags.append(tag)
        }
        
        callback(EntityChange.entitiesRemoved(tags: tags))
    }

    private static func mapEntitiesFromWrappedList(entities: NSArray, viewType: VejdirektoratetSDK.ViewType) -> [Entity] {
        var unwrappedEntities = [NSDictionary]()
        
        for entity in entities {
            guard let unwrappedEntity = (entity as? NSDictionary)?["entity"] as? NSDictionary else { continue }
            unwrappedEntities.append(unwrappedEntity)
        }
        
        return Feed.mapEntities(entities: unwrappedEntities, viewType: viewType);
    }
}
