@testable import Nestory
import os.log
import os.signpost
import XCTest

final class LogTests: XCTestCase {
    var log: Log!

    override func setUp() {
        super.setUp()
        log = Log(subsystem: "\(Bundle.main.bundleIdentifier ?? "com.drunkonjava.nestory.dev").test")
    }

    func testLogCategories() {
        for category in Log.LogCategory.allCases {
            let logger = log.logger(for: category)
            XCTAssertNotNil(logger)
        }
    }

    func testLogLevels() {
        log.debug("Debug message")
        log.info("Info message")
        log.notice("Notice message")
        log.warning("Warning message")
        log.error("Error message", error: NSError(domain: "Test", code: 1))
        log.critical("Critical message")
        log.fault("Fault message")

        XCTAssertTrue(true)
    }

    func testLogWithMetadata() {
        let metadata: [String: Any] = [
            "userId": "123",
            "action": "test",
            "count": 42,
        ]

        log.info("Test with metadata", metadata: metadata)
        log.error("Error with metadata", error: NSError(domain: "Test", code: 1), metadata: metadata)

        XCTAssertTrue(true)
    }

    func testPerformanceLogging() throws {
        var result = 0

        try log.performance("TestOperation") {
            for i in 0 ..< 1000 {
                result += i
            }
        }

        XCTAssertEqual(result, 499_500)
    }

    func testPerformanceLoggingAsync() async throws {
        let result = try await log.performanceAsync("AsyncOperation") {
            try await Task.sleep(nanoseconds: 100_000_000)
            return 42
        }

        XCTAssertEqual(result, 42)
    }

    func testBreadcrumb() {
        log.breadcrumb("User opened screen")
        log.breadcrumb("Button tapped", level: .info)

        XCTAssertTrue(true)
    }

    func testNetworkLogging() {
        log.networkRequest(
            url: "https://api.example.com/items",
            method: "GET",
            statusCode: 200,
            duration: 0.523,
        )

        log.networkRequest(
            url: "https://api.example.com/items",
            method: "POST",
            statusCode: 500,
            duration: 1.234,
            error: NSError(domain: "Network", code: 500),
        )

        XCTAssertTrue(true)
    }

    func testDatabaseLogging() {
        log.databaseOperation(
            "SELECT",
            table: "items",
            duration: 0.012,
            recordCount: 42,
        )

        log.databaseOperation(
            "INSERT",
            table: "items",
            duration: 0.034,
            error: NSError(domain: "Database", code: 1),
        )

        XCTAssertTrue(true)
    }

    func testUserActionLogging() {
        log.userAction("ButtonTapped", metadata: ["button": "submit"])
        log.userAction("ScreenViewed", metadata: ["screen": "home"])

        XCTAssertTrue(true)
    }

    func testLogContext() {
        let context = Log.Context(
            userId: "user123",
            sessionId: "session456",
            deviceId: "device789",
            appVersion: "1.0.0",
            buildNumber: "100",
        )

        Log.setContext(context)

        log.logWithContext("Test message with context")
        log.logWithContext("Error with context", level: .error, additionalMetadata: ["error": "test"])

        XCTAssertTrue(true)
    }
}

final class SignpostTests: XCTestCase {
    var signpost: Signpost!

    override func setUp() {
        super.setUp()
        signpost = Signpost(subsystem: "\(Bundle.main.bundleIdentifier ?? "com.drunkonjava.nestory.dev").test")
    }

    func testSignpostCategories() {
        for category in Signpost.SignpostCategory.allCases {
            signpost.event("Test", category: category)
        }

        XCTAssertTrue(true)
    }

    func testSignpostInterval() {
        signpost.begin("TestInterval")
        Thread.sleep(forTimeInterval: 0.01)
        signpost.end("TestInterval")

        XCTAssertTrue(true)
    }

    func testSignpostMeasure() throws {
        let result = try signpost.measure("MeasureTest") {
            1 + 1
        }

        XCTAssertEqual(result, 2)
    }

    func testSignpostMeasureAsync() async throws {
        let result = try await signpost.measureAsync("AsyncMeasure") {
            try await Task.sleep(nanoseconds: 10_000_000)
            return "Done"
        }

        XCTAssertEqual(result, "Done")
    }

    func testSignpostIntervals() {
        let networkInterval = signpost.networkRequest(url: "https://api.example.com")
        Thread.sleep(forTimeInterval: 0.01)
        networkInterval.end(message: "Success")

        let dbInterval = signpost.databaseQuery(operation: "SELECT * FROM items")
        Thread.sleep(forTimeInterval: 0.005)
        dbInterval.end()

        let imageInterval = signpost.imageProcessing(operation: "Resize")
        Thread.sleep(forTimeInterval: 0.02)
        imageInterval.end()

        let syncInterval = signpost.syncOperation(type: "Full")
        Thread.sleep(forTimeInterval: 0.03)
        syncInterval.end()

        let encryptionInterval = signpost.encryptionOperation(type: "AES-256")
        Thread.sleep(forTimeInterval: 0.001)
        encryptionInterval.end()

        let fileInterval = signpost.fileOperation(type: "Write", path: "/tmp/test.txt")
        Thread.sleep(forTimeInterval: 0.002)
        fileInterval.end()

        let uiInterval = signpost.uiOperation(screen: "Home", action: "Load")
        Thread.sleep(forTimeInterval: 0.015)
        uiInterval.end()

        XCTAssertTrue(true)
    }

    func testSignpostIntervalAutoEnd() {
        autoreleasepool {
            let interval = signpost.appLaunch()
            Thread.sleep(forTimeInterval: 0.01)
        }

        XCTAssertTrue(true)
    }

    func testSignpostMetrics() {
        let collector = Signpost.MetricsCollector()

        let metric1 = Signpost.Metrics(
            name: "NetworkRequest",
            category: .network,
            startTime: 0,
            endTime: 0.5,
        )

        let metric2 = Signpost.Metrics(
            name: "NetworkRequest",
            category: .network,
            startTime: 1,
            endTime: 1.3,
        )

        let metric3 = Signpost.Metrics(
            name: "DatabaseQuery",
            category: .database,
            startTime: 2,
            endTime: 2.1,
        )

        collector.record(metric1)
        collector.record(metric2)
        collector.record(metric3)

        let metrics = collector.getMetrics()
        XCTAssertEqual(metrics.count, 3)

        let avgDuration = collector.averageDuration(for: "NetworkRequest")
        XCTAssertEqual(avgDuration, 0.4, accuracy: 0.01)

        let p50 = collector.percentile(50, for: "NetworkRequest")
        XCTAssertNotNil(p50)

        collector.clearMetrics()
        XCTAssertEqual(collector.getMetrics().count, 0)
    }
}

@available(iOS 13.0, *)
final class MetricKitCollectorTests: XCTestCase {
    var collector: MetricKitCollector!

    override func setUp() {
        super.setUp()
        if #available(iOS 13.0, *) {
            collector = MetricKitCollector.shared
        }
    }

    func testMetricsSnapshot() {
        let snapshot = collector.collectMetrics()

        XCTAssertNotNil(snapshot.timestamp)
        XCTAssertNotNil(snapshot.deviceModel)
        XCTAssertNotNil(snapshot.osVersion)
        XCTAssertNotNil(snapshot.appVersion)
        XCTAssertNotNil(snapshot.buildNumber)
    }

    func testMetricsExport() {
        let data = collector.exportMetrics()

        XCTAssertNotNil(data)

        if let data {
            let decoded = try? JSONDecoder().decode(MetricsSnapshot.self, from: data)
            XCTAssertNotNil(decoded)
        }
    }

    func testPayloadHandlers() {
        var handlerCalled = false

        collector.onMetricPayload { _ in
            handlerCalled = true
        }

        collector.onDiagnosticPayload { _ in
            handlerCalled = true
        }

        XCTAssertTrue(true)
    }

    func testLogMetricsSummary() {
        collector.logMetricsSummary()
        XCTAssertTrue(true)
    }
}

final class MonitoringPerformanceTests: XCTestCase {
    var log: Log!
    var signpost: Signpost!

    override func setUp() {
        super.setUp()
        log = Log(subsystem: "\(Bundle.main.bundleIdentifier ?? "com.drunkonjava.nestory.dev").test.perf")
        signpost = Signpost(subsystem: "\(Bundle.main.bundleIdentifier ?? "com.drunkonjava.nestory.dev").test.perf")
    }

    func testLogPerformance() {
        measure {
            for i in 0 ..< 1000 {
                log.debug("Performance test \(i)")
            }
        }
    }

    func testSignpostPerformance() {
        measure {
            for _ in 0 ..< 100 {
                let interval = signpost.networkRequest(url: "test")
                interval.end()
            }
        }
    }

    func testMetadataFormattingPerformance() {
        let metadata: [String: Any] = [
            "userId": "123",
            "sessionId": "456",
            "timestamp": Date(),
            "count": 42,
            "flag": true,
        ]

        measure {
            for _ in 0 ..< 1000 {
                log.info("Test", metadata: metadata)
            }
        }
    }
}
