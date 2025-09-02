import Foundation
import CommonCrypto

// MARK: - Core Functions

func findProjectRoot() -> URL? {
    var currentPath = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)

    while currentPath.path != "/" {
        let specPath = currentPath.appendingPathComponent("SPEC.json")
        if FileManager.default.fileExists(atPath: specPath.path) {
            return currentPath
        }
        currentPath = currentPath.deletingLastPathComponent()
    }

    return nil
}

func computeSHA256(of file: URL) throws -> String {
    let data = try Data(contentsOf: file)
    let digest = data.withUnsafeBytes { bytes in
        var hash = [UInt8](repeating: 0, count: Int(32))
        let _ = CC_SHA256(bytes.bindMemory(to: UInt8.self).baseAddress, CC_LONG(data.count), &hash)
        return hash
    }
    return digest.map { String(format: "%02x", $0) }.joined()
}

// Fallback SHA256 implementation for systems without CommonCrypto
func computeSHA256Fallback(of file: URL) throws -> String {
    let task = Process()
    task.executableURL = URL(fileURLWithPath: "/usr/bin/shasum")
    task.arguments = ["-a", "256", file.path]

    let pipe = Pipe()
    task.standardOutput = pipe

    try task.run()
    task.waitUntilExit()

    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: .utf8) ?? ""
    return String(output.prefix(64))  // First 64 chars are the hash
}