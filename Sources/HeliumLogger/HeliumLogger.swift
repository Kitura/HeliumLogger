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

    /// If true, use the full file path, not just the filename.
    public var fullFilePath: Bool = false

    /// If not nil, specifies the user specified logging format.
    /// For example: "[(%date)] [(%type)] [(%file):(%line) (%func)] (%msg)"
    public var format: String? {
        didSet {
            if let format = self.format {
                customFormatter = HeliumLogger.parseFormat(format)
            } else {
                customFormatter = nil
            }
        }
    }

    /// If not nil, specifies the date time format
    public var dateFormat: String? {
        didSet {
            dateFormatter = HeliumLogger.getDateFormatter(format: dateFormat, timeZone: timeZone)
        }
    }

    /// If not nil, specifies the timezone used in the date time format
    public var timeZone: TimeZone? {
        didSet {
            dateFormatter = HeliumLogger.getDateFormatter(format: dateFormat, timeZone: timeZone)
        }
    }

    /// default date format - ISO 8601
    public static let defaultDateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"

    fileprivate var dateFormatter: DateFormatter = HeliumLogger.getDateFormatter()

    static func getDateFormatter(format: String? = nil, timeZone: TimeZone? = nil) -> DateFormatter {
        let formatter = DateFormatter()

        if let dateFormat = format {
            formatter.dateFormat = dateFormat
        } else {
            formatter.dateFormat = defaultDateFormat
        }

        if let timeZone = timeZone {
            formatter.timeZone = timeZone
        }

        return formatter
    }

    #if os(Linux)
    typealias RegularExpressionType = RegularExpression
    #else
    typealias RegularExpressionType = NSRegularExpression
    #endif

    private static var tokenRegex: RegularExpressionType? = {
        do {
            return try RegularExpressionType(pattern: "\\(%\\w+\\)", options: [])
        } catch {
            return nil
        }
    }()

    fileprivate var customFormatter: [LogSegment]?

    enum LogSegment {
        case token(HeliumLoggerFormatValues)
        case literal(String)
    }

    static func parseFormat(_ format: String) -> [LogSegment] {
        var logSegments = [LogSegment]()

        let nsFormat = NSString(string: format)
        let matches = tokenRegex!.matches(in: format, options: [], range: NSMakeRange(0, nsFormat.length))
        var loc = 0
        for (index, match) in matches.enumerated() {
            // possible literal segment before token match
            if loc < match.range.location {
                let segment = nsFormat.substring(with: NSMakeRange(loc, match.range.location - loc))
                if !segment.isEmpty {
                    logSegments.append(LogSegment.literal(segment))
                }
            }

            // token regex match, may not be a valid formatValue
            let segment = nsFormat.substring(with: NSMakeRange(match.range.location, match.range.length))
            loc = match.range.location + match.range.length
            if let formatValue = HeliumLoggerFormatValues(rawValue: segment) {
                logSegments.append(LogSegment.token(formatValue))
            } else {
                logSegments.append(LogSegment.literal(segment))
            }

            // possible literal segment after LAST token match
            let nextIndex = index + 1
            if nextIndex >= matches.count {
                let segment = nsFormat.substring(from: loc)
                if !segment.isEmpty {
                    logSegments.append(LogSegment.literal(segment))
                }
            }
        }

        return logSegments
    }

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

        guard type.rawValue >= self.type.rawValue else {
            return
        }

        let date = dateFormatter.string(from: Date())
        let message: String

        if let formatter = customFormatter {
            var line = ""
            for logSegment in formatter {
                let value: String

                switch logSegment {
                case .literal(let literal):
                    value = literal
                case .token(let token):
                    switch token {
                    case .date:
                        value = date
                    case .logType:
                        value = type.description
                    case .file:
                        value = getFile(fileName)
                    case .line:
                        value = "\(lineNum)"
                    case .function:
                        value = functionName
                    case .message:
                        value = msg
                    }
                }

                line.append(value)
            }
            message = line
        } else if details {
            message = "[\(date)] [\(type)] [\(getFile(fileName)):\(lineNum) \(functionName)] \(msg)"
        } else {
            message = "[\(date)] [\(type)] \(msg)"
        }

        if colored {
            let color : TerminalColor
            switch type {
            case .warning:
                color = .yellow
            case .error:
                color = .red
            default:
                color = .foreground
            }

            print(color.rawValue + message + TerminalColor.foreground.rawValue)
        } else {
            print(message)
        }
    }

    func getFile(_ path: String) -> String {
        if self.fullFilePath {
            return path
        }
        guard let range = path.range(of: "/", options: .backwards) else {
            return path
        }
        return path.substring(from: range.upperBound)
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
