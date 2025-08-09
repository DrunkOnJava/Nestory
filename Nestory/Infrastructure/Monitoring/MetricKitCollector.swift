// Layer: Infrastructure

import Foundation
import MetricKit
import os.log

@available(iOS 13.0, *)
public final class MetricKitCollector: NSObject {
    private let logger = Logger(subsystem: "com.nestory", category: "MetricKit")
    private var payloadHandlers: [(MXMetricPayload) -> Void] = []
    private var diagnosticHandlers: [(MXDiagnosticPayload) -> Void] = []

    public static let shared = MetricKitCollector()

    override private init() {
        super.init()
        MXMetricManager.shared.add(self)
        logger.info("MetricKit collector initialized")
    }

    deinit {
        MXMetricManager.shared.remove(self)
    }

    public func onMetricPayload(_ handler: @escaping (MXMetricPayload) -> Void) {
        payloadHandlers.append(handler)
    }

    public func onDiagnosticPayload(_ handler: @escaping (MXDiagnosticPayload) -> Void) {
        diagnosticHandlers.append(handler)
    }

    public func collectMetrics() -> MetricsSnapshot {
        MetricsSnapshot(
            timestamp: Date(),
            deviceModel: ProcessInfo.processInfo.environment["SIMULATOR_DEVICE_NAME"] ?? "Device",
            osVersion: ProcessInfo.processInfo.operatingSystemVersionString,
            appVersion: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown",
            buildNumber: Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
        )
    }

    @available(iOS 14.0, *)
    public func processPayload(_ payload: MXMetricPayload) -> ProcessedMetrics {
        var metrics = ProcessedMetrics()

        if let cpuMetrics = payload.cpuMetrics {
            metrics.cpu = CPUMetrics(
                cumulativeCPUTime: cpuMetrics.cumulativeCPUTime.value,
                cumulativeCPUInstructions: cpuMetrics.cumulativeCPUInstructions.value
            )
        }

        if let memoryMetrics = payload.memoryMetrics {
            metrics.memory = MemoryMetrics(
                peakMemoryUsage: memoryMetrics.peakMemoryUsage.value,
                averageSuspendedMemory: memoryMetrics.averageSuspendedMemory.averageMeasurement.value
            )
        }

        if let diskMetrics = payload.diskIOMetrics {
            metrics.disk = DiskMetrics(
                cumulativeLogicalWrites: diskMetrics.cumulativeLogicalWrites.value
            )
        }

        if let networkMetrics = payload.networkTransferMetrics {
            metrics.network = NetworkMetrics(
                cumulativeCellularUpload: networkMetrics.cumulativeCellularUpload.value,
                cumulativeCellularDownload: networkMetrics.cumulativeCellularDownload.value,
                cumulativeWiFiUpload: networkMetrics.cumulativeWifiUpload.value,
                cumulativeWiFiDownload: networkMetrics.cumulativeWifiDownload.value
            )
        }

        if let displayMetrics = payload.displayMetrics {
            metrics.display = DisplayMetrics(
                averagePixelLuminance: displayMetrics.averagePixelLuminance?.averageMeasurement.value
            )
        }

        if payload.applicationLaunchMetrics != nil {
            metrics.launch = LaunchMetrics(
                timeToFirstDraw: nil,
                applicationResumeTime: nil
            )
        }

        if let applicationResponsivenessMetrics = payload.applicationResponsivenessMetrics {
            metrics.responsiveness = ResponsivenessMetrics(
                histogrammedAppHangTime: applicationResponsivenessMetrics.histogrammedApplicationHangTime
            )
        }

        return metrics
    }

    @available(iOS 14.0, *)
    public func processDiagnostic(_ payload: MXDiagnosticPayload) -> ProcessedDiagnostics {
        var diagnostics = ProcessedDiagnostics()

        if let crashDiagnostics = payload.crashDiagnostics {
            diagnostics.crashes = crashDiagnostics.map { diagnostic in
                CrashReport(
                    exceptionType: diagnostic.exceptionType?.intValue,
                    exceptionCode: diagnostic.exceptionCode?.intValue,
                    signal: diagnostic.signal?.intValue,
                    terminationReason: diagnostic.terminationReason,
                    virtualMemoryRegionInfo: diagnostic.virtualMemoryRegionInfo,
                    diagnosticMetaData: diagnostic.metaData
                )
            }
        }

        if let hangDiagnostics = payload.hangDiagnostics {
            diagnostics.hangs = hangDiagnostics.map { diagnostic in
                HangReport(
                    hangDuration: diagnostic.hangDuration.value,
                    diagnosticMetaData: diagnostic.metaData
                )
            }
        }

        if let diskWriteDiagnostics = payload.diskWriteExceptionDiagnostics {
            diagnostics.diskWrites = diskWriteDiagnostics.map { diagnostic in
                DiskWriteReport(
                    totalWritesCaused: diagnostic.totalWritesCaused.value,
                    diagnosticMetaData: diagnostic.metaData
                )
            }
        }

        return diagnostics
    }

    public func exportMetrics() -> Data? {
        let snapshot = collectMetrics()
        return try? JSONEncoder().encode(snapshot)
    }

    public func logMetricsSummary() {
        let snapshot = collectMetrics()
        logger.info("""
        Metrics Summary:
        Device: \(snapshot.deviceModel)
        OS: \(snapshot.osVersion)
        App: \(snapshot.appVersion) (\(snapshot.buildNumber))
        Timestamp: \(snapshot.timestamp)
        """)
    }
}

@available(iOS 13.0, *)
extension MetricKitCollector: MXMetricManagerSubscriber {
    public func didReceive(_ payloads: [MXMetricPayload]) {
        logger.info("Received \(payloads.count) metric payloads")

        for payload in payloads {
            if #available(iOS 14.0, *) {
                let processed = processPayload(payload)
                logger.debug("Processed metrics: \(String(describing: processed))")
            }

            for handler in payloadHandlers {
                handler(payload)
            }
        }
    }

    public func didReceive(_ payloads: [MXDiagnosticPayload]) {
        logger.warning("Received \(payloads.count) diagnostic payloads")

        for payload in payloads {
            if #available(iOS 14.0, *) {
                let processed = processDiagnostic(payload)
                logger.debug("Processed diagnostics: \(String(describing: processed))")
            }

            for handler in diagnosticHandlers {
                handler(payload)
            }
        }
    }
}

public struct MetricsSnapshot: Codable {
    public let timestamp: Date
    public let deviceModel: String
    public let osVersion: String
    public let appVersion: String
    public let buildNumber: String
}

public struct ProcessedMetrics {
    public var cpu: CPUMetrics?
    public var memory: MemoryMetrics?
    public var disk: DiskMetrics?
    public var network: NetworkMetrics?
    public var display: DisplayMetrics?
    public var launch: LaunchMetrics?
    public var responsiveness: ResponsivenessMetrics?
}

public struct CPUMetrics {
    public let cumulativeCPUTime: Double
    public let cumulativeCPUInstructions: Double?
}

public struct MemoryMetrics {
    public let peakMemoryUsage: Double
    public let averageSuspendedMemory: Double
}

public struct DiskMetrics {
    public let cumulativeLogicalWrites: Double
}

public struct NetworkMetrics {
    public let cumulativeCellularUpload: Double
    public let cumulativeCellularDownload: Double
    public let cumulativeWiFiUpload: Double
    public let cumulativeWiFiDownload: Double
}

public struct DisplayMetrics {
    public let averagePixelLuminance: Double?
}

public struct LaunchMetrics {
    public let timeToFirstDraw: Double?
    public let applicationResumeTime: Double?
}

@available(iOS 14.0, *)
public struct ResponsivenessMetrics {
    public let histogrammedAppHangTime: MXHistogram<UnitDuration>
}

public struct ProcessedDiagnostics {
    public var crashes: [CrashReport] = []
    public var hangs: [HangReport] = []
    public var diskWrites: [DiskWriteReport] = []
}

public struct CrashReport {
    public let exceptionType: Int?
    public let exceptionCode: Int?
    public let signal: Int?
    public let terminationReason: String?
    public let virtualMemoryRegionInfo: String?
    public let diagnosticMetaData: MXMetaData?
}

public struct HangReport {
    public let hangDuration: Double
    public let diagnosticMetaData: MXMetaData?
}

public struct DiskWriteReport {
    public let totalWritesCaused: Double
    public let diagnosticMetaData: MXMetaData?
}
