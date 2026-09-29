import Foundation
import Combine

@MainActor
final class APIService: ObservableObject {
    static let shared = APIService()

    @Published var baseURL = UserDefaults.standard.string(forKey: "apiBaseURL")
        ?? "http://192.168.0.117:8788"

    private let decoder: JSONDecoder = {
        let d = JSONDecoder()
        return d
    }()

    func setBaseURL(_ url: String) {
        baseURL = url.trimmingCharacters(in: .whitespacesAndNewlines)
            .trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        UserDefaults.standard.set(baseURL, forKey: "apiBaseURL")
    }

    func snapshots() async throws -> SnapshotsResponse {
        try await request(path: "/api/v1/snapshots")
    }

    func stages(for index: AnalyzerIndex) async throws -> StagesResponse {
        try await request(
            path: "/api/v1/stages",
            query: [URLQueryItem(name: "index", value: index.apiValue)]
        )
    }

    func execution(for index: AnalyzerIndex) async throws -> ExecutionResponse {
        try await request(
            path: "/api/v1/execution",
            query: [URLQueryItem(name: "index", value: index.apiValue)]
        )
    }

    private func request<T: Decodable>(
        path: String,
        query: [URLQueryItem] = []
    ) async throws -> T {
        guard var components = URLComponents(string: baseURL + path) else {
            throw APIError.invalidURL
        }
        components.queryItems = query.isEmpty ? nil : query

        guard let url = components.url else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 12
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard (200...299).contains(http.statusCode) else {
            throw APIError.httpStatus(http.statusCode)
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decoding(error)
        }
    }
}

enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpStatus(Int)
    case decoding(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API URL."
        case .invalidResponse:
            return "Invalid server response."
        case .httpStatus(let code):
            return "API returned HTTP \(code)."
        case .decoding(let error):
            return "Unable to decode API response: \(error.localizedDescription)"
        }
    }
}

