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
                    ("testParseFormatSingleLiteral", testParseFormatSingleLiteral),
                    ("testParseFormatEmptyLiteral", testParseFormatEmptyLiteral),
                    ("testParseFormatSingleToken", testParseFormatSingleToken),
                    ("testParseFormatLiteralLooksLikeToken", testParseFormatLiteralLooksLikeToken),
                    ("testParseFormatUnicodeLiteral", testParseFormatUnicodeLiteral),
                    ("testParseFormatStartingWithLiteral", testParseFormatStartingWithLiteral),
                    ("testParseFormatEndingWithLiteral", testParseFormatEndingWithLiteral),
                    ("testParseFormatWithNoLiterals", testParseFormatWithNoLiterals),
                    ("testParseFormatWithRepeatedTokens", testParseFormatWithRepeatedTokens),
                    ("testLogSegmentEquality", testLogSegmentEquality),
                    ("testGetFile", testGetFile),
                    ("testFormatDates", testFormatDates),
                    ("testFormatEntries", testFormatEntries)
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

        HeliumLogger(.info).log(.debug, msg: "THIS SHOULD NOT BE RENDERED", functionName: #function, lineNum: #line, fileName: #file)
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

    func testParseFormatSingleLiteral() {
        let logSegments: [HeliumLogger.LogSegment] = [
            .literal("literal")
        ]
        testParseFormat(logSegments)
    }

    func testParseFormatEmptyLiteral() {
        let logSegments: [HeliumLogger.LogSegment] = [
            .literal("")
        ]
        testParseFormat(logSegments)
    }

    func testParseFormatSingleToken() {
        let logSegments: [HeliumLogger.LogSegment] = [
            .token(.message)
        ]
        testParseFormat(logSegments)
    }
    
    func testParseFormatLiteralLooksLikeToken() {
        let logSegments: [HeliumLogger.LogSegment] = [
            .literal("(%noSoupForYou)")
        ]
        testParseFormat(logSegments)
    }

    func testParseFormatUnicodeLiteral() {
        let logSegments: [HeliumLogger.LogSegment] = [
            .literal("(%\u{1f3c8})(%\u{1f37a})"),
            .token(.message),
            .literal("\u{1f37a}\u{1f3c8}"),
        ]
        testParseFormat(logSegments)
    }

    func testParseFormatStartingWithLiteral() {
        let logSegments: [HeliumLogger.LogSegment] = [
            .literal("["),
            .token(.date),
            .literal("] "),
            .token(.message)
        ]
        testParseFormat(logSegments)
    }

    func testParseFormatEndingWithLiteral() {
        let logSegments: [HeliumLogger.LogSegment] = [
            .token(.date),
            .literal(" "),
            .token(.message),
            .literal("<EOF>")
        ]
        testParseFormat(logSegments)
    }

    func testParseFormatWithNoLiterals() {
        let logSegments: [HeliumLogger.LogSegment] = [
            .token(.date),
            .token(.logType),
            .token(.file),
            .token(.line),
            .token(.function),
            .token(.message)
        ]
        testParseFormat(logSegments)
    }

    func testParseFormatWithRepeatedTokens() {
        let logSegments: [HeliumLogger.LogSegment] = [
            .token(.date),
            .token(.file),
            .token(.date),
            .token(.file),
            .token(.message),
            .token(.message)
        ]
        testParseFormat(logSegments)
    }

    func testParseFormat(_ segments: [HeliumLogger.LogSegment]) {
        var format = ""
        for segment in segments {
            switch segment {
            case .literal(let literal):
                format.append(literal)
            case .token(let token):
                format.append(token.rawValue)
            }
        }

        let parsedSegments = HeliumLogger.parseFormat(format)
        XCTAssertEqual(segments, parsedSegments)
    }

    func testLogSegmentEquality() {
        let dateEnum = HeliumLoggerFormatValues.date
        let literal1 = HeliumLogger.LogSegment.literal(dateEnum.rawValue)
        let literal2 = HeliumLogger.LogSegment.literal("(%date)")
        let token1 = HeliumLogger.LogSegment.token(dateEnum)
        let token2 = HeliumLogger.LogSegment.token(HeliumLoggerFormatValues(rawValue: dateEnum.rawValue)!)

        XCTAssertEqual(literal1, literal2)
        XCTAssertEqual(token1, token2)
        XCTAssertNotEqual(literal1, token1)
    }

    func testGetFile() {
        let filePath = #file
        let url = URL(fileURLWithPath: filePath)
        let logger = HeliumLogger()

        logger.fullFilePath = true
        XCTAssertEqual(filePath, logger.getFile(filePath))

        logger.fullFilePath = false
        XCTAssertEqual(url.lastPathComponent, logger.getFile(filePath))

        let filePathWithoutSlashes = filePath.replacingOccurrences(of: "/", with: "_")
        XCTAssertEqual(filePathWithoutSlashes, logger.getFile(filePathWithoutSlashes))
    }

    func testFormatDates() {
        let date = Date()
        let dateFormat = "MM/dd/yyyy'test'HH:mm:ss.SSSSSSSSS"
        let timeZone = TimeZone(secondsFromGMT: TimeZone.current.secondsFromGMT() + 3600)

        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat

        let logger = HeliumLogger()
        XCTAssertNotEqual(formatter.string(from: date), logger.formatDate(date)) // different formats

        logger.dateFormat = dateFormat
        formatter.timeZone = timeZone
        XCTAssertNotEqual(formatter.string(from: date), logger.formatDate(date)) // different time zones

        logger.timeZone = timeZone
        XCTAssertEqual(formatter.string(from: date), logger.formatDate(date)) // now everything should be the same
    }

    func testFormatEntries() {
        let logger = HeliumLogger()
        logger.dateFormat = "" // short circuit date so we can compare entries generated at different times

        let type: LoggerMessageType = .error
        let msg = "test message"
        let file = #file
        let line = #line
        let funct = #function

        logger.fullFilePath = false
        logger.colored = false

        logger.details = false
        let shortFormat = logger.formatEntry(type: type, msg: msg, functionName: funct, lineNum: line, fileName: file)
        logger.details = true
        let longFormat = logger.formatEntry(type: type, msg: msg, functionName: funct, lineNum: line, fileName: file)

        let format   = "!!!TEST!!! [(%file):(%line) (%msg) (%func)](%date)"
        let expected = "!!!TEST!!! [\(file):\(line) \(msg) \(funct)]"
        logger.format = format

        // test custom format with fullFilePath = false
        XCTAssertNotEqual(expected, logger.formatEntry(type: type, msg: msg, functionName: funct, lineNum: line, fileName: file))

        logger.fullFilePath = true
        // test custom format with fullFilePath = true
        XCTAssertEqual(expected, logger.formatEntry(type: type, msg: msg, functionName: funct, lineNum: line, fileName: file))

        // test custom formats are the same when not colorized for different log types
        XCTAssertEqual(expected, logger.formatEntry(type: .warning, msg: msg, functionName: funct, lineNum: line, fileName: file))
        XCTAssertEqual(expected, logger.formatEntry(type: .info, msg: msg, functionName: funct, lineNum: line, fileName: file))
        XCTAssertEqual(expected, logger.formatEntry(type: .error, msg: msg, functionName: funct, lineNum: line, fileName: file))

        logger.format = format + "(%type)"
        logger.colored = true
        let colorizedExpected = "\(TerminalColor.red.rawValue)\(expected)\(type)\(TerminalColor.foreground.rawValue)"

        // test custom formats are NOT the same when not colorized for different log types
        XCTAssertNotEqual(colorizedExpected, logger.formatEntry(type: .warning, msg: msg, functionName: funct, lineNum: line, fileName: file))
        XCTAssertNotEqual(colorizedExpected, logger.formatEntry(type: .info, msg: msg, functionName: funct, lineNum: line, fileName: file))
        XCTAssertEqual(colorizedExpected, logger.formatEntry(type: type, msg: msg, functionName: funct, lineNum: line, fileName: file))

        // test formatted entries are NOT the same as defaults when logger.format is set
        XCTAssertNotEqual(shortFormat, logger.formatEntry(type: type, msg: msg, functionName: funct, lineNum: line, fileName: file))
        XCTAssertNotEqual(longFormat, logger.formatEntry(type: type, msg: msg, functionName: funct, lineNum: line, fileName: file))

        logger.format = nil
        logger.fullFilePath = false
        logger.colored = false

        // test formatted entries are the same as defaults when logger.format is nil
        logger.details = false
        XCTAssertEqual(shortFormat, logger.formatEntry(type: type, msg: msg, functionName: funct, lineNum: line, fileName: file))
        logger.details = true
        XCTAssertEqual(longFormat, logger.formatEntry(type: type, msg: msg, functionName: funct, lineNum: line, fileName: file))
    }
}
