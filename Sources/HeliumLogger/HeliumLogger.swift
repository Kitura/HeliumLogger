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
    case white = "\u{001B}[0;37m" // white
    case red = "\u{001B}[0;31m" // red
    case yellow = "\u{001B}[0;33m" // yellow
    case foreground = "\u{001B}[0;39m" // default foreground color
    case background = "\u{001B}[0;49m" // default background color
}

public enum HeliumLoggerFormatValues: String {
    case message = "(%msg)"
    case function = "(%func)"
    case line = "(%line)"
    case file = "(%file)"
    case logType = "(%type)"
    case date = "(%date)"

    static let All: [HeliumLoggerFormatValues] = [
        .message, .function, .line, .file, .logType, .date
    ]
}

public class HeliumLogger {

    ///
    /// Singleton instance of the logger
    // static public var logger: Logger?

    public var colored: Bool = false

    public var details: Bool = true

    public var format: String?
    public var dateFormat: String?

    private static let detailedFormat = "(%type): (%func) (%file) line (%line) - (%msg)"
    private static let defaultFormat = "(%type): (%msg)"
    private static let defaultDateFormat = "dd.MM.YYYY, HH:mm:ss"

    public init() {}

    public static func use() {
        Log.logger = HeliumLogger()
        setbuf(stdout, nil)
    }
    
    private var type: LoggerMessageType = .verbose
    public init (_ type: LoggerMessageType) {
        self.type = type
    }
}

extension HeliumLogger : Logger {

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
}
