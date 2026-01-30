import SwiftUI

struct RecentSearchesView: View {
    let searches: [String]
    let onSelect: (String) -> Void
    let onClear: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent Searches")
                    .font(.headline)
                Spacer()
                Button("Clear") {
                    onClear()
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
            .padding(.horizontal)

            VStack(spacing: 0) {
                ForEach(searches, id: \.self) { search in
                    Button {
                        onSelect(search)
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "clock")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            Text(search)
                                .font(.subheadline)
                                .foregroundStyle(.primary)

                            Spacer()

                            Image(systemName: "arrow.up.left")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)

                    if search != searches.last {
                        Divider()
                            .padding(.leading, 44)
                    }
                }
            }
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal)
        }
    }
}

#Preview {
    RecentSearchesView(
        searches: ["drake", "blinding lights", "taylor swift"],
        onSelect: { _ in },
        onClear: {}
    )
}
