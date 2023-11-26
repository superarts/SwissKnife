/// An `EnvironmentRequired` component can access `currentEnvironment`.
public protocol EnvironmentRequired {
    var environment: Environment { get }
}

/// Default implementation of `currentEnvironment`.
public extension EnvironmentRequired {
    var environment: Environment {
        CompileTimeEnvironment()
    }
}

public protocol Environment {
    var isDebug: Bool { get }
    var isRelease: Bool { get }
}

struct CompileTimeEnvironment: Environment {
    var isDebug: Bool {
        // We could create an Objective-C class to handle CLANG Preprocessor Macros
        isConditionalCompilationDebug
    }

    var isRelease: Bool {
        !isDebug
    }

    /// From Swift Active Conditonal Compilation Flags
    private var isConditionalCompilationDebug: Bool {
        #if DEBUG
            return true
        #else
            return false
        #endif
    }
}