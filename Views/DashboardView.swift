import SwiftUI
import Foundation

struct DashboardView: View {
    @StateObject private var model = AnalyzerViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 14) {

                    Picker(
                        "Index",
                        selection: Binding(
                            get: { model.selectedIndex },
                            set: { model.changeIndex($0) }
                        )
                    ) {
                        ForEach(AnalyzerIndex.allCases) { index in
                            Text(index.rawValue)
                                .tag(index)
                        }
                    }
                    .pickerStyle(.segmented)

                    card("WHAT TO DO NOW") {
                        Text(
                            model.execution?.finalDecision.decision
                                ?? "NO CONFIRMATION / WAIT"
                        )
                        .font(.title3.bold())

                        Text(
                            model.execution?.finalDecision.reasons?.first
                                ?? "Loading analyzer state..."
                        )
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    }

                    LazyVGrid(
                        columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ]
                    ) {
                        tile(
                            "Direction",
                            model.execution?.finalDecision.bias
                        )

                        tile(
                            "Context",
                            model.execution?.finalDecision.quality
                        )

                        tile(
                            "15M Confirmation",
                            model.execution?.execution.confirmationStatus
                        )

                        tile(
                            "Fibonacci",
                            model.stages?.stages.fibonacci.signal
                        )
                    }

                    card("EXECUTION") {
                        let execution = model.execution?.execution

                        HStack {
                            value("Entry", execution?.entry)
                            value("Stop Loss", execution?.stop)
                        }

                        HStack {
                            value("2R Target", execution?.target2R)
                            value("5M Trigger", execution?.trigger)
                        }

                        Text(
                            execution?.detail?.first
                                ?? "Execution state unavailable."
                        )
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }

                    StageAnalysisView(
                        stages: model.stages?.stages
                    )

                    card("MTF / EXECUTION STATUS") {
                        row(
                            "Weekly",
                            model.execution?.mtf.weekly?.direction
                        )

                        row(
                            "Daily",
                            model.execution?.mtf.daily?.direction
                        )

                        row(
                            "4H",
                            model.execution?.mtf.fourHour?.direction
                        )

                        row(
                            "1H",
                            model.execution?.mtf.oneHour?.direction
                        )

                        row(
                            "Tide",
                            model.execution?.mtf.tide
                        )

                        row(
                            "Wave",
                            model.execution?.mtf.wave
                        )

                        row(
                            "Alignment",
                            model.execution?.mtf.alignment
                        )
                    }
                }
                .padding()
            }
            .navigationTitle(model.selectedIndex.rawValue)
            .refreshable {
                await model.load()
            }
            .task {
                await model.load()
            }
            .toolbar {
                Button {
                    Task {
                        await model.load()
                    }
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
            }
            .alert(
                "API Connection",
                isPresented: Binding(
                    get: { model.errorMessage != nil },
                    set: {
                        if !$0 {
                            model.errorMessage = nil
                        }
                    }
                )
            ) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(model.errorMessage ?? "")
            }
        }
    }

    @ViewBuilder
    private func card<Content: View>(
        _ title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)

            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            .thinMaterial,
            in: RoundedRectangle(cornerRadius: 16)
        )
    }

    private func tile(
        _ title: String,
        _ value: String?
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(value ?? "WAIT")
                .font(.subheadline.bold())
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            .thinMaterial,
            in: RoundedRectangle(cornerRadius: 12)
        )
    }

    private func value(
        _ title: String,
        _ number: Double?
    ) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(number.map { String(format: "%.2f", $0) } ?? "—")
                .font(.subheadline.bold())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func row(
        _ title: String,
        _ value: String?
    ) -> some View {
        HStack {
            Text(title)
                .font(.subheadline)

            Spacer()

            Text(value ?? "—")
                .font(.subheadline.bold())
        }
    }
}