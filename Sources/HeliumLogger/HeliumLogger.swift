

public enum TerminalColor: String {
    case White = "\u{001B}[0;37m" // white
    case Red = "\u{001B}[0;31m" // red
    case Yellow = "\u{001B}[0;33m" // yellow
}

public class HeliumLogger : Logger {
    
    /// 
    /// Singleton instance of the logger
    // static public var logger: Logger?
    
    public var colored: Bool = true
    
    public var details: Bool = true
    
    public init () {}
    
    public func log(type: LoggerMessageType, msg: String,
        functionName: String, lineNum: Int, fileName: String ) {
            
            var color : TerminalColor = .White
            
            if type == .Warning {
                color = .Yellow
            } else if type == .Error {
                color = .Red
            } else {
                color = .White
            }
            
            if colored && details {
                print ("\(color.rawValue) \(type.rawValue): \(functionName) \(fileName) line \(lineNum) - \(msg) \(TerminalColor.White.rawValue)")
            } else if !colored && details {
                print (" \(type.rawValue): \(functionName) \(fileName) line \(lineNum) - \(msg)")
            } else if colored && !details {
                print ("\(color.rawValue) \(type.rawValue): \(msg) \(TerminalColor.White.rawValue)")
            } else {
                print (" \(type.rawValue): \(msg)")
            }

            
    }
    
    
    
}