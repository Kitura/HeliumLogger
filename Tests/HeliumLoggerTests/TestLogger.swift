/**
 * Copyright IBM Corporation 2016
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

@testable import HeliumLogger
@testable import LoggerAPI

#if os(Linux)
    import Glibc
#else
    import Darwin
#endif

class TestLogger : XCTestCase {
    
    static var allTests : [(String, (TestLogger) -> () throws -> Void)] {
        return [
                    ("testInfo", testInfo),
                    ("testWarning", testWarning),
                    ("testError", testError),
                    ("testLevel", testLevel),
                    ("testEntry", testEntry),
                    ("testExit", testExit),
                    ("testIsLogging", testIsLogging),
        ]
    }
    
    
    func testInfo() {
        HeliumLogger.use()
        Log.info("This is an info")
        
    }
    
    func testWarning() {
        HeliumLogger.use()
        Log.warning("This is a warning")
        
    }
    
    func testError() {
        HeliumLogger.use()
        Log.error("This is an error")
        
    }
    
    func testEntry() {
        HeliumLogger.use(.entry)
        Log.entry("This is an entry")
        
    }
    
    func testExit() {
        HeliumLogger.use(.exit)
        Log.exit("This is an exit")
        
    }
    
    func testLevel() {
        HeliumLogger.use(.warning)

        Log.verbose("This is a verbose")
        Log.info("This is an info")
        Log.debug("This is a debug")
        Log.warning("This is a warning")
        Log.error("This is an error")
    }

    func testIsLogging () {
        HeliumLogger.use()
        XCTAssertTrue(Log.isLogging(.verbose))
        XCTAssertTrue(Log.isLogging(.error))
        XCTAssertFalse(Log.isLogging(.debug))
        XCTAssertFalse(Log.isLogging(.entry))

        HeliumLogger.use(.entry)
        XCTAssertTrue(Log.isLogging(.error))
        XCTAssertTrue(Log.isLogging(.verbose))
        XCTAssertTrue(Log.isLogging(.entry))

        HeliumLogger.use(.error)
        XCTAssertTrue(Log.isLogging(.error))
        XCTAssertFalse(Log.isLogging(.warning))
        XCTAssertFalse(Log.isLogging(.entry))
    }
    
}
