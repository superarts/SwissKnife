/// A very, very basic terminal color helper
public enum TerminalColor: String, CaseIterable {
    public enum Style: String, CaseIterable {
        /// Regular color; tested in iTerm2
        case regular = "0"

        /// Bold an more obvious
        case bold = "1"

        /// A bit darker than regular/0
        case dark = "2"

        /// Underline but some colors are off from blue/34, see unit tests output
        case underline = "4"

        // seems to be the same with bold/1
        // case test3 = "3"
        // case test5 = "5"
    }

    case reset = "\u{001B}[m"
    case black = "30"
    case red = "31"
    case green = "32"
    case yellow = "33"
    case blue = "34"
    case purple = "35"
    case cyan = "36"
    case white = "37"

    // Style?
    // public var regular: String { "\u{001B}[0;\(rawValue)m" }
    // public var bold: String { "\u{001B}[1;\(rawValue)m" }
    // public var underline: String { "\u{001B}[4;\(rawValue)m" }

    // Theme?
    // static let command = Self.lightCyan
    // static let output = Self.lightRed

    /// Terminal color string
    public func string(style: Style = .bold) -> String {
        if self == .reset {
            return rawValue
        }
        return "\u{001B}[\(style.rawValue);\(rawValue)m"
    }

    /// Returns colored string
    public func string(_ str: String, style: Style = .bold) -> String {
        "\(string(style: style))\(str)\(Self.reset.string())"
    }
}