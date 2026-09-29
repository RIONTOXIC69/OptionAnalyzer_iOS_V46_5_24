import SwiftUI

struct StageAnalysisView: View {
    let stages: StageBundle?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("9-STAGE ANALYSIS")
                .font(.headline)

            stageRow(
                1,
                "Option Direction",
                stages?.optionDirection.direction,
                stages?.optionDirection.confirmation
            )

            stageRow(
                2,
                "OI / Price Action",
                stages?.oiPriceAction.bias,
                stages?.oiPriceAction.detail
            )

            stageRow(
                3,
                "Support / Resistance",
                stages?.supportResistance.decision,
                stages?.supportResistance.detail
            )

            stageRow(
                4,
                "Market Structure",
                stages?.marketStructure.decision,
                stages?.marketStructure.trend
            )

            stageRow(
                5,
                "Order Block",
                stages?.orderBlock.bias,
                stages?.orderBlock.type
            )

            stageRow(
                6,
                "Chart Pattern",
                stages?.chartPattern.bias,
                stages?.chartPattern.pattern
            )

            stageRow(
                7,
                "Elliott Wave",
                stages?.elliottWave.bias,
                stages?.elliottWave.wave
            )

            stageRow(
                8,
                "Confirmation Candle",
                stages?.confirmationCandle.signal,
                stages?.confirmationCandle.detail
            )

            stageRow(
                9,
                "Fibonacci Retracement",
                stages?.fibonacci.signal,
                stages?.fibonacci.detail
            )
        }
        .padding()
        .background(
            .thinMaterial,
            in: RoundedRectangle(cornerRadius: 16)
        )
    }

    private func stageRow(
        _ number: Int,
        _ title: String,
        _ value: String?,
        _ detail: String?
    ) -> some View {
        HStack(alignment: .top) {
            Text("\(number)")
                .bold()
                .frame(width: 25, height: 25)
                .background(
                    Color.teal.opacity(0.12),
                    in: Circle()
                )

            VStack(alignment: .leading) {
                HStack {
                    Text(title)
                        .font(.subheadline.bold())

                    Spacer()

                    Text(value ?? "WAIT")
                        .font(.caption.bold())
                }

                if let detail {
                    Text(detail)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(3)
                }
            }
        }
        .padding(.vertical, 3)
    }
}