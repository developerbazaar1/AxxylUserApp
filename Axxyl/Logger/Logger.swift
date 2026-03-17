//
//  Untitled.swift
//  Axxyl
//
//  Created by Mangesh on 9/21/25.
//

import Foundation

public final class Logger {
    public static let shared = Logger()

    public enum Level: String {
        case debug = "DEBUG"
        case info  = "INFO"
        case warn  = "WARN"
        case error = "ERROR"
        case misc = "MISC"
    }

    // Notification posted for UIs to append new lines
    public static let newLogNotification = Notification.Name("LoggerNewLogNotification")

    private let ioQueue = DispatchQueue(label: "com.yourapp.logger.queue", qos: .utility)
    private let maxInMemoryLines = 1000
    private var inMemoryLines = [String]()
    private let maxFileBytes: Int = 2 * 1024 * 1024 // 2 MB rotation

    private let fileURL: URL

    private init() {
        let fm = FileManager.default
        let docs = fm.urls(for: .documentDirectory, in: .userDomainMask).first!
        self.fileURL = docs.appendingPathComponent("app.log")
        if !fm.fileExists(atPath: fileURL.path) {
            fm.createFile(atPath: fileURL.path, contents: nil, attributes: nil)
        }
        // preload last lines quickly (non-blocking)
        ioQueue.async {
            if let s = try? String(contentsOf: self.fileURL, encoding: .utf8) {
                let lines = s.split(separator: "\n", omittingEmptySubsequences: false).map { String($0) }
                let tail = lines.suffix(self.maxInMemoryLines)
                DispatchQueue.main.async {
                    self.inMemoryLines = Array(tail)
                }
            }
        }
    }

    // MARK: - Logging

    public func log(_ message: String, level: Level = .info) {
        let ts = Logger.timestamp()
        let line = "\(ts) [\(level.rawValue)] \(message)\n"

        // print to Xcode console as well
        Swift.print(line, terminator: "")

        ioQueue.async {
            self.appendToFile(line)
            self.appendToMemory(line)
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: Logger.newLogNotification, object: line)
            }
            self.rotateIfNeeded()
        }
    }

    private func appendToFile(_ line: String) {
        let data = Data(line.utf8)
        if !FileManager.default.fileExists(atPath: fileURL.path) {
            FileManager.default.createFile(atPath: fileURL.path, contents: nil, attributes: nil)
        }
        if let fh = try? FileHandle(forWritingTo: fileURL) {
            fh.seekToEndOfFile()
            fh.write(data)
            #if swift(>=5.3)
            try? fh.close()
            #else
            fh.closeFile()
            #endif
        } else {
            // fallback atomic append
            if let handle = try? FileHandle(forUpdating: fileURL) {
                handle.seekToEndOfFile()
                handle.write(data)
                #if swift(>=5.3)
                try? handle.close()
                #else
                handle.closeFile()
                #endif
            }
        }
    }

    private func appendToMemory(_ line: String) {
        inMemoryLines.append(line)
        if inMemoryLines.count > maxInMemoryLines {
            inMemoryLines.removeFirst(inMemoryLines.count - maxInMemoryLines)
        }
    }

    private func rotateIfNeeded() {
        guard let attrs = try? FileManager.default.attributesOfItem(atPath: fileURL.path),
              let sizeNum = attrs[.size] as? NSNumber else { return }
        if sizeNum.intValue > maxFileBytes {
            let ts = Logger.timestampFileSafe()
            let archiveURL = fileURL.deletingLastPathComponent().appendingPathComponent("app-\(ts).log")
            try? FileManager.default.moveItem(at: fileURL, to: archiveURL)
            FileManager.default.createFile(atPath: fileURL.path, contents: nil, attributes: nil)
            // keep in-memory lines consistent
            ioQueue.async {
                self.inMemoryLines.removeAll()
            }
        }
    }

    // MARK: - Utilities

    public func readEntireLog() -> String {
        return (try? String(contentsOf: fileURL)) ?? ""
    }

    public func tailText() -> String {
        return inMemoryLines.joined()
    }

    public func currentLogFileURL() -> URL {
        return fileURL
    }

    public func clearLogs() {
        ioQueue.async {
            try? "".write(to: self.fileURL, atomically: true, encoding: .utf8)
            DispatchQueue.main.async {
                self.inMemoryLines.removeAll()
                NotificationCenter.default.post(name: Logger.newLogNotification, object: nil) // notify UI (it should refresh)
            }
        }
    }

    // Optional: capture stdout/stderr to the same file (useful for prints/crash logs) - use carefully
    public func redirectStdErrToLogFile() {
        ioQueue.async {
            freopen(self.fileURL.path, "a+", stderr)
            freopen(self.fileURL.path, "a+", stdout)
        }
    }

    // MARK: - Timestamps
    private static func timestamp() -> String {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        df.timeZone = .current
        return df.string(from: Date())
    }
    private static func timestampFileSafe() -> String {
        let df = DateFormatter()
        df.dateFormat = "yyyyMMdd-HHmmss"
        df.timeZone = .current
        return df.string(from: Date())
    }
}
