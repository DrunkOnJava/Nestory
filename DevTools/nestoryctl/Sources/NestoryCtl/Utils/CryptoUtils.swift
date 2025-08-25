import Foundation

// MARK: - CommonCrypto Bridge

func CC_SHA256(_ data: UnsafeRawPointer?, _ len: UInt32, _ md: UnsafeMutablePointer<UInt8>?) -> UnsafeMutablePointer<UInt8>? {
    guard let data = data, let md = md else { return nil }
    
    let task = Process()
    task.executableURL = URL(fileURLWithPath: "/usr/bin/python3")
    task.arguments = ["-c", """
import hashlib
import sys
data = sys.stdin.buffer.read()
print(hashlib.sha256(data).hexdigest())
"""]
    
    let inputPipe = Pipe()
    let outputPipe = Pipe()
    task.standardInput = inputPipe
    task.standardOutput = outputPipe
    
    do {
        try task.run()
        inputPipe.fileHandleForWriting.write(Data(bytes: data, count: Int(len)))
        inputPipe.fileHandleForWriting.closeFile()
        
        let output = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let hex = String(data: output, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        // Convert hex string to bytes
        for i in 0..<32 {
            let startIndex = hex.index(hex.startIndex, offsetBy: i * 2)
            let endIndex = hex.index(startIndex, offsetBy: 2)
            if let byte = UInt8(hex[startIndex..<endIndex], radix: 16) {
                md[i] = byte
            }
        }
        
        return md
    } catch {
        return nil
    }
}