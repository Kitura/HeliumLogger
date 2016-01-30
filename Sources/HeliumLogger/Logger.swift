/**
 * Copyright IBM Corporation 2015
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 **/

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