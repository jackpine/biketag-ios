import Foundation

import os
struct Logger {
    let osLog: OSLog

    init(category: String = #file) {
        osLog = OSLog(subsystem: "me.jackpine.biketag", category: category)
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

    // `.default` logger doesn't show signposts in Instruments.
    static let shared = Logger(category: "Default")

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

// Benching
extension Logger {
    func startBench(_ name: StaticString) -> BenchEvent {
        if #available(iOS 12.0, *) {
            let signpostId = OSSignpostID(log: osLog)
            os_signpost(.begin, log: osLog, name: name, signpostID: signpostId)
            return BenchEvent(name: name, .signpostId(signpostId))
        } else {
            return BenchEvent.legacyTimed(name: name)
        }
    }

    func completeBench(_ benchEvent: BenchEvent) {
        switch benchEvent.body {
        case let .signpostId(signpostId):
            if #available(iOS 12.0, *) {
                os_signpost(.end, log: osLog, name: benchEvent.name, signpostID: signpostId)
            } else {
                assertionFailure("should never have a signpostId before iOS 12")
            }
        case let .startTime(startTime):
            let finishTime = CACurrentMediaTime()
            let duration = finishTime - startTime
            let formattedDuration = String(format: "%.2fms", duration * 1000)
            debug("\(benchEvent.name) duration: \(formattedDuration)")
        }
    }

    static func startBench(_ name: StaticString) -> BenchEvent {
        return shared.startBench(name)
    }

    static func completeBench(_ benchEvent: BenchEvent) {
        shared.completeBench(benchEvent)
    }
}

import QuartzCore
struct BenchEvent {
    enum Body {
        @available(iOS 12.0, *)
        case signpostId(OSSignpostID)

        // before iOS12, we bench with a simple time measurement
        case startTime(TimeInterval)
    }

    let name: StaticString
    let body: Body

    init(name: StaticString, _ body: Body) {
        self.name = name
        self.body = body
    }

    static func legacyTimed(name: StaticString) -> BenchEvent {
        BenchEvent(name: name, .startTime(CACurrentMediaTime()))
    }
}
