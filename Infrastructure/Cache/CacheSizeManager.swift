//
// Layer: Infrastructure
// Module: Cache
// Purpose: Manage and enforce cache size limits
//

import Foundation
import os.log

public enum CacheSizeManager {
    private static let logger = Logger(subsystem: "com.nestory", category: "CacheSizeManager")
    
    public static func calculateDiskUsage(at url: URL, using fileManager: FileManager) async -> Int {
        await withCheckedContinuation { (continuation: CheckedContinuation<Int, Never>) in
            do {
                let contents = try fileManager.contentsOfDirectory(
                    at: url,
                    includingPropertiesForKeys: [.fileSizeKey],
                    options: [.skipsHiddenFiles]
                )
                
                let totalSize = contents.reduce(0) { sum, fileURL in
                    let size = (try? fileURL.resourceValues(forKeys: [.fileSizeKey]))?.fileSize ?? 0
                    return sum + size
                }
                
                continuation.resume(returning: totalSize)
            } catch {
                logger.error("Failed to calculate disk usage: \(error.localizedDescription)")
                continuation.resume(returning: 0)
            }
        }
    }
    
    public static func enforceSizeLimit(
        at url: URL,
        currentSize: Int,
        maxSize: Int,
        using fileManager: FileManager
    ) async {
        guard currentSize > maxSize else { return }
        
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            do {
                let contents = try fileManager.contentsOfDirectory(
                    at: url,
                    includingPropertiesForKeys: [.fileSizeKey, .contentModificationDateKey],
                    options: [.skipsHiddenFiles]
                )
                
                // Sort by modification date, oldest first
                let sortedContents = contents.sorted { url1, url2 in
                    let date1 = (try? url1.resourceValues(forKeys: [.contentModificationDateKey]))?.contentModificationDate ?? Date.distantPast
                    let date2 = (try? url2.resourceValues(forKeys: [.contentModificationDateKey]))?.contentModificationDate ?? Date.distantPast
                    return date1 < date2
                }
                
                var totalSize = currentSize
                for fileURL in sortedContents {
                    guard totalSize > maxSize else { break }
                    
                    let size = (try? fileURL.resourceValues(forKeys: [.fileSizeKey]))?.fileSize ?? 0
                    try fileManager.removeItem(at: fileURL)
                    totalSize -= size
                    
                    logger.debug("Removed \(fileURL.lastPathComponent) to enforce size limit")
                }
                
                logger.debug("Enforced disk size limit: \(totalSize) / \(maxSize)")
            } catch {
                logger.error("Failed to enforce disk size limit: \(error.localizedDescription)")
            }
            
            continuation.resume()
        }
    }
}