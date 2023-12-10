/**
 * More date time formats to be added:
 * https://pkg.go.dev/time@go1.21.5#pkg-constants
 */
public enum DateTimeFormat {
    /// "Thu, 30 Nov 2023 03:00:00 GMT"
    case rfc1123

    /// "00:01"
    case timeHHmm

    /// Customized format string
    case other(format: String)

    public var string: String {
        switch self {
        case .rfc1123: "EEE',' dd MMM yyyy HH':'mm':'ss z"
        case .timeHHmm: "HH:mm"
        case let .other(format): format
        }
    }
}

/// Date, time, formatter, calendar.
public struct DateTimeUtility {
}