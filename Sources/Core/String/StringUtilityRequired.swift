public protocol StringUtilityRequired {
    var stringUtility: StringUtility { get }
}

public extension StringUtilityRequired {
    var stringUtility: StringUtility { StringUtility() }
}