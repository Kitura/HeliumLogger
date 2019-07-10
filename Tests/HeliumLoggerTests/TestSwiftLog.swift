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

import XCTest
import HeliumLogger
import Logging

let isLoggingConfigured: Bool = {
    let heliumLogger = HeliumLogger()
    LoggingSystem.bootstrap(heliumLogger.makeLogHandler)
    return true
}()

class TestSwiftLog: XCTestCase {
    
    static var allTests : [(String, (TestSwiftLog) -> () throws -> Void)] {
        return [
            ("testTrace", testTrace),
            ("testDebug", testDebug),
            ("testInfo", testInfo),
            ("testNotice", testNotice),
            ("testWarning", testWarning),
            ("testError", testError),
            ("testLevel", testLevel),
            ("testCritical", testCritical),
            ("testValueSemantics", testValueSemantics)
        ]
    }

    override func setUp() {
        XCTAssert(isLoggingConfigured)
    }
    
    func testTrace() {
        var logger = Logger(label: "TraceLogger")
        logger.logLevel = .trace
        logger.trace("This is a trace")
    }
    
    func testDebug() {
        var logger = Logger(label: "DebugLogger")
        logger.logLevel = .debug
        logger.debug("This is a debug")
    }
    
    func testInfo() {
        let logger = Logger(label: "InfoLogger")
        logger.info("This is an info")
    }
    
    func testNotice() {
        let logger = Logger(label: "NoticeLogger")
        logger.notice("This is a notice")
    }
    
    func testWarning() {
        let logger = Logger(label: "WarningLogger")
        logger.warning("This is a warning")
    }
    
    func testError() {
        let logger = Logger(label: "ErrorLogger")
        logger.error("This is an error")
    }
    
    func testCritical() {
        let logger = Logger(label: "CriticalLogger")
        logger.critical("This is a critical")
    }
    
    func testLevel() {
        var logger = Logger(label: "WarningLogger")
        logger.logLevel = .warning
        logger.trace("THIS SHOULD NOT BE RENDERED")
        logger.debug("THIS SHOULD NOT BE RENDERED")
        logger.info("THIS SHOULD NOT BE RENDERED")
        logger.notice("THIS SHOULD NOT BE RENDERED")
        logger.warning("This is a warning")
        logger.error("This is an error")
        logger.critical("This is a critical")
    }
    
    func testValueSemantics() {
        var logger1 = Logger(label: "first logger")
        logger1.logLevel = .debug
        logger1[metadataKey: "only-on"] = "first"
        
        var logger2 = logger1
        logger2.logLevel = .error
        logger2[metadataKey: "only-on"] = "second"
        
        logger1.debug("This is a debug")
        logger2.debug("THIS SHOULD NOT BE RENDERED")
        logger2.error("This is an error")
        
        XCTAssertEqual(.debug, logger1.logLevel)
        XCTAssertEqual(.error, logger2.logLevel)
        XCTAssertEqual("first", logger1[metadataKey: "only-on"])
        XCTAssertEqual("second", logger2[metadataKey: "only-on"])
    }

}
