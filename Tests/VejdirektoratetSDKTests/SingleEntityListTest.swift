//
//  SingleEntityListTest.swift
//  VejdirektoratetSDKTests
//
//  Created by Daniel Andersen on 07/01/2020.
//  Copyright © 2020 Vejdirektoratet. All rights reserved.
//

import XCTest
import Hippolyte
@testable import VejdirektoratetSDK

class SingleEntityListTest: BaseHttpTest {

    override func baseUrl() -> String {
        return Feed.baseEntityUrl[.List]!
    }
    
    func testValidEntity() {
        let body = #"""
            {"heading":"Tabt gods","description":"Rute 21 Motortrafikvej 21, fra Sjællands Odde mod Holbæk mellem Slagelse/Nykøbing Sj. og Asnæs. Tabt gods, vejhjælp er på vej. Der ligger en dunk midt på vejen","tag":"VHJhZmlrbWFuMi9yX1RyYWZpa21hbjIvMTMzNDQzMl9USUMtVHJhZmlrbWFuMi8x","entityType":"latextraffic","timestamp":"2019-09-12T09:20:26.000+0000","bounds":{"southWest":{"lat":55.808418,"lng":11.582623},"northEast":{"lat":55.808418,"lng":11.582623}}}
        """#
        
        Hippolyte.shared.add(stubbedRequest: self.request(response: self.response(body)))
        Hippolyte.shared.start()
        
        var result: HTTP.Result = HTTP.Result.entities([])
        VejdirektoratetSDK.requestEntity(tag: "tag", viewType: .List, apiKey: self.apiKey) { _result in
            result = _result
            self.expectation.fulfill()
        }
        wait(for: [self.expectation], timeout: 10)

        switch result {
        case .entity(let entity):
            let model = entity as! ListEntity
            XCTAssertEqual(model.entityType, .Traffic)
            XCTAssertEqual(model.tag, "VHJhZmlrbWFuMi9yX1RyYWZpa21hbjIvMTMzNDQzMl9USUMtVHJhZmlrbWFuMi8x")
            XCTAssertEqual(Date.toIso8601String(date: model.timestamp), "2019-09-12T09:20:26.000Z")
            XCTAssertEqual(model.heading, "Tabt gods")
            XCTAssertTrue(model.description.starts(with: "Rute 21 Motortrafikvej 21, fra Sjællands Odde mod Holbæk mellem Slagelse/Nykøbing Sj. og Asnæs."))
            XCTAssertNotNil(model.bounds)
            XCTAssertEqual(model.bounds!.center.latitude, (55.808418 + 55.808418) / 2.0)
            XCTAssertEqual(model.bounds!.center.longitude, (11.582623 + 11.582623) / 2.0)
            XCTAssertEqual(model.bounds!.span.latitudeDelta, 0.0)
            XCTAssertEqual(model.bounds!.span.longitudeDelta, 0.0)
        case .error, .entities:
            XCTFail("Call failed")
        }
    }

    func testInvalidEntityWillReturnError() {
        let errorCode = 400
        
        let body = #"""
            {"heading":"Entity type missing","description":"Rute 21 Motortrafikvej 21, fra Sjællands Odde mod Holbæk mellem Slagelse/Nykøbing Sj. og Asnæs. Tabt gods, vejhjælp er på vej. Der ligger en dunk midt på vejen","tag":"VHJhZmlrbWFuMi9yX1RyYWZpa21hbjIvMTMzNDQzMl9USUMtVHJhZmlrbWFuMi8x","timestamp":"2019-09-12T09:20:26.000+0000","bounds":{"southWest":{"lat":55.808418,"lng":11.582623},"northEast":{"lat":55.808418,"lng":11.582623}}}
        """#
        
        Hippolyte.shared.add(stubbedRequest: self.request(response: self.response(body)))
        Hippolyte.shared.start()
        
        var result: HTTP.Result = HTTP.Result.entities([])
        VejdirektoratetSDK.requestEntity(tag: "tag", viewType: .List, apiKey: self.apiKey) { _result in
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
        VejdirektoratetSDK.requestEntity(tag: "notfound", viewType: .List, apiKey: self.apiKey) { _result in
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
