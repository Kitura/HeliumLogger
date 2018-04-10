

<p align="center">
    <a href="http://kitura.io/">
        <img src="https://raw.githubusercontent.com/IBM-Swift/Kitura/master/Sources/Kitura/resources/kitura-bird.svg?sanitize=true" height="100" alt="Kitura">
    </a>
</p>


<p align="center">
    <a href="http://www.kitura.io/">
    <img src="https://img.shields.io/badge/docs-kitura.io-1FBCE4.svg" alt="Docs">
    </a>
    <a href="https://travis-ci.org/IBM-Swift/HeliumLogger">
    <img src="https://travis-ci.org/IBM-Swift/HeliumLogger.svg?branch=master" alt="Build Status - Master">
    </a>
    <img src="https://img.shields.io/badge/os-macOS-green.svg?style=flat" alt="macOS">
    <img src="https://img.shields.io/badge/os-linux-green.svg?style=flat" alt="Linux">
    <img src="https://img.shields.io/badge/license-Apache2-blue.svg?style=flat" alt="Apache 2">
    <img src="https://codecov.io/gh/IBM-Swift/HeliumLogger/branch/master/graph/badge.svg" alt="codecov">
    <a href="http://swift-at-ibm-slack.mybluemix.net/">
    <img src="http://swift-at-ibm-slack.mybluemix.net/badge.svg" alt="Slack Status">
    </a>
</p>


# HeliumLogger

Provides a lightweight Swift Logging framework.

## Features:

- Different logging levels such as Warning, Verbose, and Error
- Color output to terminal 

## Usage:

1. **Import `HeliumLogger` and `LoggerAPI`:**

  ```swift
  import HeliumLogger
  import LoggerAPI
  ```

2. **Initialize an instance of `HeliumLogger`. Set it as the logger used by `LoggerAPI`.**
  ```swift
  let logger = HeliumLogger()
  Log.logger = logger
  ```
  
  or if you don't need to customize `HeliumLogger`:
  ```swift
  HeliumLogger.use()
  ```

3. **You can specify the level of output on initialization. You will see output of that level, and all levels below that. The order goes:**

   1. entry (entering a function)
   2. exit (exiting a function)
   3. debug
   4. verbose (default)
   5. info
   6. warning
   7. error

  So for example,
  ```swift
  let logger = HeliumLogger(.verbose)
  Log.logger = logger
  ```
  Will show messages of `verbose`, `info`, `warning`, and `error` type.

  While,
  ```swift
  HeliumLogger.use(.warning)
  ```
  will only show messages of `warning` and `error` type.

4. **Adjust logging levels at runtime:**
  
  Calling `HeliumLogger.use(LoggerMessageType)` will set the LoggerAPI to use this new HeliumLogger instance. This allows you to, for example, if in a route you detect an error with your application, dynamically increase the log level.
  
  This new instance will not have any customization you did to other instances. (see list item 6).

5. **Logging messages:**
  ```swift
  Log.verbose("This is a verbose log message.")

  Log.info("This is an informational log message.")

  Log.warning("This is a warning.")

  Log.error("This is an error.")

  Log.debug("This is a debug message.")
  ```

6. **Further customization:**
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

  /// If not nil, specifies the format used when adding the date and the time to the logged messages
  public var dateFormat: String?

  /// If not nil, specifies the timezone used in the date time format
  public var timeZone: TimeZone?
  ```
