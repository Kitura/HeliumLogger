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

// Test disabled on Swift 4 for now due to
// https://bugs.swift.org/browse/SR-5684

#if os(OSX) && !swift(>=3.2)
    import XCTest
    
    class VerifyLinuxTestCount: XCTestCase {
        func testVerifyLinuxTestCount() {
            var linuxCount: Int
            var darwinCount: Int
            
            // TestLogger
            linuxCount = TestLogger.allTests.count
            darwinCount = Int(TestLogger.defaultTestSuite().testCaseCount)
            XCTAssertEqual(linuxCount, darwinCount, "\(darwinCount - linuxCount) tests are missing from TestLogger.allTests")
            
            // TestStreamLogger
            linuxCount = TestStreamLogger.allTests.count
            darwinCount = Int(TestStreamLogger.defaultTestSuite().testCaseCount)
            XCTAssertEqual(linuxCount, darwinCount, "\(darwinCount - linuxCount) tests are missing from TestStreamLogger.allTests")
        }
    }
#endif
