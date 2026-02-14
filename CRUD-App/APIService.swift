//
//  APIService.swift
//  CRUD-App
//

import Foundation

extension Notification.Name {
    static let didLogout = Notification.Name("didLogout")
}

class APIService {
    static let shared = APIService()
    private let baseHost = "http://192.168.0.101:8080"
    private var usersBaseURL: String { baseHost + "/api/users" }
    private var authBaseURL: String { baseHost + "/api/auth" }

    private let tokenKey = "auth_token"

    var isLoggedIn: Bool { token != nil }
    private var token: String? {
        get { UserDefaults.standard.string(forKey: tokenKey) }
        set {
            if newValue == nil {
                UserDefaults.standard.removeObject(forKey: tokenKey)
            } else {
                UserDefaults.standard.set(newValue, forKey: tokenKey)
            }
        }
    }

    func logout() {
        token = nil
        NotificationCenter.default.post(name: .didLogout, object: nil)
    }

    private init() {}

    private func setAuthHeader(_ request: inout URLRequest) {
        if let t = token {
            request.setValue("Bearer \(t)", forHTTPHeaderField: "Authorization")
        }
    }

    private func performRequest<T: Codable>(
        baseURL: String,
        endpoint: String,
        method: String = "GET",
        body: Data? = nil,
        useAuth: Bool = true,
        responseType: T.Type
    ) async throws -> T {
        guard let url = URL(string: baseURL + endpoint) else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if useAuth { setAuthHeader(&request) }
        if let body = body { request.httpBody = body }

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch let urlError as URLError where urlError.code == .notConnectedToInternet || urlError.code == .networkConnectionLost || urlError.code == .dataNotAllowed {
            throw APIError.offline
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        if httpResponse.statusCode == 401 {
            token = nil
            NotificationCenter.default.post(name: .didLogout, object: nil)
            throw APIError.unauthorized
        }
        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.serverError(httpResponse.statusCode)
        }

        return try JSONDecoder().decode(T.self, from: data)
    }

    private func performRequestWithoutResponse(
        baseURL: String,
        endpoint: String,
        method: String = "GET",
        body: Data? = nil,
        useAuth: Bool = true
    ) async throws {
        guard let url = URL(string: baseURL + endpoint) else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if useAuth { setAuthHeader(&request) }
        if let body = body { request.httpBody = body }

        let response: URLResponse
        do {
            (_, response) = try await URLSession.shared.data(for: request)
        } catch let urlError as URLError where urlError.code == .notConnectedToInternet || urlError.code == .networkConnectionLost || urlError.code == .dataNotAllowed {
            throw APIError.offline
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        if httpResponse.statusCode == 401 {
            token = nil
            NotificationCenter.default.post(name: .didLogout, object: nil)
            throw APIError.unauthorized
        }
        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.serverError(httpResponse.statusCode)
        }
    }

    // MARK: - Auth
    struct LoginResponse: Codable {
        let token: String
        let username: String?
    }

    func login(username: String, password: String) async throws {
        let url = authBaseURL + "/login"
        guard let requestURL = URL(string: url) else { throw APIError.invalidURL }
        var request = URLRequest(url: requestURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: String] = ["username": username, "password": password]
        request.httpBody = try JSONEncoder().encode(body)

        let (data, urlResponse) = try await URLSession.shared.data(for: request)
        guard let httpResponse = urlResponse as? HTTPURLResponse else { throw APIError.invalidResponse }
        if httpResponse.statusCode == 401 {
            throw APIError.unauthorized
        }
        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.serverError(httpResponse.statusCode)
        }
        let decoded = try JSONDecoder().decode(LoginResponse.self, from: data)
        token = decoded.token
    }

    // GET all users
    func fetchUsers() async throws -> [User] {
        return try await performRequest(baseURL: usersBaseURL, endpoint: "", responseType: [User].self)
    }

    // GET user by ID
    func fetchUser(id: Int) async throws -> User {
        return try await performRequest(baseURL: usersBaseURL, endpoint: "/\(id)", responseType: User.self)
    }

    // POST create user
    func createUser(_ user: User) async throws -> User {
        let encoder = JSONEncoder()
        let body = try encoder.encode(user)
        return try await performRequest(baseURL: usersBaseURL, endpoint: "", method: "POST", body: body, responseType: User.self)
    }

    // PUT update user
    func updateUser(_ user: User) async throws -> User {
        guard let id = user.id else {
            throw APIError.invalidURL
        }
        let encoder = JSONEncoder()
        let body = try encoder.encode(user)
        return try await performRequest(baseURL: usersBaseURL, endpoint: "/\(id)", method: "PUT", body: body, responseType: User.self)
    }

    // DELETE user
    func deleteUser(id: Int) async throws {
        try await performRequestWithoutResponse(baseURL: usersBaseURL, endpoint: "/\(id)", method: "DELETE")
    }
}

enum APIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case serverError(Int)
    case decodingError
    case offline
    case unauthorized

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
        case .unauthorized:
            return "用户名或密码错误，请重试"
        }
    }
}
