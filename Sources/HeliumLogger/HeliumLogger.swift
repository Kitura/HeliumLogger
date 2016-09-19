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

/// The set of colors used when logging with colorized lines
public enum TerminalColor: String {
    /// Log text in white.
    case white = "\u{001B}[0;37m" // white
    /// Log text in red, used for error messages.
    case red = "\u{001B}[0;31m" // red
    /// Log text in yellow, used for warning messages.
    case yellow = "\u{001B}[0;33m" // yellow
    /// Log text in the terminal's default foreground color.
    case foreground = "\u{001B}[0;39m" // default foreground color
    /// Log text in the terminal's default background color.
    case background = "\u{001B}[0;49m" // default background color
}

/// The set of substitution "variables" that can be used when formatting one's
/// logged messages.
public enum HeliumLoggerFormatValues: String {
    /// The message being logged.
    case message = "(%msg)"
    /// The name of the function invoking the logger API.
    case function = "(%func)"
    /// The line in the source code of the function invoking the logger API.
    case line = "(%line)"
    /// The file of the source code of the function invoking the logger API.
    case file = "(%file)"
    /// The type of the logged message (i.e. error, warning, etc.).
    case logType = "(%type)"
    /// The time and date at which the message was logged.
    case date = "(%date)"

    static let All: [HeliumLoggerFormatValues] = [
        .message, .function, .line, .file, .logType, .date
    ]
}

/// A light weight implementation of the `LoggerAPI` protocol.
public class HeliumLogger {

    /// Whether, if true, or not the logger output should be colorized.
    public var colored: Bool = false

    /// If true, use the detailed format when a user logging format wasn't specified.
    public var details: Bool = true

    /// If not nil, specifies the user specified logging format.
    public var format: String?
    
    /// If not nil, specifies the format used when adding the date and the time to the
    /// logged messages
    public var dateFormat: String?

    fileprivate static let detailedFormat = "(%type): (%func) (%file) line (%line) - (%msg)"
    fileprivate static let defaultFormat = "(%type): (%msg)"
    fileprivate static let defaultDateFormat = "dd.MM.YYYY, HH:mm:ss"

    /// Create a `HeliumLogger` instance
    public init() {}

    /// Create a `HeliumLogger` instance and set it up as the logger used by the `LoggerAPI`
    /// protocol.
    /// - Parameter type: The most detailed message type (`LoggerMessageType`) to see in the
    ///                  output of the logger. Defaults to `verbose`.
    public static func use(_ type: LoggerMessageType = .verbose) {
        Log.logger = HeliumLogger(type)
        setbuf(stdout, nil)
    }
    
    fileprivate var type: LoggerMessageType = .verbose
    
    /// Create a `HeliumLogger` instance
    ///
    /// - Parameter type: The most detailed message type (`LoggerMessageType`) to see in the
    ///                  output of the logger.
    public init (_ type: LoggerMessageType) {
        self.type = type
    }
}

/// Implement the `LoggerAPI` protocol in the `HeliumLogger` class.
extension HeliumLogger : Logger {

    /// Output a logged message.
    ///
    /// - Parameter type: The type of the message (`LoggerMessageType`) being logged.
    /// - Parameter msg: The mesage to be logged
    /// - Parameter functionName: The name of the function invoking the logger API.
    /// - Parameter lineNum: The line in the source code of the function invoking the
    ///                     logger API.
    /// - Parameter fileName: The file of the source code of the function invoking the
    ///                      logger API.
    public func log(_ type: LoggerMessageType, msg: String,
        functionName: String, lineNum: Int, fileName: String ) {

            let color : TerminalColor

            switch type {
                case .warning:
                    color = .yellow
                case .error:
                    color = .red
                default:
                    color = .foreground
            }

            var message: String = self.format ?? (self.details ? HeliumLogger.detailedFormat : HeliumLogger.defaultFormat)

            for formatValue in HeliumLoggerFormatValues.All {
                let stringValue = formatValue.rawValue
                let replaceValue: String
                switch formatValue {
                      case .logType:
                          replaceValue = type.description
                      case .message:
                          replaceValue = msg
                      case .function:
                          replaceValue = functionName
                      case .line:
                          replaceValue = "\(lineNum)"
                      case .file:
                          let fileNameUrl = NSURL(string: fileName)
                          replaceValue = fileNameUrl?.lastPathComponent ?? fileName
                      case .date:
                          let date = Date()
                          let dateFormatter = DateFormatter()
                          dateFormatter.dateFormat = self.dateFormat ?? HeliumLogger.defaultDateFormat
                          replaceValue = dateFormatter.string(from: date)
                }

                message = message.replacingOccurrences(of: stringValue, with: replaceValue)
            }

            if type.rawValue >= self.type.rawValue {
                if colored {
                    print ("\(color.rawValue) \(message) \(TerminalColor.foreground.rawValue)")
                } else {
                    print (" \(message) ")
                }
        }
    }
    
    /// A function that will indicate if a message with a specified type (`LoggerMessageType`)
    /// will be outputed in the log (i.e. will not be filtered out).
    ///
    /// -Parameter type: The type of message that one wants to know if it will be output in the log.
    ///
    /// - Returns: A Bool indicating whether, if true, or not a message of the specified type
    ///           (`LoggerMessageType`) would be output.
    public func isLogging(_ type: LoggerMessageType) -> Bool {
        return type.rawValue >= self.type.rawValue
    }
}
