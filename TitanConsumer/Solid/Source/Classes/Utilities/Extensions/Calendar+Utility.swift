//
//  Calendar+Utility.swift
//  Solid
//
//  Created by Solid iOS Team on 20/04/19.
//  Copyright © 2021 Solid. All rights reserved.
//

import Foundation

extension Calendar {

    func isDateInWeek(date: Date) -> Bool {
        let now = Date()
        return self.isDate(date, equalTo: now, toGranularity: .weekOfYear)
    }

    func isDateInMonth(date: Date) -> Bool {
        let now = Date()
        return self.isDate(date, equalTo: now, toGranularity: .month)
    }

    func isDateInLastMonth(date: Date) -> Bool {
        guard let dayInLastMonth = self.date(byAdding: DateComponents(month: -1), to: date) else {
            return false
        }
        let startOfMonth = self.startOfMonth(for: dayInLastMonth)
        let endOfMonth = self.endOfMonth(for: dayInLastMonth)
        let range = startOfMonth...endOfMonth
        return range.contains(date)
    }

    func isDateInYear(date: Date) -> Bool {
        let now = Date()
        return self.isDate(date, equalTo: now, toGranularity: .year)
    }

    func startOfMonth(for date: Date) -> Date {
        return self.date(from: self.dateComponents([.year, .month], from: self.startOfDay(for: date))) ?? date
    }

    func endOfMonth(for date: Date) -> Date {
        return self.date(byAdding: DateComponents(month: 1, day: -1), to: self.startOfMonth(for: date)) ?? date
    }

	func endOfMonthForTransactionFilter(for date: Date) -> Date {
		return self.date(byAdding: DateComponents(month: 1, day: -1, hour: 23, minute: 59, second: 59), to: self.startOfMonth(for: date)) ?? date
	}
}
