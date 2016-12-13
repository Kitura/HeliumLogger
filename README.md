# HeliumLogger

[![Build Status](https://travis-ci.org/IBM-Swift/HeliumLogger.svg?branch=master)](https://travis-ci.org/IBM-Swift/HeliumLogger)
[![codecov](https://codecov.io/gh/IBM-Swift/HeliumLogger/branch/master/graph/badge.svg)](https://codecov.io/gh/IBM-Swift/HeliumLogger)

Provides a lightweight Swift Logging framework.

## Features:

- Different logging levels such as Warning, Verbose, and Error
- Color output to terminal 

## Usage:

```swift
import HeliumLogger
import LoggerAPI

Log.logger = HeliumLogger()

Log.verbose("This is a log message.")

```

