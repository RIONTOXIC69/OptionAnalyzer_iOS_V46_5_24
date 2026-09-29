import SwiftUI

struct ContentView: View {
    @StateObject private var model = AnalyzerViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    IndexSelector(selectedIndex: $model.selectedIndex)
                        .onChange(of: model.selectedIndex) { _, newValue in
                            model.changeIndex(newValue)
                        }

                    if let error = model.errorMessage {
                        ErrorCard(message: error)
                    }

                    if model.isLoading && model.stages == nil {
                        ProgressView("Loading analyzer…")
                            .padding(.vertical, 30)
                    } else {
                        if let stages = model.stages {
                            FinalDecisionCard(decision: stages.finalDecision)
                            StageListView(stages: stages.stages)
                        }

                        if let execution = model.execution {
                            ExecutionView(response: execution)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Option Analyzer")
            .refreshable {
                await model.load()
            }
            .task {
                await model.load()
            }
        }
    }
}

struct IndexSelector: View {
    @Binding var selectedIndex: AnalyzerIndex

    var body: some View {
        Picker("Index", selection: $selectedIndex) {
            ForEach(AnalyzerIndex.allCases) { index in
                Text(index.rawValue).tag(index)
            }
        }
        .pickerStyle(.segmented)
    }
}

struct FinalDecisionCard: View {
    let decision: FinalDecision

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("FINAL DECISION")
                .font(.caption.weight(.bold))
                .foregroundStyle(.secondary)

            Text(decision.decision ?? "NO CONFIRMATION / WAIT")
                .font(.title3.weight(.bold))

            HStack {
                Text("Bias: \(decision.bias ?? "—")")
                Text("Quality: \(decision.quality ?? "—")")
            }
            .font(.subheadline)

            ForEach(decision.blockers ?? [], id: \.self) {
                Text("• \($0)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

struct StageListView: View {
    let stages: StageBundle

    var body: some View {
        VStack(spacing: 10) {
            StageCard(number: 1, title: "Option Direction",
                      status: stages.optionDirection.direction ?? "WAIT",
                      detail: stages.optionDirection.confirmation ?? "")
            StageCard(number: 2, title: "OI / Price Action",
                      status: stages.oiPriceAction.decision ?? "WAIT",
                      detail: stages.oiPriceAction.detail ?? "")
            StageCard(number: 3, title: "Support / Resistance",
                      status: stages.supportResistance.decision ?? "WAIT",
                      detail: stages.supportResistance.detail ?? "")
            StageCard(number: 4, title: "Market Structure",
                      status: stages.marketStructure.decision ?? "WAIT",
                      detail: stages.marketStructure.detail ?? "")
            StageCard(number: 5, title: "Order Block",
                      status: stages.orderBlock.type ?? "WAIT",
                      detail: stages.orderBlock.detail ?? "")
            StageCard(number: 6, title: "Chart Pattern",
                      status: stages.chartPattern.pattern ?? "WAIT",
                      detail: stages.chartPattern.detail ?? "")
            StageCard(number: 7, title: "Elliott Wave",
                      status: stages.elliottWave.wave ?? "WAIT",
                      detail: stages.elliottWave.detail ?? "")
            StageCard(number: 8, title: "Confirmation Candle",
                      status: stages.confirmationCandle.signal ?? "WAIT",
                      detail: stages.confirmationCandle.detail ?? "")
            StageCard(number: 9, title: "Fibonacci Retracement",
                      status: stages.fibonacci.signal ?? "WAIT",
                      detail: stages.fibonacci.detail ?? "")
        }
    }
}

struct StageCard: View {
    let number: Int
    let title: String
    let status: String
    let detail: String

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack {
                Text("STAGE \(number)")
                    .font(.caption.weight(.bold))
                Text(title)
                    .font(.headline)
                Spacer()
                Text(status)
                    .font(.caption.weight(.bold))
                    .multilineTextAlignment(.trailing)
            }

            if !detail.isEmpty {
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct ErrorCard: View {
    let message: String

    var body: some View {
        Text(message)
            .font(.caption)
            .foregroundStyle(.red)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(.red.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
