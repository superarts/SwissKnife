/// Matching `Strings` from `allCases` in `CaseIterable`.
public protocol IteratedCaseMatchable: CaseIterable, RawRepresentable {
    /// Whether a `String` contains any case of `Self`.
    /// Example: `Direction.isContained(by: "Go north.")`
    static func isContained(by string: String) -> Bool

    /// Return `rawValue` of the first case that is contained by `string`.
    /// Example: `Direction.firstStringContained(by: "Go north.") == "north"`
    static func firstStringContained(by string: String) -> String?

    // TODO: implemented these if needed
    // static func firstContained(by string: String) -> Self?
    // static func allStringContained(by string: String) -> [String]
    // static func allContained(by string: String) -> [Self]
}

public extension IteratedCaseMatchable where RawValue == String {
    static func isContained(by string: String) -> Bool {
        Self.allCases.map { $0.rawValue }.contains(where: string.contains)
    }

    static func firstStringContained(by string: String) -> String? {
        for caseString in Self.allCases.map({ $0.rawValue }) {
            if string.contains(caseString) {
                return caseString
            }
        }
        return nil
    }
}