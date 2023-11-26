/// Matching `Strings` from `allCases` in `CaseIterable`.
public protocol IteratedCaseMatchable: CaseIterable, RawRepresentable {
    /// Whether a `String` contains any case of `Self`.
    /// Example: `Direction.isContained(by: "Go north.")`
    static func isContained(by string: String) -> Bool
}

public extension IteratedCaseMatchable where RawValue == String {
    static func isContained(by string: String) -> Bool {
        Self.allCases.map { $0.rawValue }.contains(where: string.contains)
    }
}