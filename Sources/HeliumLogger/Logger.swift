
public enum LoggerMessageType: String {
    case Verbose = "VERBOSE"
    case Info = "INFO"
    case Debug = "DEBUG"
    case Warning = "WARNING"
    case Error = "ERROR"
}

public protocol Logger {
    
    func log(type: LoggerMessageType, msg: String,
        functionName: String, lineNum: Int, fileName: String )
    
}

public class Log {
    
    public static var logger: Logger?
    

    public static func verbose(msg: String, functionName: String = __FUNCTION__,
        lineNum: Int = __LINE__, fileName: String = __FILE__ ) {
            logger?.log( .Verbose, msg: msg,
                functionName: functionName, lineNum: lineNum, fileName: fileName)
    }
    
    public class func info(msg: String, functionName: String = __FUNCTION__,
        lineNum: Int = __LINE__, fileName: String = __FILE__) {
            logger?.log( .Info, msg: msg,
                functionName: functionName, lineNum: lineNum, fileName: fileName)
    }
    
    public class func warning(msg: String, functionName: String = __FUNCTION__,
        lineNum: Int = __LINE__, fileName: String = __FILE__) {
            logger?.log( .Warning, msg: msg,
                functionName: functionName, lineNum: lineNum, fileName: fileName)
    }
    
    public class func error(msg: String, functionName: String = __FUNCTION__,
        lineNum: Int = __LINE__, fileName: String = __FILE__) {
            logger?.log( .Error, msg: msg,
                functionName: functionName, lineNum: lineNum, fileName: fileName)
    }
    
    public class func debug(msg: String, functionName: String = __FUNCTION__,
        lineNum: Int = __LINE__, fileName: String = __FILE__) {
            logger?.log( .Warning, msg: msg,
                functionName: functionName, lineNum: lineNum, fileName: fileName)
    }

    
    
}