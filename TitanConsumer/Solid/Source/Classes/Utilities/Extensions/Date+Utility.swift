//
//  UIDate+Utility.swift
//  Solid
//
//  Created by Solid iOS Team on 29/05/19.
//  Copyright © 2021 Solid. All rights reserved.
//

import UIKit

extension Date {

    init(milliseconds: Int64) {
        let seconds = TimeInterval(milliseconds) / 1000
        self = Date(timeIntervalSince1970: seconds)
    }

    var millisecondsSince1970: Int64 {
        return Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }

    func diffInMs(inDate: Date) -> Int64 {
        return (self.millisecondsSince1970 - inDate.millisecondsSince1970)
    }

    init(_ dateString: String, format: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        if let theDate = formatter.date(from: dateString) {
            self = theDate
        } else {
            self = Date()

        }
    }

    init(_ dateString: String, format: String, timeZone: TimeZone) {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.timeZone = timeZone

        if let theDate = formatter.date(from: dateString) {
            self = theDate
        } else {
            self = Date()

        }
    }

    init(day: Int, month: Int, year: Int) {
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day

        // Create date from components
        let userCalendar = Calendar.current // user calendar
        let date = userCalendar.date(from: dateComponents)
        self = date ?? Date()
    }

    var day: Int {
        let calendar = Calendar.current
        return calendar.component(.day, from: self)
    }

    var month: Int {
        let calendar = Calendar.current
        return calendar.component(.month, from: self)
    }

    var year: Int {
        let calendar = Calendar.current
        return calendar.component(.year, from: self)
    }

    func isBetween(_ date1: Date, and date2: Date) -> Bool {
        return (min(date1, date2) ... max(date1, date2)).contains(self)
    }
    
    func smartString() -> String {
        let calendar = Calendar.current
        let date = self
        let startOfNow = calendar.startOfDay(for: Date())
        let startOfTimeStamp = calendar.startOfDay(for: date)
        let components = calendar.dateComponents([.day], from: startOfNow, to: startOfTimeStamp)
        let compDay = components.day!
        if abs(compDay) < 2 {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .none
            formatter.doesRelativeDateFormatting = true
            return formatter.string(from: date)
        } else {
            return "\(-compDay) days ago"
        }
    }

    func getGeneralisedInAppDate() -> String {
        var dateText = ""
        let calendar = Calendar.current
        if calendar.isDateInToday(self) {
            dateText = "Today"
        } else if calendar.isDateInYesterday(self) {
            dateText = "Yesterday"
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM dd, yyyy"
            dateText = dateFormatter.string(from: self)
        }
        return dateText
    }

    func convertDateTo(format: String) -> String {

        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }

    func countTransactionDate() -> String {
        // let today = Date()
        let calendar = Calendar.current

        if calendar.isDateInToday(self) {
            let formatter = DateFormatter()
            formatter.dateFormat = "hh:mm a"
            formatter.timeZone = TimeZone.current
            var date =  formatter.string(from: self)
            date =     "Today, \(date)"
            return date
        } else {
             let formatter = DateFormatter()
             formatter.dateFormat = "MMM dd, yyyy h:mm a"
             formatter.timeZone = TimeZone.current
             return formatter.string(from: self)
        }
    }

    var startOfWeek: Date? {
        let gregorian = Calendar(identifier: .gregorian)
        guard let sunday = gregorian.date(from: gregorian.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)) else { return nil }
        return gregorian.date(byAdding: .day, value: 1, to: sunday)
    }

    var endOfWeek: Date? {
        let gregorian = Calendar(identifier: .gregorian)
        guard let sunday = gregorian.date(from: gregorian.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)) else { return nil }
        return gregorian.date(byAdding: .day, value: 7, to: sunday)
    }

    func isSameDayAs(theDate: Date) -> Bool {
        return self.year == theDate.year &&
            self.month == theDate.month &&
            self.day == theDate.day
    }

    func dateFormatWithSuffix() -> String {
        return "MMM dd'\(self.daySuffix())', yyyy"
    }

    func daySuffix() -> String {
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components(.day, from: self)
        let dayOfMonth = components.day
        switch dayOfMonth {
        case 1, 21, 31:
            return "st"
        case 2, 22:
            return "nd"
        case 3, 23:
            return "rd"
        default:
            return "th"
        }
    }

    func getDateString() -> String {

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: self)
    }
}
