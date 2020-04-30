//
//  DateExtension.swift
//  VejdirektoratetSDK
//
//  Created by Daniel Andersen on 13/09/2019.
//  Copyright © 2019 Vejdirektoratet. All rights reserved.
//

import Foundation

internal extension Date {
    static func fromIso8601String(dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        guard let date = dateFormatter.date(from: dateString) else {
            return nil
        }
        return date
    }

    static func toIso8601String(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        return dateFormatter.string(from: date)
    }
}
