import Foundation

import os
struct Logger {
    let osLog: OSLog

    init(category: String = #file) {
        osLog = OSLog(subsystem: "me.jackpine.biketag", category: category)
    }

    init(osLog: OSLog) {
        self.osLog = osLog
    }

    func trace(type: OSLogType = .debug, function: StaticString = #function, file: StaticString = #file, line: UInt = #line) {
        os_log("%@ %@:%lu", log: osLog, type: type, "\(function)", "\(file)", line)
    }

    func debug(_ message: @autoclosure () -> String) {
        os_log("%@", log: osLog, type: .debug, message())
    }

    func info(_ message: @autoclosure () -> String) {
        os_log("%@", log: osLog, type: .info, message())
    }

    func error(_ message: @autoclosure () -> String) {
        os_log("%@", log: osLog, type: .error, message())
    }

    func fault(_ message: @autoclosure () -> String) {
        os_log("%@", log: osLog, type: .fault, message())
    }

    // MARK: - Shared Singleton

    static let shared = Logger(osLog: .default)

    static func trace(type: OSLogType = .debug, function: StaticString = #function, file: StaticString = #file, line: UInt = #line) {
        shared.trace(type: type, function: function, file: file, line: line)
    }

    static func debug(_ message: @autoclosure () -> String) {
        shared.debug(message())
    }

    static func info(_ message: @autoclosure () -> String) {
        shared.info(message())
    }

    static func error(_ message: @autoclosure () -> String) {
        shared.error(message())
    }

    static func fault(_ message: @autoclosure () -> String) {
        shared.fault(message())
    }
}
