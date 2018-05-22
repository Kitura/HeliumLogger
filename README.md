<p align="center">
    <a href="http://kitura.io/">
        <img src="https://raw.githubusercontent.com/IBM-Swift/Kitura/master/Sources/Kitura/resources/kitura-bird.svg?sanitize=true" height="100" alt="Kitura">
    </a>
</p>


<p align="center">
    <a href="https://www.kitura.io/en/api/">
    <img src="https://img.shields.io/badge/docs-kitura.io-1FBCE4.svg" alt="Docs">
    </a>
    <a href="https://travis-ci.org/IBM-Swift/HeliumLogger">
    <img src="https://travis-ci.org/IBM-Swift/HeliumLogger.svg?branch=master" alt="Build Status - Master">
    </a>
    <img src="https://codecov.io/gh/IBM-Swift/HeliumLogger/branch/master/graph/badge.svg" alt="codecov">
    <img src="https://img.shields.io/badge/os-macOS-green.svg?style=flat" alt="macOS">
    <img src="https://img.shields.io/badge/os-linux-green.svg?style=flat" alt="Linux">
    <img src="https://img.shields.io/badge/license-Apache2-blue.svg?style=flat" alt="Apache 2">
    <a href="http://swift-at-ibm-slack.mybluemix.net/">
    <img src="http://swift-at-ibm-slack.mybluemix.net/badge.svg" alt="Slack Status">
    </a>
</p>

# HeliumLogger

Provides a lightweight Swift logging framework which supports logging to standard output.

## Features:

- Different logging levels such as Warning, Verbose, and Error
- Color output to terminal

## Usage:

1. **Add the HeliumLogger package to the dependencies within your application’s `Package.swift` file.**

```swift
// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "example",
    dependencies: [
      .package(url: "https://github.com/IBM-Swift/HeliumLogger.git", .upToNextMinor(from: "x.x.x")
      ],
    targets: [
      .target(name: "example", dependencies: [ "HeliumLogger"])
    ]
)
```
Substitute `"x.x.x"` with the latest `HeliumLogger` [release](https://github.com/IBM-Swift/HeliumLogger/releases).

2. **Import `HeliumLogger` and `LoggerAPI`.**

  ```swift
  import HeliumLogger
  import LoggerAPI
  ```

3. **Initialize an instance of `HeliumLogger`. Set it as the logger used by `LoggerAPI`.**
  ```swift
  let logger = HeliumLogger()
  Log.logger = logger
  ```

  or, if you don't need to customize `HeliumLogger`:
  ```swift
  HeliumLogger.use()
  ```

4. **You can specify the level of output on initialization. You will see output of that level, and all levels below that.**

The order is:
   1. entry (entering a function)
   2. exit (exiting a function)
   3. debug
   4. verbose (default)
   5. info
   6. warning
   7. error

For example, this logger will show messages of type `verbose`, `info`, `warning`, and `error`:
```swift
  let logger = HeliumLogger(.verbose)
  Log.logger = logger
```

In this example, the logger will only show messages of type `warning` and `error`:
```swift
  HeliumLogger.use(.warning)
```

5. **Adjust logging levels at runtime**

  Calling `HeliumLogger.use(LoggerMessageType)` will set the `LoggerAPI` to use this new HeliumLogger instance. If in a route you detect an error with your application, you could use this to dynamically increase the log level.

  This new instance will not have any customization which you applied to other instances (see list item 7).

6. **Logging messages**

How to use HeliumLogger to log messages in your application:
  ```swift
  Log.verbose("This is a verbose log message.")

  Log.info("This is an informational log message.")

  Log.warning("This is a warning.")

  Log.error("This is an error.")

  Log.debug("This is a debug message.")
  ```

7. **Further customization**
  ```swift
  /// Whether, if true, or not the logger output should be colorized.
  public var colored: Bool = false

  /// If true, use the detailed format when a user logging format wasn't specified.
  public var details: Bool = true

  /// If true, use the full file path, not just the filename.
  public var fullFilePath: Bool = false

  /// If not nil, specifies the user specified logging format.
  /// For example: "[(%date)] [(%type)] [(%file):(%line) (%func)] (%msg)"
  public var format: String?

  /// If not nil, specifies the format used when adding the date and the time to the logged messages.
  public var dateFormat: String?

  /// If not nil, specifies the timezone used in the date time format.
  public var timeZone: TimeZone?
  ```

## Community

We love to talk server-side Swift, and Kitura. Join our [Slack](http://swift-at-ibm-slack.mybluemix.net/) to meet the team!

## License

This library is licensed under Apache 2.0. Full license text is available in [LICENSE](https://github.com/IBM-Swift/HeliumLogger/blob/master/LICENSE.txt).
