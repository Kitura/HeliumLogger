<p align="center">
    <a href="http://kitura.io/">
        <img src="https://raw.githubusercontent.com/IBM-Swift/Kitura/master/Sources/Kitura/resources/kitura-bird.svg?sanitize=true" height="100" alt="Kitura">
    </a>
</p>


<p align="center">
    <a href="https://ibm-swift.github.io/HeliumLogger/index.html">
    <img src="https://img.shields.io/badge/apidoc-HeliumLogger-1FBCE4.svg?style=flat" alt="APIDoc">
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

## Features

- Logs output to stdout by default. You can change the output stream, see example usage for [`HeliumStreamLogger.use(_:outputStream:)`](http://ibm-swift.github.io/HeliumLogger/Classes/HeliumStreamLogger.html#use).
- Different logging levels such as Warning, Verbose, and Error
  Enable/disable color output to terminal 

## Usage

#### Add dependencies

Add the `HeliumLogger` package to the dependencies within your application’s `Package.swift` file. Substitute `"x.x.x"` with the latest `HeliumLogger` [release](https://github.com/IBM-Swift/HeliumLogger/releases).

```swift
.package(url: "https://github.com/IBM-Swift/HeliumLogger.git", from: "x.x.x")
```

Add `HeliumLogger` to your target's dependencies:

```swift
.target(name: "example", dependencies: ["HeliumLogger"]),
```
#### Import packages

```swift
import HeliumLogger
import LoggerAPI
```

#### Initialize HeliumLogger

Initialize an instance of `HeliumLogger`. Set it as the logger used by `LoggerAPI`.

```swift
let logger = HeliumLogger()
Log.logger = logger
```

or, if you don't need to customize `HeliumLogger`:
```swift
HeliumLogger.use()
```

#### Logging levels

You can specify the level of output on initialization. You will see output of that level, and all levels below that.

The order is:
 1. entry (entering a function)
 2. exit (exiting a function)
 3. debug
 4. verbose (default)
 5. info
 6. &#32;warning
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

#### Adjust logging levels at runtime

Calling `HeliumLogger.use(LoggerMessageType)` will set the `LoggerAPI` to use this new HeliumLogger instance. If in a route you detect an error with your application, you could use this to dynamically increase the log level.

This new instance will not have any customization which you applied to other instances (see list item 7).

#### Logging messages

How to use HeliumLogger to log messages in your application:
```swift
Log.verbose("This is a verbose log message.")

Log.info("This is an informational log message.")

Log.warning("This is a warning.")

Log.error("This is an error.")

Log.debug("This is a debug message.")
```

#### Further customization

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

## API documentation

For more information visit our [API reference](http://ibm-swift.github.io/HeliumLogger/).

## Community

We love to talk server-side Swift, and Kitura. Join our [Slack](http://swift-at-ibm-slack.mybluemix.net/) to meet the team!

## License

This library is licensed under Apache 2.0. Full license text is available in [LICENSE](https://github.com/IBM-Swift/HeliumLogger/blob/master/LICENSE.txt).