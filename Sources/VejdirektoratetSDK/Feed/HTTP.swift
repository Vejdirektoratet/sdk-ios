//
//  HTTP.swift
//  VejdirektoratetSDK
//
//  Created by Daniel Andersen on 05/09/2019.
//  Copyright © 2019 Vejdirektoratet. All rights reserved.
//

import Foundation
import MapKit
import Alamofire

public class HTTP {
    public enum Result {
        case entities([Entity])
        case entity(Entity)
        case error(Feed.RequestError)
    }

    public class Request {
        let request: DataRequest

        init(request: DataRequest) {
            self.request = request
        }

        public func cancel() {
            self.request.cancel()
        }
    }

    internal func request(url: String, viewType: VejdirektoratetSDK.ViewType, completion: @escaping (Result) -> Void) -> Request {
        let request = AF.request(url, headers: [.accept("application/json")])
        request
            .validate()
            .responseJSON(options: .allowFragments) { (response) in
                if !request.isCancelled {
                    completion(self.extractResult(response: response, viewType: viewType))
            }
        }
        return Request(request: request)
    }

    private func extractResult(response: AFDataResponse<Any>, viewType: VejdirektoratetSDK.ViewType) -> Result {
        switch response.result {
        case .success(let value):
            if value is Array<Any> {
                let entities = Feed.mapEntities(entities: value as! [Any], viewType: viewType)
                return Result.entities(entities)
            }
            else if value is NSDictionary {
                let entity = Feed.mapEntity(entity: value as! NSDictionary, viewType: viewType)
                if entity == nil {
                    return Result.error(Feed.RequestError.ServerError(errorCode: 400, message: "Invalid entity"))
                }
                return Result.entity(entity!)
            }
            else {
                return Result.error(Feed.RequestError.ServerError(errorCode: 500, message: "Expected array or dictionary result"))
            }
        case .failure(let error):
            return Result.error(Feed.RequestError.ServerError(errorCode: error.responseCode, message: error.errorDescription))
        }
    }
}
