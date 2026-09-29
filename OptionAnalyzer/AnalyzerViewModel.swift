import Foundation
import Combine

@MainActor
final class AnalyzerViewModel: ObservableObject {
    @Published var selectedIndex: AnalyzerIndex = .nifty50
    @Published var stages: StagesResponse?
    @Published var execution: ExecutionResponse?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let api = APIService.shared

    func load() async {
        isLoading = true
        errorMessage = nil

        do {
            async let stageTask = api.stages(for: selectedIndex)
            async let executionTask = api.execution(for: selectedIndex)

            let (stageResult, executionResult) = try await (stageTask, executionTask)
            stages = stageResult
            execution = executionResult
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func changeIndex(_ index: AnalyzerIndex) {
        selectedIndex = index
        Task { await load() }
    }
}
