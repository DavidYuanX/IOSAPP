//
//  APIService.swift
//  CRUD-App
//

import Foundation

class APIService {
    static let shared = APIService()
    private let baseURL = "http://192.168.0.101:8080/api/users"

    private init() {}

    private func performRequest<T: Codable>(
        endpoint: String,
        method: String = "GET",
        body: Data? = nil,
        responseType: T.Type
    ) async throws -> T {
        guard let url = URL(string: baseURL + endpoint) else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let body = body {
            request.httpBody = body
        }

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch let urlError as URLError where urlError.code == .notConnectedToInternet || urlError.code == .networkConnectionLost || urlError.code == .dataNotAllowed {
            throw APIError.offline
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.serverError(httpResponse.statusCode)
        }

        return try JSONDecoder().decode(T.self, from: data)
    }

    private func performRequestWithoutResponse(
        endpoint: String,
        method: String = "GET",
        body: Data? = nil
    ) async throws {
        guard let url = URL(string: baseURL + endpoint) else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let body = body {
            request.httpBody = body
        }

        let response: URLResponse
        do {
            (_, response) = try await URLSession.shared.data(for: request)
        } catch let urlError as URLError where urlError.code == .notConnectedToInternet || urlError.code == .networkConnectionLost || urlError.code == .dataNotAllowed {
            throw APIError.offline
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.serverError(httpResponse.statusCode)
        }
    }

    // GET all users
    func fetchUsers() async throws -> [User] {
        return try await performRequest(endpoint: "", responseType: [User].self)
    }

    // GET user by ID
    func fetchUser(id: Int) async throws -> User {
        return try await performRequest(endpoint: "/\(id)", responseType: User.self)
    }

    // POST create user
    func createUser(_ user: User) async throws -> User {
        let encoder = JSONEncoder()
        let body = try encoder.encode(user)
        return try await performRequest(endpoint: "", method: "POST", body: body, responseType: User.self)
    }

    // PUT update user
    func updateUser(_ user: User) async throws -> User {
        guard let id = user.id else {
            throw APIError.invalidURL
        }
        let encoder = JSONEncoder()
        let body = try encoder.encode(user)
        return try await performRequest(endpoint: "/\(id)", method: "PUT", body: body, responseType: User.self)
    }

    // DELETE user
    func deleteUser(id: Int) async throws {
        try await performRequestWithoutResponse(endpoint: "/\(id)", method: "DELETE")
    }
}

enum APIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case serverError(Int)
    case decodingError
    case offline

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .serverError(let code):
            return "Server error: \(code)"
        case .decodingError:
            return "Failed to decode response"
        case .offline:
            return "No internet connection. Please check your network and try again."
        }
    }
}
