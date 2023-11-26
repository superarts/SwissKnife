import Foundation

/// StringUtility+Foundation
extension StringUtility {
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