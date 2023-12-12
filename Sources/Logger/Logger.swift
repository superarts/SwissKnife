import SwissKnifeCore

/// A quick and dirty logger.
public struct Logger: EnvironmentRequired {
    /// Print log only when the module is supported by `LoggerManager`.
    /// Returns what's literally printed.
    @discardableResult
    func log(_ module: LoggerModule, _ message: String) -> String? {
        if environment.isDebug {
            // if LoggerManager.shared.supportedModules.contains(module) { }
            if LoggerManager.shared.supportedModules.contains(where: { supportedModule in
                supportedModule.rawValue == module.rawValue
            }) {
                let output = "[\(module.rawValue)] \(message)"
                print(output)
                return output
            }
        }
        return nil
    }

    // TODO: is there any value of this function?
    /*
     @available(*, deprecated, message: "Not fully implemented. Use log(module, message) instead.")
     func log(_ message: String) {
         if environment.isDebug {
             if let string = Module.firstStringContained(by: message) {
                 print(message.replacingOccurrences(of: string, with: "[\(string)]"))
             }
         }
     }
      */
}