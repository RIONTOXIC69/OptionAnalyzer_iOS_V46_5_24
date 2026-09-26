import SwiftUI

struct ContentView: View {
    @StateObject private var api = OptionAnalyzerAPIClient()
    @State private var selectedIndex: AnalyzerIndex = .nifty50
    @State private var timer: Timer?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    header
                    indexPicker
                    whatToDoNow
                    summaryGrid
                    tradeProgress
                    executionCard
                    stagesSection
                    mtfSection
                    decisionSection
                    footer
                }
                .padding(16)
            }
            .background(Color(red: 0.015, green: 0.055, blue: 0.05))
            .foregroundStyle(.white)
            .toolbar(.hidden, for: .navigationBar)
            .task {
                await api.refresh(index: selectedIndex)
                startPolling()
            }
            .onDisappear {
                timer?.invalidate()
            }
            .onChange(of: selectedIndex) {
                Task { await api.refresh(index: selectedIndex) }
            }
            .refreshable {
                await api.refresh(index: selectedIndex)
            }
        }
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 5) {
                Text("\(selectedIndex.rawValue) • INTERDAY")
                    .font(.caption.weight(.bold))
                    .tracking(2)
                    .foregroundStyle(.secondary)

                Text("Option Trading Analyzer")
                    .font(.system(size: 30, weight: .bold))

                Text("Updated \(api.status?.generatedAtIST ?? "—")")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button {
                Task { await api.refresh(index: selectedIndex) }
            } label: {
                Image(systemName: "arrow.clockwise")
                    .font(.title3.weight(.semibold))
                    .frame(width: 52, height: 52)
            }
            .buttonStyle(.bordered)
            .tint(.white.opacity(0.7))
        }
    }

    private var indexPicker: some View {
        HStack {
            Text("INDEX")
                .font(.caption.weight(.semibold))
                .tracking(1.5)
                .foregroundStyle(.secondary)

            Spacer()

            Picker("Index", selection: $selectedIndex) {
                ForEach(AnalyzerIndex.allCases) { index in
                    Text(index.rawValue).tag(index)
                }
            }
            .pickerStyle(.menu)
            .tint(.white)
        }
        .padding(18)
        .card()
    }

    private var whatToDoNow: some View {
        let decision = api.status?.finalDecision?.decision ?? "WAIT"
        let reason = api.status?.finalDecision?.reasons?.first
            ?? api.status?.interday?.action
            ?? "Waiting for analyzer state."

        return VStack(alignment: .leading, spacing: 8) {
            Text("WHAT TO DO NOW")
                .font(.caption.weight(.bold))
                .tracking(2)
                .foregroundStyle(.secondary)

            Text(decision.contains("WAIT") ? "WAIT" : decision)
                .font(.system(size: 48, weight: .heavy))

            Text(reason)
                .font(.headline)
                .foregroundStyle(.secondary)
        }
        .padding(24)
        .card()
    }

    private var summaryGrid: some View {
        let interday = api.status?.interday

        return LazyVGrid(columns: [.init(.flexible()), .init(.flexible())], spacing: 12) {
            SummaryCell(title: "DIRECTION", value: interday?.direction ?? "—")
            SummaryCell(title: "CONTEXT", value: interday?.context ?? "—")
            SummaryCell(title: "15M CONFIRMATION", value: interday?.stage8 ?? "WAIT")
            SummaryCell(title: "FIBONACCI", value: interday?.stage9 ?? "WAIT")
        }
    }

    private var tradeProgress: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("TRADE PROGRESS")
                    .font(.headline.weight(.semibold))
                    .tracking(1.5)
                Spacer()
                Text(progressText)
                    .foregroundStyle(.secondary)
            }

            HStack {
                progressNode("1", "Direction")
                progressLine
                progressNode("2", "15M")
                progressLine
                progressNode("3", "Fibonacci")
                progressLine
                progressNode("4", "5M Trigger")
            }
        }
        .padding(20)
        .card()
    }

    private var executionCard: some View {
        let e = api.execution?.execution

        return VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("EXECUTION")
                    .font(.headline.weight(.semibold))
                    .tracking(1.5)
                Spacer()
                Text(e?.executionPhase ?? "IDLE")
                    .foregroundStyle(.secondary)
            }

            LazyVGrid(columns: [.init(.flexible()), .init(.flexible())], spacing: 12) {
                MetricCell(title: "ENTRY", value: number(e?.entry))
                MetricCell(title: "STOP LOSS", value: number(e?.stop))
                MetricCell(title: "2R TARGET", value: number(e?.target2R ?? e?.target2))
                MetricCell(title: "5M TRIGGER", value: number(e?.trigger))
            }
        }
        .padding(20)
        .card()
    }

    private var stagesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("9-STAGE ANALYSIS")
                    .font(.headline.weight(.semibold))
                    .tracking(1.5)
                Spacer()
                Text("9 gates")
                    .foregroundStyle(.secondary)
            }

            let stages = stageItems
            ForEach(stages.indices, id: \.self) { i in
                StageCard(stage: stages[i])
            }
        }
    }

    private var mtfSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("MTF ALIGNMENT")
                    .font(.headline.weight(.semibold))
                    .tracking(1.5)
                Spacer()
                Text(api.execution?.mtf?.alignment ?? "—")
                    .foregroundStyle(.secondary)
            }

            let mtf = api.execution?.mtf
            MTFRow(name: "WEEKLY", value: mtf?.weekly?.direction ?? "—", detail: mtf?.weekly?.detail)
            MTFRow(name: "DAILY", value: mtf?.daily?.direction ?? "—", detail: mtf?.daily?.detail)
            MTFRow(name: "4H", value: mtf?.fourHour?.direction ?? "—", detail: mtf?.fourHour?.detail)
            MTFRow(name: "1H", value: mtf?.oneHour?.direction ?? "—", detail: mtf?.oneHour?.detail)
            MTFRow(name: "TIDE", value: mtf?.tide ?? "—", detail: nil)
            MTFRow(name: "WAVE", value: mtf?.wave ?? "—", detail: nil)
        }
        .padding(20)
        .card()
    }

    private var decisionSection: some View {
        let decision = api.status?.finalDecision
        return VStack(alignment: .leading, spacing: 12) {
            Text("DECISION DETAILS")
                .font(.headline.weight(.semibold))
                .tracking(1.5)

            ForEach(decision?.reasons ?? [], id: \.self) { reason in
                DetailBox(label: "REASON", text: reason)
            }

            ForEach(decision?.blockers ?? [], id: \.self) { blocker in
                DetailBox(label: "BLOCKER", text: blocker, danger: true)
            }
        }
        .padding(20)
        .card()
    }

    private var footer: some View {
        Text("iOS API client • Existing 9-stage engine remains authoritative")
            .font(.caption)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
    }

    private var progressText: String {
        let e = api.execution?.execution
        var count = 0
        if e?.setupDirection?.uppercased() != "WAIT" { count += 1 }
        if e?.confirmationStatus?.uppercased() == "CONFIRMED" { count += 1 }
        if api.status?.interday?.stage9?.uppercased() == "CONFIRMED" { count += 1 }
        if e?.triggerStatus?.uppercased() == "TRIGGERED" { count += 1 }
        return "\(count) / 4"
    }

    private var progressLine: some View {
        Rectangle()
            .fill(.white.opacity(0.18))
            .frame(height: 1)
    }

    private func progressNode(_ number: String, _ label: String) -> some View {
        VStack(spacing: 6) {
            Text(number)
                .frame(width: 42, height: 42)
                .background(.white.opacity(0.03))
                .clipShape(Circle())
                .overlay(Circle().stroke(.white.opacity(0.16), lineWidth: 1))
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    private func number(_ value: Double?) -> String {
        guard let value else { return "—" }
        return String(format: "%.2f", value)
    }

    private func startPolling() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { _ in
            Task { @MainActor in
                await api.refresh(index: selectedIndex)
            }
        }
    }

    private var stageItems: [StageItem] {
        let s = api.stages?.stages
        return [
            StageItem(number: 1, title: "Option Direction", value: s?.optionDirection?.direction ?? "WAIT", detail: s?.optionDirection?.confirmation ?? "—"),
            StageItem(number: 2, title: "OI / Price Action", value: s?.oiPriceAction?.decision ?? "WAIT", detail: s?.oiPriceAction?.detail ?? "—"),
            StageItem(number: 3, title: "Support / Resistance", value: s?.supportResistance?.decision ?? "WAIT", detail: s?.supportResistance?.detail ?? "—"),
            StageItem(number: 4, title: "Market Structure", value: s?.marketStructure?.decision ?? "WAIT", detail: s?.marketStructure?.detail ?? "—"),
            StageItem(number: 5, title: "Order Block", value: s?.orderBlock?.bias ?? "WAIT", detail: s?.orderBlock?.detail ?? "—"),
            StageItem(number: 6, title: "Chart Pattern", value: s?.chartPattern?.bias ?? "NEUTRAL", detail: s?.chartPattern?.detail ?? "—"),
            StageItem(number: 7, title: "Elliott Wave", value: s?.elliottWave?.bias ?? "WAIT", detail: s?.elliottWave?.detail ?? "—"),
            StageItem(number: 8, title: "Confirmation Candle", value: s?.confirmationCandle?.signal ?? "WAIT", detail: s?.confirmationCandle?.detail ?? "—"),
            StageItem(number: 9, title: "Fibonacci Retracement", value: s?.fibonacci?.signal ?? "WAIT", detail: s?.fibonacci?.detail ?? "—")
        ]
    }
}

struct StageItem {
    let number: Int
    let title: String
    let value: String
    let detail: String
}

struct SummaryCell: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.caption).foregroundStyle(.secondary)
            Text(value)
                .font(.headline.weight(.semibold))
                .foregroundStyle(value.contains("BEAR") ? .red : value.contains("BULL") ? .mint : .white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .card()
    }
}

struct MetricCell: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title).font(.caption).foregroundStyle(.secondary)
            Text(value).font(.title3.weight(.semibold))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .card()
    }
}

struct DetailBox: View {
    let label: String
    let text: String
    var danger = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label).font(.caption.weight(.semibold)).foregroundStyle(.secondary)
            Text(text).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(.white.opacity(0.02))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(danger ? Color.red.opacity(0.45) : Color.white.opacity(0.10), lineWidth: 1)
        )
    }
}

extension View {
    func card() -> some View {
        self
            .background(Color(red: 0.035, green: 0.10, blue: 0.095))
            .clipShape(RoundedRectangle(cornerRadius: 22))
            .overlay(
                RoundedRectangle(cornerRadius: 22)
                    .stroke(Color.white.opacity(0.10), lineWidth: 1)
            )
    }
}
