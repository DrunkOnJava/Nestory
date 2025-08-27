@testable import Nestory
import XCTest

final class FileStoreTests: XCTestCase {
    var fileStore: FileStore!

    override func setUp() async throws {
        try await super.setUp()
        fileStore = try FileStore(directory: .temporary, subdirectory: "test-\(UUID().uuidString)")
    }

    override func tearDown() async throws {
        try await fileStore.delete("")
        fileStore = nil
        try await super.tearDown()
    }

    func testSaveAndLoadCodable() async throws {
        struct TestModel: Codable, Equatable {
            let id: String
            let name: String
            let value: Int
        }

        let model = TestModel(id: "123", name: "Test", value: 42)

        try await fileStore.save(model, to: "test.json")
        let loaded = try await fileStore.load(TestModel.self, from: "test.json")

        XCTAssertEqual(loaded, model)
    }

    func testSaveAndLoadData() async throws {
        let data = "Hello, World!".data(using: .utf8)!

        try await fileStore.saveData(data, to: "test.txt")
        let loaded = try await fileStore.loadData(from: "test.txt")

        XCTAssertEqual(loaded, data)
    }

    func testFileExists() async throws {
        XCTAssertFalse(fileStore.exists("nonexistent.txt"))

        let data = Data("test".utf8)
        try await fileStore.saveData(data, to: "exists.txt")

        XCTAssertTrue(fileStore.exists("exists.txt"))
    }

    func testDeleteFile() async throws {
        let data = Data("test".utf8)
        try await fileStore.saveData(data, to: "delete.txt")

        XCTAssertTrue(fileStore.exists("delete.txt"))

        try await fileStore.delete("delete.txt")

        XCTAssertFalse(fileStore.exists("delete.txt"))
    }

    func testListFiles() async throws {
        try await fileStore.saveData(Data("1".utf8), to: "file1.txt")
        try await fileStore.saveData(Data("2".utf8), to: "file2.txt")
        try await fileStore.saveData(Data("3".utf8), to: "subdir/file3.txt")

        let files = try await fileStore.listFiles()

        XCTAssertTrue(files.contains("file1.txt"))
        XCTAssertTrue(files.contains("file2.txt"))
        XCTAssertFalse(files.contains("file3.txt"))
    }

    func testFileSize() async throws {
        let data = Data(repeating: 0, count: 1024)
        try await fileStore.saveData(data, to: "sized.bin")

        let size = try await fileStore.size(of: "sized.bin")

        XCTAssertEqual(size, 1024)
    }

    func testTotalSize() async throws {
        try await fileStore.saveData(Data(repeating: 0, count: 1024), to: "file1.bin")
        try await fileStore.saveData(Data(repeating: 0, count: 2048), to: "file2.bin")

        let totalSize = try await fileStore.totalSize()

        XCTAssertGreaterThanOrEqual(totalSize, 3072)
    }
}

final class CacheTests: XCTestCase {
    var cache: Cache<String, String>!

    override func setUp() async throws {
        try await super.setUp()
        cache = try Cache(name: "test-\(UUID().uuidString)", maxMemoryCount: 10, ttl: 1.0)
    }

    override func tearDown() async throws {
        await cache.removeAll()
        cache = nil
        try await super.tearDown()
    }

    func testSetAndGet() async {
        await cache.set("value1", for: "key1")
        let value = await cache.get(for: "key1")

        XCTAssertEqual(value, "value1")
    }

    func testRemove() async {
        await cache.set("value1", for: "key1")
        await cache.remove(for: "key1")
        let value = await cache.get(for: "key1")

        XCTAssertNil(value)
    }

    func testContains() async {
        await cache.set("value1", for: "key1")

        let containsKey1 = await cache.contains(key: "key1")
        XCTAssertTrue(containsKey1)
        let containsKey2 = await cache.contains(key: "key2")
        XCTAssertFalse(containsKey2)
    }

    func testTTLExpiration() async throws {
        await cache.set("value1", for: "key1")

        try await Task.sleep(nanoseconds: 1_500_000_000)

        let value = await cache.get(for: "key1")
        XCTAssertNil(value)
    }

    func testRemoveAll() async {
        await cache.set("value1", for: "key1")
        await cache.set("value2", for: "key2")

        await cache.removeAll()

        let value1 = await cache.get(for: "key1")
        XCTAssertNil(value1)
        let value2 = await cache.get(for: "key2")
        XCTAssertNil(value2)
    }
}

final class ImageIOTests: XCTestCase {
    var imageIO: ImageIO!

    override func setUp() {
        super.setUp()
        imageIO = ImageIO(compressionQuality: 0.8)
    }

    func testImageFormats() throws {
        let size = CGSize(width: 100, height: 100)
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            UIColor.red.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }

        let jpegData = try imageIO.encodeImage(image, format: .jpeg)
        XCTAssertNotNil(jpegData)
        XCTAssertGreaterThan(jpegData.count, 0)

        let pngData = try imageIO.encodeImage(image, format: .png)
        XCTAssertNotNil(pngData)
        XCTAssertGreaterThan(pngData.count, 0)

        if #available(iOS 14.0, *) {
            let heicData = try imageIO.encodeImage(image, format: .heic)
            XCTAssertNotNil(heicData)
            XCTAssertGreaterThan(heicData.count, 0)
        }
    }

    func testImageResizing() async throws {
        let size = CGSize(width: 1000, height: 1000)
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            UIColor.blue.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }

        let resized = try await imageIO.resizeImage(image, maxDimension: 500)

        XCTAssertLessThanOrEqual(resized.size.width, 500)
        XCTAssertLessThanOrEqual(resized.size.height, 500)
    }

    func testImageCropping() async throws {
        let size = CGSize(width: 200, height: 200)
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            UIColor.green.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }

        let cropRect = CGRect(x: 50, y: 50, width: 100, height: 100)
        let cropped = try await imageIO.cropImage(image, to: cropRect)

        XCTAssertEqual(cropped.size.width, 100)
        XCTAssertEqual(cropped.size.height, 100)
    }
}

final class ThumbnailerTests: XCTestCase {
    var thumbnailer: Thumbnailer!

    override func setUp() {
        super.setUp()
        thumbnailer = Thumbnailer()
    }

    func testThumbnailGeneration() async throws {
        let size = CGSize(width: 1000, height: 1000)
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            UIColor.yellow.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }

        let thumbnail = try await thumbnailer.generateThumbnail(from: image)

        XCTAssertLessThanOrEqual(thumbnail.size.width, 150)
        XCTAssertLessThanOrEqual(thumbnail.size.height, 150)
    }

    func testDisplayImageGeneration() async throws {
        let size = CGSize(width: 2000, height: 2000)
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            UIColor.purple.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }

        let displayImage = try await thumbnailer.generateDisplayImage(from: image)

        XCTAssertLessThanOrEqual(displayImage.size.width, 800)
        XCTAssertLessThanOrEqual(displayImage.size.height, 800)
    }

    func testProcessedImages() async throws {
        let size = CGSize(width: 1500, height: 1500)
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            UIColor.orange.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }

        let data = image.jpegData(compressionQuality: 0.9)!
        let processed = try await thumbnailer.processImage(from: data)

        XCTAssertNotNil(processed.original)
        XCTAssertNotNil(processed.thumbnail)
        XCTAssertNotNil(processed.display)
        XCTAssertLessThanOrEqual(processed.thumbnail.size.width, 150)
        XCTAssertLessThanOrEqual(processed.display.size.width, 800)
    }
}

final class PerceptualHashTests: XCTestCase {
    var pHash: PerceptualHash!

    override func setUp() {
        super.setUp()
        pHash = PerceptualHash()
    }

    func testHashGeneration() async throws {
        let size = CGSize(width: 200, height: 200)
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            UIColor.red.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }

        let hash = try await pHash.hash(image: image)

        XCTAssertNotEqual(hash, 0)
    }

    func testSimilarImages() async throws {
        let size = CGSize(width: 200, height: 200)
        let renderer = UIGraphicsImageRenderer(size: size)

        let image1 = renderer.image { context in
            UIColor.red.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }

        let image2 = renderer.image { context in
            UIColor.red.withAlphaComponent(0.95).setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }

        let hash1 = try await pHash.hash(image: image1)
        let hash2 = try await pHash.hash(image: image2)

        let similarity = pHash.similarity(hash1: hash1, hash2: hash2)

        XCTAssertGreaterThan(similarity, 0.8)
    }

    func testDifferentImages() async throws {
        let size = CGSize(width: 200, height: 200)
        let renderer = UIGraphicsImageRenderer(size: size)

        let image1 = renderer.image { context in
            UIColor.red.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }

        let image2 = renderer.image { context in
            UIColor.blue.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }

        let hash1 = try await pHash.hash(image: image1)
        let hash2 = try await pHash.hash(image: image2)

        let similarity = pHash.similarity(hash1: hash1, hash2: hash2)

        XCTAssertLessThan(similarity, 0.5)
    }

    func testHashStringConversion() {
        let hash: UInt64 = 0x1234_5678_9ABC_DEF0
        let hashString = pHash.hashString(from: hash)
        let recoveredHash = pHash.hash(from: hashString)

        XCTAssertEqual(hash, recoveredHash)
    }
}
