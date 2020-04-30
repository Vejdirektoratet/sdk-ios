//
//  MapEntityValidatorTest.swift
//  VejdirektoratetSDKTests
//
//  Created by Daniel Andersen on 18/09/2019.
//  Copyright © 2019 Vejdirektoratet. All rights reserved.
//

import XCTest
@testable import VejdirektoratetSDK

class MapEntityValidatorTest : XCTestCase {
    override func setUp() {
        super.setUp()
        self.continueAfterFailure = false
    }
    
    func testValidMarkerEntity() {
        let entity = [
            "entityType": "latextraffic",
            "tag": "VHJhZmlrbWFuMi9yX1RyYWZpa21hbjIvMTMzNDQzMl9USUMtVHJhZmlrbWFuMi8x",
            "center": [ "lat": 55.808418, "lng": 11.582623] as NSDictionary,
            "style": [
                "id": "Trafficevent.Activity",
                "strokeColor": "#ff0000ff",
                "strokeWidth": 3.0,
                "fillColor": "#ff000088",
                "icon": "https://s3-eu-west-1.amazonaws.com/static.nap.vd.dk/icons/roadsign_trafikmelding.png",
                "dashed": false,
                "dashColor": "#000000ff",
                "zIndex": 0
            ] as NSDictionary,
            "type":"MARKER"
        ] as NSDictionary
        
        let validator = MapMarker.MarkerValidator()
        XCTAssertNoThrow(try validator.validate(data: entity))
    }

    func testInvalidMarkerEntity() {
        let entity = [:] as NSDictionary
        
        let validator = MapMarker.MarkerValidator()
        XCTAssertThrowsError(try validator.validate(data: entity))
    }

    func testMissingMarkerFields() {
        let validator = MapMarker.MarkerValidator()

        let missingEntityTypeEntity = [
            "tag": "VHJhZmlrbWFuMi9yX1RyYWZpa21hbjIvMTMzNDQzMl9USUMtVHJhZmlrbWFuMi8x",
            "center": [ "lat": 55.808418, "lng": 11.582623] as NSDictionary,
            "type":"MARKER",
            "style": ["id": "Trafficevent.Activity", "strokeColor": "#ff0000ff", "strokeWidth": 3.0, "fillColor": "#ff000088", "icon": "", "dashed": false, "dashColor": "#000000ff", "zIndex": 0] as NSDictionary
        ] as NSDictionary
        
        let missingTagEntity = [
            "entityType": "latextraffic",
            "center": [ "lat": 55.808418, "lng": 11.582623] as NSDictionary,
            "type":"MARKER",
            "style": ["id": "Trafficevent.Activity", "strokeColor": "#ff0000ff", "strokeWidth": 3.0, "fillColor": "#ff000088", "icon": "", "dashed": false, "dashColor": "#000000ff", "zIndex": 0] as NSDictionary
        ] as NSDictionary

        let missingCenterEntity = [
            "entityType": "latextraffic",
            "tag": "VHJhZmlrbWFuMi9yX1RyYWZpa21hbjIvMTMzNDQzMl9USUMtVHJhZmlrbWFuMi8x",
            "type":"MARKER",
            "style": ["id": "Trafficevent.Activity", "strokeColor": "#ff0000ff", "strokeWidth": 3.0, "fillColor": "#ff000088", "icon": "", "dashed": false, "dashColor": "#000000ff", "zIndex": 0] as NSDictionary
        ] as NSDictionary

        let missingTypeEntity = [
            "entityType": "latextraffic",
            "tag": "VHJhZmlrbWFuMi9yX1RyYWZpa21hbjIvMTMzNDQzMl9USUMtVHJhZmlrbWFuMi8x",
            "center": [ "lat": 55.808418, "lng": 11.582623] as NSDictionary,
            "style": ["id": "Trafficevent.Activity", "strokeColor": "#ff0000ff", "strokeWidth": 3.0, "fillColor": "#ff000088", "icon": "", "dashed": false, "dashColor": "#000000ff", "zIndex": 0] as NSDictionary
        ] as NSDictionary

        let missingStyleEntity = [
            "entityType": "latextraffic",
            "tag": "VHJhZmlrbWFuMi9yX1RyYWZpa21hbjIvMTMzNDQzMl9USUMtVHJhZmlrbWFuMi8x",
            "center": [ "lat": 55.808418, "lng": 11.582623] as NSDictionary
        ] as NSDictionary

        XCTAssertThrowsError(try validator.validate(data: missingEntityTypeEntity))
        XCTAssertThrowsError(try validator.validate(data: missingTagEntity))
        XCTAssertThrowsError(try validator.validate(data: missingCenterEntity))
        XCTAssertThrowsError(try validator.validate(data: missingTypeEntity))
        XCTAssertThrowsError(try validator.validate(data: missingStyleEntity))
    }

    func testNullMarkerFields() {
        let validator = MapMarker.MarkerValidator()

        let missingEntityTypeEntity = [
            "tag": "VHJhZmlrbWFuMi9yX1RyYWZpa21hbjIvMTMzNDQzMl9USUMtVHJhZmlrbWFuMi8x",
            "center": [ "lat": 55.808418, "lng": 11.582623] as NSDictionary,
            "type":"MARKER",
            "style": ["id": "Trafficevent.Activity", "strokeColor": "#ff0000ff", "strokeWidth": 3.0, "fillColor": "#ff000088", "icon": "", "dashed": false, "dashColor": "#000000ff", "zIndex": 0] as NSDictionary,
            "entityType": NSNull()
        ] as NSDictionary
        
        let missingTagEntity = [
            "entityType": "latextraffic",
            "center": [ "lat": 55.808418, "lng": 11.582623] as NSDictionary,
            "type":"MARKER",
            "style": ["id": "Trafficevent.Activity", "strokeColor": "#ff0000ff", "strokeWidth": 3.0, "fillColor": "#ff000088", "icon": "", "dashed": false, "dashColor": "#000000ff", "zIndex": 0] as NSDictionary,
            "tag": NSNull()
        ] as NSDictionary

        let missingCenterEntity = [
            "entityType": "latextraffic",
            "tag": "VHJhZmlrbWFuMi9yX1RyYWZpa21hbjIvMTMzNDQzMl9USUMtVHJhZmlrbWFuMi8x",
            "type":"MARKER",
            "style": ["id": "Trafficevent.Activity", "strokeColor": "#ff0000ff", "strokeWidth": 3.0, "fillColor": "#ff000088", "icon": "", "dashed": false, "dashColor": "#000000ff", "zIndex": 0] as NSDictionary,
            "center": NSNull()
        ] as NSDictionary

        let missingTypeEntity = [
            "entityType": "latextraffic",
            "tag": "VHJhZmlrbWFuMi9yX1RyYWZpa21hbjIvMTMzNDQzMl9USUMtVHJhZmlrbWFuMi8x",
            "center": [ "lat": 55.808418, "lng": 11.582623] as NSDictionary,
            "style": ["id": "Trafficevent.Activity", "strokeColor": "#ff0000ff", "strokeWidth": 3.0, "fillColor": "#ff000088", "icon": "", "dashed": false, "dashColor": "#000000ff", "zIndex": 0] as NSDictionary,
            "type": NSNull()
        ] as NSDictionary

        let missingStyleEntity = [
            "entityType": "latextraffic",
            "tag": "VHJhZmlrbWFuMi9yX1RyYWZpa21hbjIvMTMzNDQzMl9USUMtVHJhZmlrbWFuMi8x",
            "type":"MARKER",
            "center": ["lat": 55.808418, "lng": 11.582623] as NSDictionary,
            "style": NSNull()
        ] as NSDictionary

        XCTAssertThrowsError(try validator.validate(data: missingEntityTypeEntity))
        XCTAssertThrowsError(try validator.validate(data: missingTagEntity))
        XCTAssertThrowsError(try validator.validate(data: missingCenterEntity))
        XCTAssertThrowsError(try validator.validate(data: missingTypeEntity))
        XCTAssertThrowsError(try validator.validate(data: missingStyleEntity))
    }

    func testValidPolylineEntity() {
        let entity = [
            "entityType": "latextraffic",
            "tag": "VHJhZmlrbWFuMi9yX1RyYWZpa21hbjIvMTMzNDQzMF9USUMtVHJhZmlrbWFuMi8x",
            "points": [
                [ "lat": 56.46536, "lng": 9.98535 ] as NSDictionary,
                [ "lat": 56.46492, "lng": 9.98551 ] as NSDictionary
            ] as NSArray,
            "style": ["id": "Trafficevent.Activity", "strokeColor": "#ff0000ff", "strokeWidth": 3.0, "fillColor": "#ff000088", "icon": "", "dashed": false, "dashColor": "#000000ff", "zIndex": 0] as NSDictionary,
            "type": "POLYLINE"
        ] as NSDictionary
        
        let validator = MapPolyline.PolylineValidator()
        XCTAssertNoThrow(try validator.validate(data: entity))
    }
    
    func testInvalidPolylineEntity() {
        let entity = [:] as NSDictionary
        
        let validator = MapPolyline.PolylineValidator()
        XCTAssertThrowsError(try validator.validate(data: entity))
    }

    func testMissingPolylineFields() {
        let validator = MapPolyline.PolylineValidator()

        let missingEntityTypeEntity = [
            "tag": "VHJhZmlrbWFuMi9yX1RyYWZpa21hbjIvMTMzNDQzMF9USUMtVHJhZmlrbWFuMi8x",
            "points": [
                [ "lat": 56.46536, "lng": 9.98535 ] as NSDictionary,
                [ "lat": 56.46492, "lng": 9.98551 ] as NSDictionary
            ] as NSArray,
            "type": "POLYLINE"
        ] as NSDictionary
        
        let missingTagEntity = [
            "entityType": "latextraffic",
            "points": [
                [ "lat": 56.46536, "lng": 9.98535 ] as NSDictionary,
                [ "lat": 56.46492, "lng": 9.98551 ] as NSDictionary
            ] as NSArray,
            "type": "POLYLINE"
        ] as NSDictionary

        let missingPointsEntity = [
            "tag": "VHJhZmlrbWFuMi9yX1RyYWZpa21hbjIvMTMzNDQzMF9USUMtVHJhZmlrbWFuMi8x",
            "entityType": "latextraffic",
            "type": "POLYLINE"
        ] as NSDictionary

        let missingTypeEntity = [
            "tag": "VHJhZmlrbWFuMi9yX1RyYWZpa21hbjIvMTMzNDQzMF9USUMtVHJhZmlrbWFuMi8x",
            "entityType": "latextraffic",
            "points": [
                [ "lat": 56.46536, "lng": 9.98535 ] as NSDictionary,
                [ "lat": 56.46492, "lng": 9.98551 ] as NSDictionary
            ] as NSArray
        ] as NSDictionary

        XCTAssertThrowsError(try validator.validate(data: missingEntityTypeEntity))
        XCTAssertThrowsError(try validator.validate(data: missingTagEntity))
        XCTAssertThrowsError(try validator.validate(data: missingPointsEntity))
        XCTAssertThrowsError(try validator.validate(data: missingTypeEntity))
    }

    func testNullPolylineFields() {
        let validator = MapPolyline.PolylineValidator()

        let missingEntityTypeEntity = [
            "tag": "VHJhZmlrbWFuMi9yX1RyYWZpa21hbjIvMTMzNDQzMF9USUMtVHJhZmlrbWFuMi8x",
            "points": [
                [ "lat": 56.46536, "lng": 9.98535 ] as NSDictionary,
                [ "lat": 56.46492, "lng": 9.98551 ] as NSDictionary
            ] as NSArray,
            "type": "POLYLINE",
            "entityType": NSNull()
        ] as NSDictionary
        
        let missingTagEntity = [
            "entityType": "latextraffic",
            "points": [
                [ "lat": 56.46536, "lng": 9.98535 ] as NSDictionary,
                [ "lat": 56.46492, "lng": 9.98551 ] as NSDictionary
            ] as NSArray,
            "type": "POLYLINE",
            "tag": NSNull()
        ] as NSDictionary

        let missingPointsEntity = [
            "tag": "VHJhZmlrbWFuMi9yX1RyYWZpa21hbjIvMTMzNDQzMF9USUMtVHJhZmlrbWFuMi8x",
            "entityType": "latextraffic",
            "type": "POLYLINE",
            "points": NSNull()
        ] as NSDictionary

        let missingTypeEntity = [
            "tag": "VHJhZmlrbWFuMi9yX1RyYWZpa21hbjIvMTMzNDQzMF9USUMtVHJhZmlrbWFuMi8x",
            "entityType": "latextraffic",
            "points": [
                [ "lat": 56.46536, "lng": 9.98535 ] as NSDictionary,
                [ "lat": 56.46492, "lng": 9.98551 ] as NSDictionary
            ] as NSArray,
            "type": NSNull()
        ] as NSDictionary

        XCTAssertThrowsError(try validator.validate(data: missingEntityTypeEntity))
        XCTAssertThrowsError(try validator.validate(data: missingTagEntity))
        XCTAssertThrowsError(try validator.validate(data: missingPointsEntity))
        XCTAssertThrowsError(try validator.validate(data: missingTypeEntity))
    }

    func testValidPolygonEntity() {
        let entity = [
            "entityType": "latextraffic",
            "tag": "VHJhZmlrbWFuMi9yX1RyYWZpa21hbjIvMTMzNDQzMF9USUMtVHJhZmlrbWFuMi8x",
            "points": [
                [ "lat": 56.46536, "lng": 9.98535 ] as NSDictionary,
                [ "lat": 56.46492, "lng": 9.98551 ] as NSDictionary
            ] as NSArray,
            "style": [
                "id": "Trafficevent.Activity",
                "strokeColor": "#ff0000ff",
                "strokeWidth": 3.0,
                "fillColor": "#ff000088",
                "icon": "https://s3-eu-west-1.amazonaws.com/static.nap.vd.dk/icons/roadsign_trafikmelding.png",
                "dashed": false,
                "dashColor": "#000000ff",
                "zIndex": 0
            ] as NSDictionary,
            "type": "POLYGON"
        ] as NSDictionary
        
        let validator = MapPolygon.PolygonValidator()
        XCTAssertNoThrow(try validator.validate(data: entity))
    }
    
    func testInvalidPolygonEntity() {
        let entity = [:] as NSDictionary
        
        let validator = MapPolygon.PolygonValidator()
        XCTAssertThrowsError(try validator.validate(data: entity))
    }
    
    func testMissingPolygonFields() {
        let validator = MapPolygon.PolygonValidator()

        let missingEntityTypeEntity = [
            "tag": "VHJhZmlrbWFuMi9yX1RyYWZpa21hbjIvMTMzNDQzMF9USUMtVHJhZmlrbWFuMi8x",
            "points": [
                [ "lat": 56.46536, "lng": 9.98535 ] as NSDictionary,
                [ "lat": 56.46492, "lng": 9.98551 ] as NSDictionary
            ] as NSArray,
            "type": "POLYGON"
        ] as NSDictionary
        
        let missingTagEntity = [
            "entityType": "latextraffic",
            "points": [
                [ "lat": 56.46536, "lng": 9.98535 ] as NSDictionary,
                [ "lat": 56.46492, "lng": 9.98551 ] as NSDictionary
            ] as NSArray,
            "type": "POLYGON"
        ] as NSDictionary
        
        let missingPointsEntity = [
            "tag": "VHJhZmlrbWFuMi9yX1RyYWZpa21hbjIvMTMzNDQzMF9USUMtVHJhZmlrbWFuMi8x",
            "entityType": "latextraffic",
            "type": "POLYGON"
        ] as NSDictionary
        
        let missingTypeEntity = [
            "tag": "VHJhZmlrbWFuMi9yX1RyYWZpa21hbjIvMTMzNDQzMF9USUMtVHJhZmlrbWFuMi8x",
            "entityType": "latextraffic",
            "points": [
                [ "lat": 56.46536, "lng": 9.98535 ] as NSDictionary,
                [ "lat": 56.46492, "lng": 9.98551 ] as NSDictionary
            ] as NSArray
        ] as NSDictionary
        
        XCTAssertThrowsError(try validator.validate(data: missingEntityTypeEntity))
        XCTAssertThrowsError(try validator.validate(data: missingTagEntity))
        XCTAssertThrowsError(try validator.validate(data: missingPointsEntity))
        XCTAssertThrowsError(try validator.validate(data: missingTypeEntity))
    }

    func testNullPolygonFields() {
        let validator = MapPolygon.PolygonValidator()

        let missingEntityTypeEntity = [
            "tag": "VHJhZmlrbWFuMi9yX1RyYWZpa21hbjIvMTMzNDQzMF9USUMtVHJhZmlrbWFuMi8x",
            "points": [
                [ "lat": 56.46536, "lng": 9.98535 ] as NSDictionary,
                [ "lat": 56.46492, "lng": 9.98551 ] as NSDictionary
            ] as NSArray,
            "type": "POLYGON",
            "entityType": NSNull()
        ] as NSDictionary
        
        let missingTagEntity = [
            "entityType": "latextraffic",
            "points": [
                [ "lat": 56.46536, "lng": 9.98535 ] as NSDictionary,
                [ "lat": 56.46492, "lng": 9.98551 ] as NSDictionary
            ] as NSArray,
            "type": "POLYGON",
            "tag": NSNull()
        ] as NSDictionary
        
        let missingPointsEntity = [
            "tag": "VHJhZmlrbWFuMi9yX1RyYWZpa21hbjIvMTMzNDQzMF9USUMtVHJhZmlrbWFuMi8x",
            "entityType": "latextraffic",
            "type": "POLYGON",
            "points": NSNull()
        ] as NSDictionary
        
        let missingTypeEntity = [
            "tag": "VHJhZmlrbWFuMi9yX1RyYWZpa21hbjIvMTMzNDQzMF9USUMtVHJhZmlrbWFuMi8x",
            "entityType": "latextraffic",
            "points": [
                [ "lat": 56.46536, "lng": 9.98535 ] as NSDictionary,
                [ "lat": 56.46492, "lng": 9.98551 ] as NSDictionary
            ] as NSArray,
            "type": NSNull()
        ] as NSDictionary
        
        XCTAssertThrowsError(try validator.validate(data: missingEntityTypeEntity))
        XCTAssertThrowsError(try validator.validate(data: missingTagEntity))
        XCTAssertThrowsError(try validator.validate(data: missingPointsEntity))
        XCTAssertThrowsError(try validator.validate(data: missingTypeEntity))
    }
}
