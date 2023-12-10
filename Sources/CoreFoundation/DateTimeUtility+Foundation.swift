import Foundation
import SwissKnifeCore

/// DateTime+Foundation
public extension DateTimeUtility {
    /// String to Date? with a format.
    func toDate(string: String, format: DateTimeFormat) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = format.string
        return formatter.date(from: string)
    }

    /// Date to String with a format.
    func toString(date: Date, format: DateTimeFormat) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format.string
        return formatter.string(from: date)
    }
}