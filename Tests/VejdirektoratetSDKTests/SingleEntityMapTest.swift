//
//  SingleEntityMapTest.swift
//  VejdirektoratetSDKTests
//
//  Created by Daniel Andersen on 07/01/2020.
//  Copyright © 2020 Vejdirektoratet. All rights reserved.
//

import XCTest
import Hippolyte
@testable import VejdirektoratetSDK

class SingleEntityMapTest: BaseHttpTest {

    override func baseUrl() -> String {
        return Feed.baseEntityUrl[.Map]!
    }
    
    func testValidEntity() {
        let body = #"""
        {"entityType":"latextraffic","tag":"VHJhZmlrbWFuMi9yX1RyYWZpa21hbjIvMTMzNDQzMF9USUMtVHJhZmlrbWFuMi8x","points":[{"lat":56.46536,"lng":9.98535},{"lat":56.46492,"lng":9.98551},{"lat":56.46411,"lng":9.98581},{"lat":56.46383,"lng":9.98591},{"lat":56.46351,"lng":9.98603},{"lat":56.46319,"lng":9.98615},{"lat":56.46248,"lng":9.98639},{"lat":56.46204,"lng":9.98655},{"lat":56.46147,"lng":9.98678},{"lat":56.46077,"lng":9.98713},{"lat":56.460111,"lng":9.987521}],"style":{"id":"Trafficevent.Activity","strokeColor":"#ff0000ff","strokeWidth":3.0,"fillColor":"#ff000088","icon":"https://s3-eu-west-1.amazonaws.com/static.nap.vd.dk/icons/roadsign_trafikmelding.png","dashed":false,"dashColor":"#000000ff","zIndex":0},"extras":{},"type":"POLYLINE"}
        """#
        
        Hippolyte.shared.add(stubbedRequest: self.request(response: self.response(body)))
        Hippolyte.shared.start()
        
        var result: HTTP.Result = HTTP.Result.entities([])
        VejdirektoratetSDK.requestEntity(tag: "tag", viewType: .Map, apiKey: self.apiKey) { _result in
            result = _result
            self.expectation.fulfill()
        }
        wait(for: [self.expectation], timeout: 10)

        switch result {
        case .entity(let entity):
            XCTAssertTrue(entity is MapPolyline)
            let model = entity as! MapPolyline
            XCTAssertEqual(model.entityType, .Traffic)
            XCTAssertEqual(model.tag, "VHJhZmlrbWFuMi9yX1RyYWZpa21hbjIvMTMzNDQzMF9USUMtVHJhZmlrbWFuMi8x")
            XCTAssertEqual(model.points.count, 11)
        case .error, .entities:
            XCTFail("Call failed")
        }
    }

    func testInvalidEntityWillReturnError() {
        let errorCode = 400
        
        let body = #"""
            {"tag":"missing_entitytype","points":[{"lat":56.46536,"lng":9.98535},{"lat":56.46492,"lng":9.98551},{"lat":56.46411,"lng":9.98581},{"lat":56.46383,"lng":9.98591},{"lat":56.46351,"lng":9.98603},{"lat":56.46319,"lng":9.98615},{"lat":56.46248,"lng":9.98639},{"lat":56.46204,"lng":9.98655},{"lat":56.46147,"lng":9.98678},{"lat":56.46077,"lng":9.98713},{"lat":56.460111,"lng":9.987521}],"style":{"id":"Trafficevent.Activity","strokeColor":"#ff0000ff","strokeWidth":3.0,"fillColor":"#ff000088","icon":"https://s3-eu-west-1.amazonaws.com/static.nap.vd.dk/icons/roadsign_trafikmelding.png","dashed":false,"dashColor":"#000000ff","zIndex":0},"extras":{},"type":"POLYLINE"}
        """#
        
        Hippolyte.shared.add(stubbedRequest: self.request(response: self.response(body)))
        Hippolyte.shared.start()
        
        var result: HTTP.Result = HTTP.Result.entities([])
        VejdirektoratetSDK.requestEntity(tag: "tag", viewType: .Map, apiKey: self.apiKey) { _result in
            result = _result
            self.expectation.fulfill()
        }
        wait(for: [self.expectation], timeout: 10)

        switch result {
        case .entities, .entity:
            XCTFail("Call should fail with error code \(errorCode), but succeeded")
        case .error(let error):
            switch error {
            case .ServerError(let actualErrorCode, _):
                XCTAssertEqual(actualErrorCode, errorCode)
            }
        }
    }

    func testEntityNotFound() {
        let errorCode = 400
        let expectation = XCTestExpectation(description: "Entity request with error code \(errorCode)")
        
        Hippolyte.shared.add(stubbedRequest: self.request(response: self.response(statusCode: errorCode)))
        Hippolyte.shared.start()
        
        var result: HTTP.Result = HTTP.Result.entities([])
        VejdirektoratetSDK.requestEntity(tag: "notfound", viewType: .Map, apiKey: self.apiKey) { _result in
            result = _result
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10)
        
        switch result {
        case .entities, .entity:
            XCTFail("Call should fail with error code \(errorCode), but succeeded")
        case .error(let error):
            switch error {
            case .ServerError(let actualErrorCode, _):
                XCTAssertEqual(actualErrorCode, errorCode)
            }
        }
    }
}
