//
//  BaseHttpTest.swift
//  VejdirektoratetSDKTests
//
//  Created by Daniel Andersen on 16/09/2019.
//  Copyright © 2019 Vejdirektoratet. All rights reserved.
//

import XCTest
import Hippolyte
@testable import VejdirektoratetSDK

class BaseHttpTest : XCTestCase {
    let apiKey = "test_key"
    var expectation = XCTestExpectation(description: "LIST request")

    override func setUp() {
        super.setUp()
        self.continueAfterFailure = false

        self.expectation = XCTestExpectation(description: "API request")
    }

    override class func setUp() {
        super.setUp()
    }
    
    override class func tearDown() {
        Hippolyte.shared.stop()
        Hippolyte.shared.clearStubs()
        super.tearDown()
    }

    func baseUrl() -> String {
        return ""
    }

    func response(_ body: String) -> StubResponse {
        return StubResponse.Builder()
            .stubResponse(withStatusCode: 200)
            .addHeader(withKey: "content-type", value: "application/json;charset=UTF-8")
            .addBody(body.data(using: .utf8)!)
            .build()
    }
    
    func response(statusCode: Int) -> StubResponse {
        return StubResponse.Builder()
            .stubResponse(withStatusCode: statusCode)
            .build()
    }

    func request(response: StubResponse) -> StubRequest {
        let urlRegexp = try? NSRegularExpression(pattern: "\(self.baseUrl()).*", options: [])
        return StubRequest.Builder()
            .stubRequest(withMethod: .GET, urlMatcher: RegexMatcher(regex: urlRegexp!))
            .addResponse(response)
            .build()
    }
}
