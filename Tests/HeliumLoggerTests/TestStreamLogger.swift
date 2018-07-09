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
import XCTest

import HeliumLogger
import LoggerAPI

#if os(Linux)
    import Glibc
#else
    import Darwin
#endif

class TestStreamLogger : XCTestCase {

    static var allTests : [(String, (TestStreamLogger) -> () throws -> Void)] {
        return [
            ("testInfo", testInfo),
            ("testWarning", testWarning),
            ("testError", testError),
            ("testLevel", testLevel),
            ("testEntry", testEntry),
            ("testExit", testExit),
            ("testIsLogging", testIsLogging),
            ("testUse", testUse)
        ]
    }

    class MockTextOutputStream: TextOutputStream {
        var stream: String = ""
        func write(_ string: String) {
            stream += string
        }
    }

    #if os(Linux) && !swift(>=3.1)
    typealias NSRegularExpression = RegularExpression
    #endif

    struct LogMessage {
        let typeString: String
        let messageString: String

        init(typeString: String = "", messageString: String = "") {
            self.typeString = typeString
            self.messageString = messageString
        }
    }

    private func getLogMessage(_ logString: String) -> LogMessage {
        do {
            let regularExpression = try NSRegularExpression(pattern: "\\[.*\\]\\s\\[(.*)\\]\\s\\[.*\\]\\s(.*)", options: [])
            #if swift(>=3.2)
            let matches = regularExpression.matches(in: logString, options: [],
                                                    range: NSRange(location:0, length: logString.count))
            #else
            let matches = regularExpression.matches(in: logString, options: [],
                                                    range: NSRange(location:0, length: logString.characters.count))
            #endif

            guard let messageMatch = matches.first else {
                return LogMessage()
            }
            #if os(Linux) || swift(>=4.0)
                let typeStringRange = messageMatch.range(at: 1)
                let typeString = NSString(string: logString).substring(with: typeStringRange)
            #else
                let typeStringRange = messageMatch.rangeAt(1)
                let typeString = (logString as NSString).substring(with: typeStringRange)
            #endif

            #if os(Linux) || swift(>=4.0)
                let messageStringRange = messageMatch.range(at: 2)
                let messageString = NSString(string: logString).substring(with: messageStringRange)
            #else
                let messageStringRange = messageMatch.rangeAt(2)
                let messageString = (logString as NSString).substring(with: messageStringRange)
            #endif

            return LogMessage(typeString: typeString, messageString: messageString)
        } catch {
            XCTFail("Unable to process log string: \(logString)")
        }
        return LogMessage()
    }

    private func testLog(message: String, type: String, shouldBeLogged: Bool = true,
                         logLevel: LoggerMessageType = .verbose, doLog: () -> Void) {
        let outputStream = MockTextOutputStream()
        HeliumStreamLogger.use(logLevel, outputStream: outputStream)
        doLog()
        let parsedLogMessage = getLogMessage(outputStream.stream)
        if shouldBeLogged {
            XCTAssertEqual(parsedLogMessage.messageString, message)
            XCTAssertEqual(parsedLogMessage.typeString, type)
        } else {
            XCTAssertEqual(parsedLogMessage.messageString, "")
            XCTAssertEqual(parsedLogMessage.typeString, "")
        }
    }

    func testInfo() {
        let logMessage = "This is an info"
        testLog(message: logMessage, type: "INFO") {
            Log.info(logMessage)
        }
    }

    func testWarning() {
        let logMessage = "This is a warning"
        testLog(message: logMessage, type: "WARNING") {
            Log.warning(logMessage)
        }
    }

    func testError() {
        let logMessage = "This is an error"
        testLog(message: logMessage, type: "ERROR") {
            Log.error(logMessage)
        }
    }

    func testEntry() {
        let logMessage = "This is an entry"
        testLog(message: logMessage, type: "ENTRY", logLevel: .entry) {
            Log.entry(logMessage)
        }
    }

    func testExit() {
        let logMessage = "This is an exit"
        testLog(message: logMessage, type: "EXIT", logLevel: .exit) {
            Log.exit(logMessage)
        }
    }

    func testLevel() {
        let logMessage = "Log Message"

        testLog(message: logMessage, type: "VERBOSE", shouldBeLogged: false, logLevel: .warning) {
            Log.verbose(logMessage)
        }

        testLog(message: logMessage, type: "INFO", shouldBeLogged: false, logLevel: .warning) {
            Log.info(logMessage)
        }

        testLog(message: logMessage, type: "DEBUG", shouldBeLogged: false, logLevel: .warning) {
            Log.debug(logMessage)
        }

        testLog(message: logMessage, type: "WARNING", shouldBeLogged: true, logLevel: .warning) {
            Log.warning(logMessage)
        }

        testLog(message: logMessage, type: "ERROR", shouldBeLogged: true, logLevel: .warning) {
            Log.error(logMessage)
        }

        testLog(message: logMessage, type: "DEBUG", shouldBeLogged: false, logLevel: .info) {
            Log.debug(logMessage)
        }
    }

    func testIsLogging () {
        HeliumStreamLogger.use(outputStream: MockTextOutputStream())
        XCTAssertTrue(Log.isLogging(.verbose))
        XCTAssertTrue(Log.isLogging(.error))
        XCTAssertFalse(Log.isLogging(.debug))
        XCTAssertFalse(Log.isLogging(.entry))

        HeliumStreamLogger.use(.entry, outputStream: MockTextOutputStream())
        XCTAssertTrue(Log.isLogging(.error))
        XCTAssertTrue(Log.isLogging(.verbose))
        XCTAssertTrue(Log.isLogging(.entry))

        HeliumStreamLogger.use(.error, outputStream: MockTextOutputStream())
        XCTAssertTrue(Log.isLogging(.error))
        XCTAssertFalse(Log.isLogging(.warning))
        XCTAssertFalse(Log.isLogging(.entry))
    }

    func verifyNoLoggingEnabled() {
        XCTAssertFalse(Log.isLogging(.verbose))
        XCTAssertFalse(Log.isLogging(.error))
        XCTAssertFalse(Log.isLogging(.warning))
        XCTAssertFalse(Log.isLogging(.debug))
        XCTAssertFalse(Log.isLogging(.entry))
        XCTAssertFalse(Log.isLogging(.exit))
    }

    func testUse() {
        Log.logger = nil

        verifyNoLoggingEnabled()

        HeliumStreamLogger<MockTextOutputStream>.use(.entry)

        verifyNoLoggingEnabled()
    }
}
