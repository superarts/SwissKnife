public typealias LoggerModule = any RawRepresentable<String>

public protocol LoggerManagerRequired {
    var loggerManager: LoggerManager { get set }
}

public extension LoggerManagerRequired {
    var loggerManager: LoggerManager { 
        get { LoggerManager.shared }
        set { LoggerManager.shared = newValue }
    }
}

public struct LoggerManager {
    public static var shared: LoggerManager = LoggerManager()

    /// Debug messages are printed for these modules.
    public var supportedModules = [LoggerModule]()
}