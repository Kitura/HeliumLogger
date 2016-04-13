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
    case Message = "(%m)"
    case Function = "(%func)"
    case Line = "(%l)"
    case File = "(%file)"
    case LogType = "(%t)"

    static let All: [HeliumLoggerFormatValues] = [.Message, .Function, .Line, .File, .LogType]
}

public class HeliumLogger {

    ///
    /// Singleton instance of the logger
    // static public var logger: Logger?

    public var colored: Bool = true

    public var details: Bool = true

    public var format: String?

    private static let detailedFormat = "(%t): (%func) (%file) line (%l) - (%m)"
    private static let defaultFormat = "(%t): (%m)"

    public init () {}



}

extension HeliumLogger : Logger {

    public func log(type: LoggerMessageType, msg: String,
        functionName: String, lineNum: Int, fileName: String ) {

            var color : TerminalColor = .Foreground

            if type == .Warning {
                color = .Yellow
            } else if type == .Error {
                color = .Red
            } else {
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
                          replaceValue = fileName
                }

                message = message.replacingOccurrences(of: stringValue, with: replaceValue)
            }

            if colored {
                print ("\(color.rawValue) \(message) \(TerminalColor.Foreground.rawValue)")
            } else {
                print (" \(message) ")
            }

    }
}
