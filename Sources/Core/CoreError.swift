/// Errors that are common in 
public enum CoreError: Error {
    /// Customized implementation is needed
    case implementationRequired(message: String? = nil)

    /// Get `nil` at an unexpected place
    case unexpectedNil(message: String? = nil)

    /// Cannot convert certain types
    case conversionFailure(message: String? = nil)

    /// Index out of bound
    case outOfBound(message: String? = nil)
}