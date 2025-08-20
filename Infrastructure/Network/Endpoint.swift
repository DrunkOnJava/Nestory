// Layer: Infrastructure

import Foundation

public struct Endpoint {
    public let method: HTTPMethod
    public let path: String
    public let query: [String: String]
    public let headers: [String: String]
    public let body: Data?
    public let timeout: TimeInterval

    public init(
        method: HTTPMethod,
        path: String,
        query: [String: String] = [:],
        headers: [String: String] = [:],
        body: Data? = nil,
        timeout: TimeInterval = 30
    ) {
        self.method = method
        self.path = path
        self.query = query
        self.headers = headers
        self.body = body
        self.timeout = timeout
    }

    public func urlRequest(baseURL: URL) throws -> URLRequest {
        var components = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: true)

        if !query.isEmpty {
            components?.queryItems = query.map { URLQueryItem(name: $0.key, value: $0.value) }
        }

        guard let url = components?.url else {
            throw NetworkError.invalidURL(path: path)
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.httpBody = body
        request.timeoutInterval = timeout

        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }

        if body != nil, request.value(forHTTPHeaderField: "Content-Type") == nil {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        return request
    }
}

public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
    case head = "HEAD"
    case options = "OPTIONS"
}

extension Endpoint {
    public static func get(_ path: String, query: [String: String] = [:]) -> Endpoint {
        Endpoint(method: .get, path: path, query: query)
    }

    public static func post(_ path: String, body: Data? = nil) -> Endpoint {
        Endpoint(method: .post, path: path, body: body)
    }

    public static func put(_ path: String, body: Data? = nil) -> Endpoint {
        Endpoint(method: .put, path: path, body: body)
    }

    public static func patch(_ path: String, body: Data? = nil) -> Endpoint {
        Endpoint(method: .patch, path: path, body: body)
    }

    public static func delete(_ path: String) -> Endpoint {
        Endpoint(method: .delete, path: path)
    }
}
