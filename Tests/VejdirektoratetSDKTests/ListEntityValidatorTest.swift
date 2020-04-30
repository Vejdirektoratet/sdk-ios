//
//  ListEntityValidatorTest.swift
//  VejdirektoratetSDKTests
//
//  Created by Daniel Andersen on 18/09/2019.
//  Copyright © 2019 Vejdirektoratet. All rights reserved.
//

import XCTest
@testable import VejdirektoratetSDK

class ListEntityValidatorTest : XCTestCase {
    override func setUp() {
        super.setUp()
        self.continueAfterFailure = false
    }
    
    func testValidTrafficEntity() {
        let entity = [
            "heading": "",
            "description": "",
            "tag": "",
            "entityType": "latextraffic",
            "timestamp": "2019-09-12T09:20:26.000+0000"
        ] as NSDictionary
        
        let validator = ListEntity.Traffic.TrafficValidator()
        XCTAssertNoThrow(try validator.validate(data: entity))
    }

    func testValidRoadworkEntity() {
        let entity = [
            "heading": "",
            "description": "",
            "tag": "",
            "entityType": "latexroadwork",
            "timestamp": "2019-09-12T09:20:26.000+0000",
            "bounds": [
                "southWest": [
                    "lat": 55.707131,
                    "lng":12.589524
                ] as NSDictionary,
                "northEast": [
                    "lat":55.70728,
                    "lng":12.59096
                ] as NSDictionary
            ] as NSDictionary
        ] as NSDictionary
        
        let validator = ListEntity.Roadwork.RoadworkValidator()
        XCTAssertNoThrow(try validator.validate(data: entity))
    }

    func testInvalidTrafficEntity() {
        let entity = [:] as NSDictionary
        
        let validator = ListEntity.Traffic.TrafficValidator()
        XCTAssertThrowsError(try validator.validate(data: entity))
    }

    func testMissingFields() {
        let validator = ListEntity.Traffic.TrafficValidator()

        let missingHeadingEntity = [
            "description": "",
            "tag": "",
            "entityType": "invalid entity type",
            "timestamp": "2019-09-12T09:20:26.000+0000"
        ] as NSDictionary

        let missingDescriptionEntity = [
            "heading": "",
            "tag": "",
            "entityType": "invalid entity type",
            "timestamp": "2019-09-12T09:20:26.000+0000"
        ] as NSDictionary

        let missingTagEntity = [
            "heading": "",
            "description": "",
            "entityType": "invalid entity type",
            "timestamp": "2019-09-12T09:20:26.000+0000"
        ] as NSDictionary

        let missingEntityTypeEntity = [
            "heading": "",
            "description": "",
            "tag": "",
            "timestamp": "2019-09-12T09:20:26.000+0000"
        ] as NSDictionary

        let missingTimestampEntity = [
            "heading": "",
            "description": "",
            "tag": "",
            "entityType": "invalid entity type"
        ] as NSDictionary

        XCTAssertThrowsError(try validator.validate(data: missingHeadingEntity))
        XCTAssertThrowsError(try validator.validate(data: missingDescriptionEntity))
        XCTAssertThrowsError(try validator.validate(data: missingTagEntity))
        XCTAssertThrowsError(try validator.validate(data: missingEntityTypeEntity))
        XCTAssertThrowsError(try validator.validate(data: missingTimestampEntity))
    }

    func testNullFields() {
        let validator = ListEntity.Traffic.TrafficValidator()
        
        let nullHeadingEntity = [
            "heading": NSNull(),
            "description": "",
            "tag": "",
            "entityType": "latextraffic",
            "timestamp": "2019-09-12T09:20:26.000+0000"
        ] as NSDictionary
        
        let nullDescriptionEntity = [
            "heading": "",
            "description": NSNull(),
            "tag": "",
            "entityType": "latextraffic",
            "timestamp": "2019-09-12T09:20:26.000+0000"
        ] as NSDictionary
        
        let nullTagEntity = [
            "heading": "",
            "description": "",
            "tag": NSNull(),
            "entityType": "latextraffic",
            "timestamp": "2019-09-12T09:20:26.000+0000"
        ] as NSDictionary
        
        let nullEntityTypeEntity = [
            "heading": "",
            "description": "",
            "tag": "",
            "entityType": NSNull(),
            "timestamp": "2019-09-12T09:20:26.000+0000"
        ] as NSDictionary
        
        let nullTimestampEntity = [
            "heading": "",
            "description": "",
            "tag": "",
            "entityType": "latextraffic",
            "timestamp": NSNull()
        ] as NSDictionary
        
        XCTAssertThrowsError(try validator.validate(data: nullHeadingEntity))
        XCTAssertThrowsError(try validator.validate(data: nullDescriptionEntity))
        XCTAssertThrowsError(try validator.validate(data: nullTagEntity))
        XCTAssertThrowsError(try validator.validate(data: nullEntityTypeEntity))
        XCTAssertThrowsError(try validator.validate(data: nullTimestampEntity))
    }

    func testInvalidEntityType() {
        let entity = [
            "heading": "",
            "description": "",
            "tag": "",
            "entityType": "invalid entity type",
            "timestamp": "2019-09-12T09:20:26.000+0000"
        ] as NSDictionary
        
        let validator = ListEntity.Traffic.TrafficValidator()
        XCTAssertThrowsError(try validator.validate(data: entity))
    }

    func testEmptyBounds() {
        let validator = ListEntity.Traffic.TrafficValidator()

        let noBoundsEntity = [
            "heading": "",
            "description": "",
            "tag": "",
            "entityType": "latextraffic",
            "timestamp": "2019-09-12T09:20:26.000+0000"
        ] as NSDictionary
        
        let nullBoundsEntity = [
            "heading": "",
            "description": "",
            "tag": "",
            "entityType": "latextraffic",
            "timestamp": "2019-09-12T09:20:26.000+0000",
            "bounds": NSNull()
        ] as NSDictionary

        XCTAssertNoThrow(try validator.validate(data: noBoundsEntity))
        XCTAssertNoThrow(try validator.validate(data: nullBoundsEntity))
    }

    func testInvalidTimestamp() {
        let entity = [
            "heading": "",
            "description": "",
            "tag": "",
            "entityType": "latextraffic",
            "timestamp": "2019-09-12 09:20:26"
        ] as NSDictionary
        
        let validator = ListEntity.Traffic.TrafficValidator()
        XCTAssertThrowsError(try validator.validate(data: entity))
    }
}
