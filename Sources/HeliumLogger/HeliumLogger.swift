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

import LoggerAPI
import Foundation

public enum TerminalColor: String {
    case White = "\u{001B}[0;37m" // white
    case Red = "\u{001B}[0;31m" // red
    case Yellow = "\u{001B}[0;33m" // yellow
    case Foreground = "\u{001B}[0;39m" // default foreground color
    case Background = "\u{001B}[0;49m" // default background color
}

public enum HeliumLoggerFormatValues: String {
    case Message = "(%msg)"
    case Function = "(%func)"
    case Line = "(%line)"
    case File = "(%file)"
    case LogType = "(%type)"
    case Date = "(%date)"

    static let All: [HeliumLoggerFormatValues] = [
        .Message, .Function, .Line, .File, .LogType, .Date
    ]
}

public class HeliumLogger {

    ///
    /// Singleton instance of the logger
    // static public var logger: Logger?

    public var colored: Bool = true

    public var details: Bool = true

    public var format: String?
    public var dateFormat: String?

    private static let detailedFormat = "(%type): (%func) (%file) line (%line) - (%msg)"
    private static let defaultFormat = "(%type): (%msg)"
    private static let defaultDateFormat = "dd.MM.YYYY, HH:mm:ss"

    public init () {}
}

extension HeliumLogger : Logger {
    
    public func log(_ type: LoggerMessageType, msg: String,
        functionName: String, lineNum: Int, fileName: String ) {

            let color : TerminalColor

            switch type {
                case .Warning:
                    color = .Yellow
                case .Error:
                    color = .Red
                default:
                    color = .Foreground
            }

            var message: String = self.format ?? (self.details ? HeliumLogger.detailedFormat : HeliumLogger.defaultFormat)

            for formatValue in HeliumLoggerFormatValues.All {
                let stringValue = formatValue.rawValue
                let replaceValue: String
                switch formatValue {
                      case .LogType:
                          replaceValue = type.rawValue
                      case .Message:
                          replaceValue = msg
                      case .Function:
                          replaceValue = functionName
                      case .Line:
                          replaceValue = "\(lineNum)"
                      case .File:
                          let fileNameUrl = NSURL(string: fileName)
                          replaceValue = fileNameUrl?.lastPathComponent ?? fileName
                      case .Date:
                          let date = NSDate()
                          let dateFormatter = NSDateFormatter()
                          dateFormatter.dateFormat = self.dateFormat ?? HeliumLogger.defaultDateFormat
                          #if os(Linux)
                              replaceValue = dateFormatter.stringFromDate(date)
                          #else
                              replaceValue = dateFormatter.string(from: date)
                          #endif
                }

                #if os(Linux)
                    message = message.stringByReplacingOccurrencesOfString(stringValue, withString: replaceValue)
                #else
                    message = message.replacingOccurrences(of: stringValue, with: replaceValue)
                #endif
            }

            if colored {
                print ("\(color.rawValue) \(message) \(TerminalColor.Foreground.rawValue)")
            } else {
                print (" \(message) ")
            }
    }
}
