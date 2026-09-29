import SwiftUI
import Foundation

struct ExecutionView: View {
    let response: ExecutionResponse

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("EXECUTION")
                .font(.title3.weight(.bold))

            ExecutionStatusRow(title: "Phase", value: response.execution.executionPhase)
            ExecutionStatusRow(title: "Direction", value: response.execution.direction)
            ExecutionStatusRow(title: "Setup", value: response.execution.setupDirection)
            ExecutionStatusRow(title: "Entry", value: number(response.execution.entry))
            ExecutionStatusRow(title: "Trigger", value: number(response.execution.trigger))
            ExecutionStatusRow(title: "Stop Loss", value: number(response.execution.stop))
            ExecutionStatusRow(title: "2R Target", value: number(response.execution.target2R))
            ExecutionStatusRow(title: "RR", value: number(response.execution.rr))

            Divider()

            Text("MTF ALIGNMENT")
                .font(.headline)

            MTFRow(name: "Weekly", data: response.mtf.weekly)
            MTFRow(name: "Daily", data: response.mtf.daily)
            MTFRow(name: "4H", data: response.mtf.fourHour)
            MTFRow(name: "1H", data: response.mtf.oneHour)

            if let alignment = response.mtf.alignment {
                ExecutionStatusRow(title: "Alignment", value: alignment)
            }

            if let details = response.execution.detail {
                ForEach(details, id: \.self) {
                    Text("â€¢ \($0)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private func number(_ value: Double?) -> String {
        guard let value else { return "WAIT" }
        return String(format: "%.2f", value)
    }
}

struct ExecutionStatusRow: View {
    let title: String
    let value: String?

    var body: some View {
        HStack {
            Text(title)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value ?? "WAIT")
                .fontWeight(.semibold)
        }
        .font(.subheadline)
    }
}

struct MTFRow: View {
    let name: String
    let data: MTFTimeframe?

    var body: some View {
        HStack {
            Text(name)
            Spacer()
            Text(data?.direction ?? "WAIT")
                .fontWeight(.semibold)
        }
        .font(.subheadline)
    }
}
