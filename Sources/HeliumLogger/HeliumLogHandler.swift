/**
 * Copyright IBM Corporation 2017
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

import Foundation
import Logging

extension HeliumLogger {
    
    /// Creates a `HeliumLogHandler` instance for use with the SwiftLog logging system.
    ///
    ///### Usage Example: ###
    /// This may be used to bootstrap the SwiftLog logging system with a
    /// `HeliumLogger` instance. The `HeliumLogger` instance will
    /// be used as the logging backend for SwiftLog.
    ///```swift
    ///let heliumLogger = HeliumLogger()
    ///LoggingSystem.bootstrap(heliumLogger.makeLogHandler)
    ///```
    /// - Parameter label: The label to use for a SwiftLog `Logger`.
    public func makeLogHandler(label: String) -> HeliumLogHandler {
        return HeliumLogHandler(label: label, logger: self)
    }
    
    private static let defaultLogger = HeliumLogger()
    
    /// Creates a `HeliumLogHandler` instance for use with the SwiftLog logging system.
    ///
    ///### Usage Example: ###
    /// This may be used to bootstrap the SwiftLog logging system with a default
    /// `HeliumLogger` instance. The default `HeliumLogger` instance will
    /// be used as the logging backend for SwiftLog.
    ///```swift
    ///LoggingSystem.bootstrap(HeliumLogger.makeLogHandler)
    ///```
    /// - Parameter label: The label to use for a SwiftLog `Logger`.
    public static func makeLogHandler(label: String) -> HeliumLogHandler {
        return HeliumLogHandler(label: label, logger: defaultLogger)
    }
}

/// A lightweight implementation of SwiftLog's `LogHandler` protocol.
public struct HeliumLogHandler: LogHandler {
    public var logger: HeliumLogger
    
    public let label: String
    
    public var logLevel: Logger.Level = .info
    
    private var prettyMetadata: String?
    
    public var metadata = Logger.Metadata() {
        didSet {
            prettyMetadata = prettify(metadata)
        }
    }
    
    public subscript(metadataKey metadataKey: String) -> Logger.Metadata.Value? {
        get {
            return metadata[metadataKey]
        }
        set {
            metadata[metadataKey] = newValue
        }
    }
    
    init(label: String, logger: HeliumLogger) {
        self.label = label
        self.logger = logger
    }
    
    public func log(level: Logger.Level, message: Logger.Message, metadata: Logger.Metadata?, file: String, function: String, line: UInt) {
        let prettyMetadata = metadata?.isEmpty ?? true
            ? self.prettyMetadata
            : self.prettify(self.metadata.merging(metadata!, uniquingKeysWith: { _, new in new }))
        
        let output = logger.formatEntry(type: "\(level)", label: label, msg: "\(message)", metadata: prettyMetadata, color: level.color,
                                        functionName: function, lineNum: Int(line), fileName: file)
        
        logger.doPrint(output)
    }
    
    private func prettify(_ metadata: Logger.Metadata) -> String? {
        return !metadata.isEmpty ? metadata.map { "\($0)=\($1)" }.joined(separator: " ") : nil
    }
}

extension Logger.Level {
    var color: TerminalColor {
        switch self {
        case .warning:
            return .yellow
        case .error:
            return .red
        default:
            return .foreground
        }
    }
}
