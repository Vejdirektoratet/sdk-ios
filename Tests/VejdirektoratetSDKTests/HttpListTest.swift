//
//  HttpListTest.swift
//  VejdirektoratetSDKTests
//
//  Created by Daniel Andersen on 05/09/2019.
//  Copyright © 2019 Vejdirektoratet. All rights reserved.
//

import XCTest
import Hippolyte
@testable import VejdirektoratetSDK

class HttpListTest: BaseHttpTest {

    override func baseUrl() -> String {
        return Feed.baseSnapshotUrl[.List]!
    }
    
    func testSuccessStatusCode() {
        let body = #"[]"#

        Hippolyte.shared.add(stubbedRequest: self.request(response: self.response(body)))
        Hippolyte.shared.start()
        
        var result: HTTP.Result = HTTP.Result.entities([])
        VejdirektoratetSDK.request(entityTypes: [.Traffic], viewType: .List, apiKey: self.apiKey) { _result in
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
                {"heading":"Tabt gods","description":"Rute 21 Motortrafikvej 21, fra Sjællands Odde mod Holbæk mellem Slagelse/Nykøbing Sj. og Asnæs. Tabt gods, vejhjælp er på vej. Der ligger en dunk midt på vejen","tag":"VHJhZmlrbWFuMi9yX1RyYWZpa21hbjIvMTMzNDQzMl9USUMtVHJhZmlrbWFuMi8x","entityType":"latextraffic","timestamp":"2019-09-12T09:20:26.000+0000","bounds":{"southWest":{"lat":55.808418,"lng":11.582623},"northEast":{"lat":55.808418,"lng":11.582623}}},
                {"heading":"Vejarbejde","description":"O2 København-Østerbro, Århusgade til Kalkbrænderihavnsgade mellem Hjørringgade og Trelleborggade. Vejarbejde, spærret. Metroarbejde. Spærret for al trafik fra Århusgade til Kalkbrænderihavnsgade, Følg skiltning på stedet. Cykler og gående skal via Vordingborggade eller Nordre Frihavnsgade","tag":"VHJhZmlrbWFuMi9yX1RyYWZpa21hbjIvMTIxNjU3N19USUMtVHJhZmlrbWFuMi8x","entityType":"latexroadwork","timestamp":"2018-08-17T09:08:25.000+0000","bounds":{"southWest":{"lat":55.707131,"lng":12.589524},"northEast":{"lat":55.70728,"lng":12.59096}}}
            ]
        """#
        
        Hippolyte.shared.add(stubbedRequest: self.request(response: self.response(body)))
        Hippolyte.shared.start()
        
        var result: HTTP.Result = HTTP.Result.entities([])
        VejdirektoratetSDK.request(entityTypes: [.Traffic, .RoadWork], viewType: .List, apiKey: self.apiKey) { _result in
            result = _result
            self.expectation.fulfill()
        }
        wait(for: [self.expectation], timeout: 10)

        switch result {
        case .entities(let entities):
            XCTAssertEqual(entities.count, 2)
            
            let firstEntity = entities[0] as! ListEntity
            XCTAssertEqual(firstEntity.entityType, .Traffic)
            XCTAssertEqual(firstEntity.tag, "VHJhZmlrbWFuMi9yX1RyYWZpa21hbjIvMTMzNDQzMl9USUMtVHJhZmlrbWFuMi8x")
            XCTAssertEqual(Date.toIso8601String(date: firstEntity.timestamp), "2019-09-12T09:20:26.000Z")
            XCTAssertEqual(firstEntity.heading, "Tabt gods")
            XCTAssertTrue(firstEntity.description.starts(with: "Rute 21 Motortrafikvej 21, fra Sjællands Odde mod Holbæk mellem Slagelse/Nykøbing Sj. og Asnæs."))
            XCTAssertNotNil(firstEntity.bounds)
            XCTAssertEqual(firstEntity.bounds!.center.latitude, (55.808418 + 55.808418) / 2.0)
            XCTAssertEqual(firstEntity.bounds!.center.longitude, (11.582623 + 11.582623) / 2.0)
            XCTAssertEqual(firstEntity.bounds!.span.latitudeDelta, 0.0)
            XCTAssertEqual(firstEntity.bounds!.span.longitudeDelta, 0.0)
            
            let secondEntity = entities[1] as! ListEntity
            XCTAssertEqual(secondEntity.entityType, .RoadWork)
            XCTAssertEqual(secondEntity.tag, "VHJhZmlrbWFuMi9yX1RyYWZpa21hbjIvMTIxNjU3N19USUMtVHJhZmlrbWFuMi8x")
            XCTAssertEqual(Date.toIso8601String(date: secondEntity.timestamp), "2018-08-17T09:08:25.000Z")
            XCTAssertEqual(secondEntity.heading, "Vejarbejde")
            XCTAssertTrue(secondEntity.description.starts(with: "O2 København-Østerbro, Århusgade til Kalkbrænderihavnsgade mellem Hjørringgade og Trelleborggade."))
            XCTAssertNotNil(secondEntity.bounds)
            XCTAssertEqual(secondEntity.bounds!.center.latitude, (55.707131 + 55.70728) / 2.0)
            XCTAssertEqual(secondEntity.bounds!.center.longitude, (12.589524 + 12.59096) / 2.0)
            XCTAssertEqual(secondEntity.bounds!.span.latitudeDelta, abs(55.707131 - 55.70728))
            XCTAssertEqual(secondEntity.bounds!.span.longitudeDelta, abs(12.589524 - 12.59096))
        case .error, .entity:
            XCTFail("Call failed")
        }
    }

    func testTrafficWithoutBounds() {
        let body = #"""
            [
                {"heading":"","description":"","tag":"","entityType":"latextraffic","timestamp":"2019-09-12T09:20:26.000+0000"},
                {"heading":"","description":"","tag":"","entityType":"latextraffic","timestamp":"2019-09-12T09:20:26.000+0000","bounds": null}
            ]
        """#

        Hippolyte.shared.add(stubbedRequest: self.request(response: self.response(body)))
        Hippolyte.shared.start()
        
        var result: HTTP.Result = HTTP.Result.entities([])
        VejdirektoratetSDK.request(entityTypes: [.Traffic], viewType: .List, apiKey: self.apiKey) { _result in
            result = _result
            self.expectation.fulfill()
        }
        wait(for: [self.expectation], timeout: 10)

        switch result {
        case .entities(let entities):
            XCTAssertEqual(entities.count, 2)
            
            let firstEntity = entities[0] as? ListEntity
            XCTAssertNil(firstEntity?.bounds)

            let secondEntity = entities[1] as? ListEntity
            XCTAssertNil(secondEntity?.bounds)
        case .error, .entity:
            XCTFail("Call failed")
        }
    }

    func testBuggyTrafficEntriesFilteredAway() {
        let body = #"""
            [
                {"heading":"Correct","description":"","tag":"","entityType":"latextraffic","timestamp":"2019-09-12T09:20:26.000+0000"},
                {"heading":"EntityType float value","description":"", "tag":"","entityType":42.24,"timestamp":"2019-09-12T09:20:26.000+0000"},
                {"heading":"EntityType unknown","description":"","tag":"","entityType":"unknown","timestamp":"2019-09-12T09:20:26.000+0000"},
                {"heading":"Description integer value","description":42, "tag":"","entityType":"latextraffic","timestamp":"2019-09-12T09:20:26.000+0000"},
                {"heading":"Timestamp doesn't validate","description":"", "tag":"","entityType":"latextraffic","timestamp":"Tue, 17 Sep 2019 11:35:13 GMT"},
                {"heading":"Tag <null>","description":"","tag":null,"timestamp":"2019-09-12T09:20:26.000+0000"}
            ]
        """#

        Hippolyte.shared.add(stubbedRequest: self.request(response: self.response(body)))
        Hippolyte.shared.start()

        var result: HTTP.Result = HTTP.Result.entities([])
        VejdirektoratetSDK.request(entityTypes: [.Traffic], viewType: .List, apiKey: self.apiKey) { _result in
            result = _result
            self.expectation.fulfill()
        }
        wait(for: [self.expectation], timeout: 10)
        
        switch result {
        case .entities(let entities):
            XCTAssertEqual(entities.count, 1)
            
            let firstEntity = entities[0] as! ListEntity
            XCTAssertEqual(firstEntity.heading, "Correct")
        case .error, .entity:
            XCTFail("Call failed")
        }
    }

    func testMissingFieldsFilteredAway() {
        let body = #"""
            [
                {"heading":"Correct","description":"","tag":"","entityType":"latextraffic","timestamp":"2019-09-12T09:20:26.000+0000"},
                {"heading":"Missing description","tag":"","entityType":"latextraffic","timestamp":"2019-09-12T09:20:26.000+0000"},
                {"heading":"Description <null>","description":null,"tag":"","entityType":"latextraffic","timestamp":"2019-09-12T09:20:26.000+0000"},
                {"heading":"Missing entityType","description":"","tag":"","timestamp":"2019-09-12T09:20:26.000+0000"},
                {"heading":"EntityType <null>","description":"","tag":"","entityType":null,"timestamp":"2019-09-12T09:20:26.000+0000"},
                {"heading":"Missing tag","entityType":"latextraffic","timestamp":"2019-09-12T09:20:26.000+0000"},
                {"heading":"Tag <null>","description":"","tag":null,"timestamp":"2019-09-12T09:20:26.000+0000"},
                {"heading":"Missing timestamp","description":"","tag":"","entityType":"latextraffic"},
                {"heading":"Timestamp <null>","description":"","tag":"","entityType":"latextraffic","timestamp":null}
            ]
        """#

        Hippolyte.shared.add(stubbedRequest: self.request(response: self.response(body)))
        Hippolyte.shared.start()
        
        var result: HTTP.Result = HTTP.Result.entities([])
        VejdirektoratetSDK.request(entityTypes: [.Traffic], viewType: .List, apiKey: self.apiKey) { _result in
            result = _result
            self.expectation.fulfill()
        }
        wait(for: [self.expectation], timeout: 10)
        
        switch result {
        case .entities(let entities):
            XCTAssertEqual(entities.count, 1)
            
            let firstEntity = entities[0] as! ListEntity
            XCTAssertNil(firstEntity.bounds)
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
        VejdirektoratetSDK.request(entityTypes: [.Traffic], viewType: .List, apiKey: self.apiKey) { _result in
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
