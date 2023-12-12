/// Can `log`.
public protocol Loggable {
    @discardableResult
    func log(_ module: LoggerModule, _ message: String) -> String?
}

/// Loggable+Log
public extension Loggable {
    @discardableResult
    func log(_ module: LoggerModule, _ message: String) -> String? {
        return Logger().log(module, message)
    }
}