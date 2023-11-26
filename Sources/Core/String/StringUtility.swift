public struct StringUtility {
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

    /// Remove duplicated lines from a string.
    public func removeDuplicatedLines(_ str: String) -> String {
        let array = str.split(whereSeparator: \.isNewline)
        var set = Set<Substring>()
        return array.filter {
            set.insert($0).inserted
        }.joined(separator: "\n")
    }
}