import Foundation

@MainActor
final class OptionAnalyzerAPIClient: ObservableObject {
    @Published var status: StatusResponse?
    @Published var execution: ExecutionResponse?
    @Published var stages: StagesResponse?
    @Published var isLoading = false
    @Published var errorMessage: String?

    // Change only this value when the Windows PC's LAN IP changes.
    var baseURL = "http://192.168.0.117:8788"

    private let session: URLSession

    init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 8
        configuration.timeoutIntervalForResource = 12
        session = URLSession(configuration: configuration)
    }

    func refresh(index: AnalyzerIndex) async {
        isLoading = true
        errorMessage = nil

        do {
            async let statusRequest: StatusResponse = request(
                path: "/api/v1/status",
                index: index
            )
            async let executionRequest: ExecutionResponse = request(
                path: "/api/v1/execution",
                index: index
            )
            async let stagesRequest: StagesResponse = request(
                path: "/api/v1/stages",
                index: index
            )

            let (newStatus, newExecution, newStages) = try await (
                statusRequest,
                executionRequest,
                stagesRequest
            )

            status = newStatus
            execution = newExecution
            stages = newStages
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    private func request<T: Decodable>(
        path: String,
        index: AnalyzerIndex
    ) async throws -> T {
        guard var components = URLComponents(string: baseURL + path) else {
            throw APIError.invalidURL
        }

        components.queryItems = [
            URLQueryItem(name: "index", value: index.rawValue)
        ]

        guard let url = components.url else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.cachePolicy = .reloadIgnoringLocalCacheData

        let (data, response) = try await session.data(for: request)

        guard let http = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard (200...299).contains(http.statusCode) else {
            throw APIError.http(http.statusCode)
        }

        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw APIError.decoding(error.localizedDescription)
        }
    }
}

enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case http(Int)
    case decoding(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API URL."
        case .invalidResponse:
            return "The API returned an invalid response."
        case .http(let code):
            return "API returned HTTP \(code)."
        case .decoding(let message):
            return "Could not decode API response: \(message)"
        }
    }
}
