public struct StringUtility {
    /// Remove duplicated lines from a string.
    public func removeDuplicatedLines(_ str: String) -> String {
        let array = str.split(whereSeparator: \.isNewline)
        var set = Set<Substring>()
        return array.filter {
            set.insert($0).inserted
        }.joined(separator: "\n")
    }
}