/// DateTime+DependencyInjection
public protocol DateTimeUtilityRequired {
    var dateTimeUtility: DateTimeUtility { get }
}

public extension DateTimeUtilityRequired {
    var dateTimeUtility: DateTimeUtility { DateTimeUtility() }
}