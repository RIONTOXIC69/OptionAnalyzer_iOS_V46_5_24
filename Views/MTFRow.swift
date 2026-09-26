import SwiftUI

struct MTFRow: View {
    let name: String
    let value: String
    let detail: String?

    var body: some View {
        HStack(spacing: 12) {
            Text(name)
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)
                .frame(width: 65, alignment: .leading)

            Text(value)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(value.uppercased().contains("BEAR") ? .red :
                                 value.uppercased().contains("BULL") ? .mint : .white)

            Spacer()

            if let detail {
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .padding(14)
        .background(.white.opacity(0.018))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(.white.opacity(0.08), lineWidth: 1)
        )
    }
}
