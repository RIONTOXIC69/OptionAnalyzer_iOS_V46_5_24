import SwiftUI

struct StageCard: View {
    let stage: StageItem

    private var accent: Color {
        let v = stage.value.uppercased()
        if v.contains("BEAR") || v.contains("SELL") || v.contains("UNWIND") {
            return .red
        }
        if v.contains("BULL") || v.contains("BUY") || v.contains("BUILD") || v.contains("CONTINUATION") {
            return .mint
        }
        return .white.opacity(0.9)
    }

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Text("\(stage.number)")
                .font(.headline)
                .frame(width: 44, height: 44)
                .background(.white.opacity(0.04))
                .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 5) {
                Text("Stage \(stage.number) · \(stage.title)")
                    .font(.headline.weight(.semibold))

                Text(stage.value)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(accent)

                Text(stage.detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
        }
        .padding(18)
        .background(Color(red: 0.03, green: 0.09, blue: 0.085))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(accent.opacity(0.35), lineWidth: 1)
        )
    }
}
