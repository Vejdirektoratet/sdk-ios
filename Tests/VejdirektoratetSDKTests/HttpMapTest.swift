//
//  HttpMapTest.swift
//  VejdirektoratetSDKTests
//
//  Created by Daniel Andersen on 18/09/2019.
//  Copyright © 2019 Vejdirektoratet. All rights reserved.
//

import XCTest
import Hippolyte
@testable import VejdirektoratetSDK

class HttpMapTest: BaseHttpTest {
    
    override func baseUrl() -> String {
        return Feed.baseSnapshotUrl[.Map]!
    }
    
    func testSuccessStatusCode() {
        let body = #"[]"#
        
        Hippolyte.shared.add(stubbedRequest: self.request(response: self.response(body)))
        Hippolyte.shared.start()
        
        var result: HTTP.Result = HTTP.Result.entities([])
        VejdirektoratetSDK.request(entityTypes: [.Traffic], viewType: .Map, apiKey: self.apiKey) { _result in
            result = _result
            self.expectation.fulfill()
        }
        wait(for: [self.expectation], timeout: 10)
        
        switch result {
        case .entities:
            XCTAssertTrue(true)
        case .entity:
            XCTFail()
        case .error(let error):
            XCTFail("Call should succeed, but failed with error: \(error)")
        }
    }
    
    func testMixingTrafficAndRoadwork() {
        let body = #"""
            [
            {"entityType":"latextraffic","tag":"VHJhZmlrbWFuMi9yX1RyYWZpa21hbjIvMTMzNDQzMF9USUMtVHJhZmlrbWFuMi8x","points":[{"lat":56.46536,"lng":9.98535},{"lat":56.46492,"lng":9.98551},{"lat":56.46411,"lng":9.98581},{"lat":56.46383,"lng":9.98591},{"lat":56.46351,"lng":9.98603},{"lat":56.46319,"lng":9.98615},{"lat":56.46248,"lng":9.98639},{"lat":56.46204,"lng":9.98655},{"lat":56.46147,"lng":9.98678},{"lat":56.46077,"lng":9.98713},{"lat":56.460111,"lng":9.987521}],"style":{"id":"Trafficevent.Activity","strokeColor":"#ff0000ff","strokeWidth":3.0,"fillColor":"#ff000088","icon":"https://s3-eu-west-1.amazonaws.com/static.nap.vd.dk/icons/roadsign_trafikmelding.png","dashed":false,"dashColor":"#000000ff","zIndex":0},"extras":{},"type":"POLYLINE"},
            {"entityType":"latexroadwork","tag":"VHJhZmlrbWFuMi9yX09UbWFuL3Zlam1hbl84NTFfMTktMDM3MjNfVElDLVRyYWZpa21hbjIvMQ","center":{"lat":57.070131,"lng":9.910451},"style":{"id":"Trafficevent.RoadWork","strokeColor":"#ff0000ff","strokeWidth":3.0,"fillColor":"#ff000088","icon":"https://s3-eu-west-1.amazonaws.com/static.nap.vd.dk/icons/roadsign_vejarbejde.png","dashed":false,"dashColor":"#000000ff","zIndex":0},"extras":{},"type":"MARKER"}
            ]
        """#
        
        Hippolyte.shared.add(stubbedRequest: self.request(response: self.response(body)))
        Hippolyte.shared.start()
        
        var result: HTTP.Result = HTTP.Result.entities([])
        VejdirektoratetSDK.request(entityTypes: [.Traffic, .RoadWork], viewType: .Map, apiKey: self.apiKey) { _result in
            result = _result
            self.expectation.fulfill()
        }
        wait(for: [self.expectation], timeout: 10)
        
        switch result {
        case .entities(let entities):
            XCTAssertEqual(entities.count, 2)
            
            XCTAssertTrue(entities[0] is MapPolyline)
            let firstEntity = entities[0] as! MapPolyline
            XCTAssertEqual(firstEntity.entityType, .Traffic)
            XCTAssertEqual(firstEntity.tag, "VHJhZmlrbWFuMi9yX1RyYWZpa21hbjIvMTMzNDQzMF9USUMtVHJhZmlrbWFuMi8x")
            XCTAssertEqual(firstEntity.points.count, 11)
            
            XCTAssertTrue(entities[1] is MapMarker)
            let secondEntity = entities[1] as! MapMarker
            XCTAssertEqual(secondEntity.entityType, .RoadWork)
            XCTAssertEqual(secondEntity.tag, "VHJhZmlrbWFuMi9yX09UbWFuL3Zlam1hbl84NTFfMTktMDM3MjNfVElDLVRyYWZpa21hbjIvMQ")
            XCTAssertEqual(secondEntity.center.latitude, 57.070131)
            XCTAssertEqual(secondEntity.center.longitude, 9.910451)
        case .error, .entity:
            XCTFail("Call failed")
        }
    }
    
    func testTrafficWithoutStyle() {
        let body = #"""
            [
                {"entityType":"latextraffic","tag":"VHJhZmlrbWFuMi9yX1RyYWZpa21hbjIvMTMzNDQzMF9USUMtVHJhZmlrbWFuMi8x","points":[],"type":"POLYLINE"},
                {"entityType":"latexroadwork","tag":"VHJhZmlrbWFuMi9yX09UbWFuL3Zlam1hbl84NTFfMTktMDM3MjNfVElDLVRyYWZpa21hbjIvMQ","center":{"lat":57.070131,"lng":9.910451},"style":null,"type":"MARKER"}
            ]
        """#

        Hippolyte.shared.add(stubbedRequest: self.request(response: self.response(body)))
        Hippolyte.shared.start()
        
        var result: HTTP.Result = HTTP.Result.entities([])
        VejdirektoratetSDK.request(entityTypes: [.Traffic], viewType: .Map, apiKey: self.apiKey) { _result in
            result = _result
            self.expectation.fulfill()
        }
        wait(for: [self.expectation], timeout: 10)
        
        switch result {
        case .entities(let entities):
            XCTAssertEqual(entities.count, 0)
        case .error, .entity:
            XCTFail("Call failed")
        }
    }
    
    func testBuggyEntriesFilteredAway() {
        let body = #"""
            [
                {"tag":"Correct","entityType":"latexroadwork","center":{"lat":57.070131,"lng":9.910451},"type":"MARKER", "style":{"id":"Trafficevent.Activity","strokeColor":"#ff0000ff","strokeWidth":3.0,"fillColor":"#ff000088","icon":"","dashed":false,"dashColor":"#000000ff","zIndex":0}},
                {"tag":"entityType <integer>","entityType":42,"center":{"lat":57.070131,"lng":9.910451},"type":"MARKER","style":{"id":"Trafficevent.Activity","strokeColor":"#ff0000ff","strokeWidth":3.0,"fillColor":"#ff000088","icon":"","dashed":false,"dashColor":"#000000ff","zIndex":0}},
                {"tag":"center <float>","center":42.24,"type":"MARKER","style":{"id":"Trafficevent.Activity","strokeColor":"#ff0000ff","strokeWidth":3.0,"fillColor":"#ff000088","icon":"","dashed":false,"dashColor":"#000000ff","zIndex":0}},
                {"tag":"center.lat <string>","entityType":"latexroadwork","center":{"lat":"I'm a string, but should be a float","lng":9.910451},"type":"MARKER","style":{"id":"Trafficevent.Activity","strokeColor":"#ff0000ff","strokeWidth":3.0,"fillColor":"#ff000088","icon":"","dashed":false,"dashColor":"#000000ff","zIndex":0}},
                {"tag":"center.lng <string>","entityType":"latexroadwork","center":{"lat":57.070131,"lng":"I'm a string, but should be a float"},"type":"MARKER","style":{"id":"Trafficevent.Activity","strokeColor":"#ff0000ff","strokeWidth":3.0,"fillColor":"#ff000088","icon":"","dashed":false,"dashColor":"#000000ff","zIndex":0}},
                {"tag":"type <float>","entityType":"latexroadwork","center":{"lat":57.070131,"lng":9.910451},"type":42.24,"style":{"id":"Trafficevent.Activity","strokeColor":"#ff0000ff","strokeWidth":3.0,"fillColor":"#ff000088","icon":"","dashed":false,"dashColor":"#000000ff","zIndex":0}},
                {"tag":42.24,"entityType":"latexroadwork","center":{"lat":57.070131,"lng":9.910451},"type":"MARKER","style":{"id":"Trafficevent.Activity","strokeColor":"#ff0000ff","strokeWidth":3.0,"fillColor":"#ff000088","icon":"","dashed":false,"dashColor":"#000000ff","zIndex":0}},
            ]
        """#
        
        Hippolyte.shared.add(stubbedRequest: self.request(response: self.response(body)))
        Hippolyte.shared.start()
        
        var result: HTTP.Result = HTTP.Result.entities([])
        VejdirektoratetSDK.request(entityTypes: [.Traffic], viewType: .Map, apiKey: self.apiKey) { _result in
            result = _result
            self.expectation.fulfill()
        }
        wait(for: [self.expectation], timeout: 10)
        
        switch result {
        case .entities(let entities):
            XCTAssertEqual(entities.count, 1)
            
            let firstEntity = entities[0] as! MapMarker
            XCTAssertEqual(firstEntity.tag, "Correct")
        case .error, .entity:
            XCTFail("Call failed")
        }
    }

    func testMissingFieldsFilteredAway() {
        let body = #"""
            [
                {"tag":"Correct","entityType":"latexroadwork","center":{"lat":57.070131,"lng":9.910451},"type":"MARKER","style":{"id":"Trafficevent.Activity","strokeColor":"#ff0000ff","strokeWidth":3.0,"fillColor":"#ff000088","icon":"","dashed":false,"dashColor":"#000000ff","zIndex":0}},
                {"tag":"Missing entityType","center":{"lat":57.070131,"lng":9.910451},"type":"MARKER","style":{"id":"Trafficevent.Activity","strokeColor":"#ff0000ff","strokeWidth":3.0,"fillColor":"#ff000088","icon":"","dashed":false,"dashColor":"#000000ff","zIndex":0}},
                {"tag":"entityType <null>","entityType":null,"center":{"lat":57.070131,"lng":9.910451},"type":"MARKER","style":{"id":"Trafficevent.Activity","strokeColor":"#ff0000ff","strokeWidth":3.0,"fillColor":"#ff000088","icon":"","dashed":false,"dashColor":"#000000ff","zIndex":0}},
                {"tag":"Missing center","entityType":"latexroadwork","type":"MARKER","style":{"id":"Trafficevent.Activity","strokeColor":"#ff0000ff","strokeWidth":3.0,"fillColor":"#ff000088","icon":"","dashed":false,"dashColor":"#000000ff","zIndex":0}},
                {"tag":"Center <null>","center": null, "entityType":"latexroadwork","type":"MARKER","style":{"id":"Trafficevent.Activity","strokeColor":"#ff0000ff","strokeWidth":3.0,"fillColor":"#ff000088","icon":"","dashed":false,"dashColor":"#000000ff","zIndex":0}},
                {"tag":"Missing center.lat","entityType":"latexroadwork","center":{"lng":9.910451},"type":"MARKER","style":{"id":"Trafficevent.Activity","strokeColor":"#ff0000ff","strokeWidth":3.0,"fillColor":"#ff000088","icon":"","dashed":false,"dashColor":"#000000ff","zIndex":0}},
                {"tag":"center.lat <null>","entityType":"latexroadwork","center":{"lat":null,"lng":9.910451},"type":"MARKER","style":{"id":"Trafficevent.Activity","strokeColor":"#ff0000ff","strokeWidth":3.0,"fillColor":"#ff000088","icon":"","dashed":false,"dashColor":"#000000ff","zIndex":0}},
                {"tag":"Missing center.lng","entityType":"latexroadwork","center":{"lat":57.070131},"type":"MARKER","style":{"id":"Trafficevent.Activity","strokeColor":"#ff0000ff","strokeWidth":3.0,"fillColor":"#ff000088","icon":"","dashed":false,"dashColor":"#000000ff","zIndex":0}},
                {"tag":"center.lng <null>","entityType":"latexroadwork","center":{"lng":null,"lat":57.070131},"type":"MARKER","style":{"id":"Trafficevent.Activity","strokeColor":"#ff0000ff","strokeWidth":3.0,"fillColor":"#ff000088","icon":"","dashed":false,"dashColor":"#000000ff","zIndex":0}},
                {"tag":"Missing type","entityType":"latexroadwork","center":{"lat":57.070131,"lng":9.910451},"style":{"id":"Trafficevent.Activity","strokeColor":"#ff0000ff","strokeWidth":3.0,"fillColor":"#ff000088","icon":"","dashed":false,"dashColor":"#000000ff","zIndex":0}},
                {"tag":"type <null>","type":null,"entityType":"latexroadwork","center":{"lat":57.070131,"lng":9.910451},"style":{"id":"Trafficevent.Activity","strokeColor":"#ff0000ff","strokeWidth":3.0,"fillColor":"#ff000088","icon":"","dashed":false,"dashColor":"#000000ff","zIndex":0}},
                {"tag":"Missing <style>","entityType":"latexroadwork","center":{"lat":57.070131,"lng":9.910451},"type":"MARKER"}
            ]
        """#
        
        Hippolyte.shared.add(stubbedRequest: self.request(response: self.response(body)))
        Hippolyte.shared.start()
        
        var result: HTTP.Result = HTTP.Result.entities([])
        VejdirektoratetSDK.request(entityTypes: [.Traffic], viewType: .Map, apiKey: self.apiKey) { _result in
            result = _result
            self.expectation.fulfill()
        }
        wait(for: [self.expectation], timeout: 10)
        
        switch result {
        case .entities(let entities):
            XCTAssertEqual(entities.count, 1)
            
            let firstEntity = entities[0] as! MapMarker
            XCTAssertEqual(firstEntity.tag, "Correct")
        case .error, .entity:
            XCTFail("Call failed")
        }
    }
    
    func testHttpErrorCodes() {
        performErrorCodeTest(errorCode: 400)
        performErrorCodeTest(errorCode: 404)
        performErrorCodeTest(errorCode: 500)
    }
    
    func performErrorCodeTest(errorCode: Int) {
        let expectation = XCTestExpectation(description: "LIST request with error code \(errorCode)")
        
        Hippolyte.shared.add(stubbedRequest: self.request(response: self.response(statusCode: errorCode)))
        Hippolyte.shared.start()
        
        var result: HTTP.Result = HTTP.Result.entities([])
        VejdirektoratetSDK.request(entityTypes: [.Traffic], viewType: .Map, apiKey: self.apiKey) { _result in
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
        
        Hippolyte.shared.stop()
        Hippolyte.shared.clearStubs()
    }
}
