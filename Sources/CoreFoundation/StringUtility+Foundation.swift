import Foundation
import SwissKnifeCore

/// StringUtility+Foundation
extension StringUtility {
    /// Returns whether a string matches a regex `pattern`.
    public func matches(_ str: String, pattern: String) -> Bool {
        return str.range(of: pattern, options: .regularExpression) != nil
    }

    /// Trim all whitespaces and new lines line by line
    public func trimAllWhitespaces(_ str: String) -> String {
        str.split(whereSeparator: \.isNewline)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .joined(separator: "\n")
    }

    /// For range X ..< Y, get a new string from line X to line Y.
    public func linesOf(string: String, range: Range<Int>) -> String {
        var str = ""
        let array = string.components(separatedBy: "\n")
        for index in range {
            str += array[index] + "\n"
        }
        return str
    }

    /// Captured `()` groups in pattern
    public func captured(_ str: String, pattern: String, options: NSRegularExpression.Options = []) -> [String] {
        var results = [String]()

        var regex: NSRegularExpression
        do {
            regex = try NSRegularExpression(pattern: pattern, options: options)
        } catch {
            return results
        }
        let matches = regex.matches(in: str, options: [], range: NSRange(location: 0, length: str.count))

        guard let match = matches.first else { return results }

        let lastRangeIndex = match.numberOfRanges - 1
        guard lastRangeIndex >= 1 else { return results }

        for i in 1 ... lastRangeIndex {
            let range = match.range(at: i)
            if range.lowerBound == NSNotFound {
                results.append("")
            } else {
                let matchedString = (str as NSString).substring(with: range)
                results.append(matchedString)
            }
        }

        return results
    }

    public func groups(_ str: String, pattern: String, options: NSRegularExpression.Options = []) throws -> [[String]] {
        let regex = try NSRegularExpression(pattern: pattern, options: options)
        let matches = regex.matches(in: str, range: NSRange(str.startIndex..., in: str))
        return try matches.map { match throws in
            try (0 ..< match.numberOfRanges).map { range throws in
                let rangeBounds = match.range(at: range)
                guard let range = Range(rangeBounds, in: str) else {
                    throw StringError.invalidRange
                }
                return String(str[range])
            }
        }
    }
}