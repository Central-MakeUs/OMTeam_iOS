//
//  Calendar+Extension.swift
//  OMT
//
//  Created by 이인호 on 2/9/26.
//

import Foundation

extension Calendar {
    /// A calendar configured with Monday as the first day of the week.
    static var mondayFirst: Calendar {
        var calendar = Calendar.current
        calendar.firstWeekday = 2  // 1 = Sunday, 2 = Monday
        return calendar
    }

    /// Get the week information for a given date based on Monday-Sunday weeks
    /// - Parameter date: The date to get week info for
    /// - Returns: Tuple of (year, month, weekNumber) where the week belongs
    ///            The week belongs to the month where its Monday falls
    func weekInfoFromFirstMonday(for date: Date) -> (year: Int, month: Int, week: Int) {
        // Find which Monday-Sunday week this date belongs to
        let weekday = component(.weekday, from: date)
        
        // Calculate days to subtract to get to Monday of this week
        // weekday: 1=Sun, 2=Mon, 3=Tue, 4=Wed, 5=Thu, 6=Fri, 7=Sat
        let daysToMonday: Int
        if weekday == 1 {  // Sunday
            daysToMonday = 6  // Go back 6 days to Monday
        } else {  // Monday to Saturday
            daysToMonday = weekday - 2  // Mon=0, Tue=1, Wed=2, Thu=3, Fri=4, Sat=5
        }
        
        guard let monday = self.date(byAdding: .day, value: -daysToMonday, to: date) else {
            return (component(.year, from: date),
                    component(.month, from: date),
                    1)
        }
        
        // The week belongs to the month where Monday falls
        let weekMonth = component(.month, from: monday)
        let weekYear = component(.year, from: monday)
        
        // Calculate week number in that month
        let weekNumber = weekOfMonthFromFirstMonday(for: monday)
        
        return (weekYear, weekMonth, weekNumber)
    }

    /// Custom week calculation where week 1 starts from the first Monday of each month.
    /// - Parameter date: The date to calculate the week for
    /// - Returns: Week number (1-5) where week 1 starts from the first Monday.
    ///            Returns 0 if the date is before the first Monday of the month.
    private func weekOfMonthFromFirstMonday(for date: Date) -> Int {
        let year = component(.year, from: date)
        let month = component(.month, from: date)
        let day = component(.day, from: date)

        // Find the first Monday of the month
        guard let firstDayOfMonth = self.date(from: DateComponents(year: year, month: month, day: 1)) else {
            return 1
        }

        let firstDayWeekday = component(.weekday, from: firstDayOfMonth)

        // Calculate days until first Monday (weekday 2)
        let daysUntilMonday: Int
        if firstDayWeekday == 2 {
            daysUntilMonday = 0  // First day is Monday
        } else if firstDayWeekday == 1 {
            daysUntilMonday = 1  // Sunday -> Monday is next day
        } else {
            daysUntilMonday = 9 - firstDayWeekday  // Tue(3)->6, Wed(4)->5, etc.
        }

        let firstMondayDay = 1 + daysUntilMonday

        // If the date is before the first Monday, return 0
        if day < firstMondayDay {
            return 0
        }

        // Calculate which week (1-based) the date falls into
        let daysSinceFirstMonday = day - firstMondayDay
        let weekNumber = (daysSinceFirstMonday / 7) + 1

        return weekNumber
    }

    /// Get a date for a specific week of month using the first-Monday-based calculation.
    /// - Parameters:
    ///   - week: The week number (1-5)
    ///   - month: The month (1-12)
    ///   - year: The year
    /// - Returns: The Monday of that week, or nil if invalid
    func dateFromFirstMondayWeek(week: Int, month: Int, year: Int) -> Date? {
        guard week >= 1 else { return nil }

        // Find the first Monday of the month
        guard let firstDayOfMonth = self.date(from: DateComponents(year: year, month: month, day: 1)) else {
            return nil
        }

        let firstDayWeekday = component(.weekday, from: firstDayOfMonth)

        let daysUntilMonday: Int
        if firstDayWeekday == 2 {
            daysUntilMonday = 0
        } else if firstDayWeekday == 1 {
            daysUntilMonday = 1
        } else {
            daysUntilMonday = 9 - firstDayWeekday
        }

        let firstMondayDay = 1 + daysUntilMonday

        // Calculate the Monday of the requested week
        let targetDay = firstMondayDay + ((week - 1) * 7)

        return self.date(from: DateComponents(year: year, month: month, day: targetDay))
    }
}

