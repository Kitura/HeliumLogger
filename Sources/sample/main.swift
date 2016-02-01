import HeliumLogger

Log.logger = BasicLogger()

Log.verbose("Hello World")

Log.warning("This is a warning")

Log.error("This is an error")

Log.logger = nil

Log.verbose("Hello World")

Log.warning("This is a warning")

Log.error("This is an error")


