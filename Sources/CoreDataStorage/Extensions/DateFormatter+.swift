//
//  DateFormatter+.swift
//  CoreDataDemo1
//
//  Created by Boyce Estes on 5/9/21.
//

import Foundation

extension DateFormatter {

    static let yyyyMMdd: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}
