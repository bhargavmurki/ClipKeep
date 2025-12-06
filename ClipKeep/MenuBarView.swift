import SwiftUI
import SwiftData
import AppKit

struct MenuBarView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [SortDescriptor(\Item.createdAt, order: .reverse)]) private var items: [Item]

    @State private var searchText = ""
    @State private var hoverID: PersistentIdentifier?

    private let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()

    private var filteredItems: [Item] {
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return items
        }
        return items.filter { $0.content.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        VStack(spacing: 12) {
            header
            searchBar
            content
            footer
        }
        .padding(20)
        .frame(width: 360)
        .frame(maxHeight: 1000, alignment: .top)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.15), radius: 18, x: 0, y: 12)
        )
        .animation(.easeInOut(duration: 0.18), value: filteredItems.count)
    }

    private var header: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Text("ClipKeep")
                    .font(.system(.title3, design: .rounded, weight: .semibold))
                Text("Fast, elegant clipboard access from the menu bar.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Circle()
                .fill(LinearGradient(colors: [.teal, .blue], startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 36, height: 36)
                .overlay(
                    Image(systemName: "sparkles")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                )
        }
    }

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            TextField("Search clips", text: $searchText)
                .textFieldStyle(.plain)
                .onSubmit { searchText = searchText.trimmingCharacters(in: .whitespacesAndNewlines) }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.thinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(Color.primary.opacity(0.06))
        )
    }

    private var content: some View {
        Group {
            if filteredItems.isEmpty {
                emptyState
            } else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(filteredItems) { item in
                            MenuBarRow(item: item,
                                       isHovered: hoverID == item.persistentModelID,
                                       subtitle: formatter.string(from: item.createdAt),
                                       source: item.source,
                                       copyCount: item.copyCount,
                                       copyAction: { copy(item) })
                            .onHover { hovering in
                                hoverID = hovering ? item.persistentModelID : nil
                            }
                            .contextMenu {
                                Button("Copy") { copy(item) }
                                Button("Delete", role: .destructive) { delete(item) }
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
                .scrollIndicators(.hidden)
            }
        }
        .frame(maxHeight: 560)
    }

    private var footer: some View {
        HStack {
            Button(action: clearAll) {
                Label("Clear All", systemImage: "trash")
                    .font(.subheadline.weight(.semibold))
            }
            .buttonStyle(StrokeCapsuleStyle(color: .red.opacity(0.85)))
            .disabled(items.isEmpty)
            Spacer()
            Button(action: { NSApplication.shared.terminate(nil) }) {
                Label("Quit", systemImage: "power")
                    .font(.subheadline.weight(.semibold))
            }
            .buttonStyle(StrokeCapsuleStyle(color: .primary.opacity(0.12)))
        }
        .padding(.top, 2)
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "rectangle.on.rectangle.slash")
                .font(.system(size: 30, weight: .semibold))
                .foregroundStyle(.secondary)
                .padding(.bottom, 2)
            Text("Clipboard is clear")
                .font(.headline)
            Text("Copy something new and it will appear here instantly.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.vertical, 32)
    }

    private func copy(_ item: Item) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(item.content, forType: .string)
    }

    private func delete(_ item: Item) {
        withAnimation(.spring(response: 0.28, dampingFraction: 0.9)) {
            modelContext.delete(item)
            try? modelContext.save()
        }
    }

    private func clearAll() {
        guard !items.isEmpty else { return }
        withAnimation(.easeInOut(duration: 0.2)) {
            items.forEach { modelContext.delete($0) }
            try? modelContext.save()
        }
    }
}

private struct MenuBarRow: View {
    let item: Item
    let isHovered: Bool
    let subtitle: String
    let source: String
    let copyCount: Int
    let copyAction: () -> Void

    var body: some View {
        Button(action: copyAction) {
            VStack(alignment: .leading, spacing: 4) {
                Text(item.content.trimmingCharacters(in: .whitespacesAndNewlines))
                    .font(.system(.body, design: .rounded))
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentTransition(.opacity)

                if isHovered {
                    HStack(spacing: 8) {
                        Label(source.isEmpty ? "Clipboard" : source, systemImage: "rectangle.and.pencil.and.ellipsis")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                        Circle()
                            .fill(Color.secondary.opacity(0.4))
                            .frame(width: 4, height: 4)
                        Label(subtitle, systemImage: "clock")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                        Spacer()
                        Label("\(copyCount)", systemImage: "arrow.triangle.2.circlepath")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(isHovered ? Color.primary.opacity(0.08) : Color.primary.opacity(0.03))
            )
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.15), value: isHovered)
    }
}

private struct StrokeCapsuleStyle: ButtonStyle {
    let color: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(configuration.isPressed ? color.opacity(0.7) : color)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                Capsule(style: .continuous)
                    .strokeBorder(color.opacity(configuration.isPressed ? 0.35 : 0.6), lineWidth: 1.2)
                    .background(
                        Capsule(style: .continuous)
                            .fill(color.opacity(configuration.isPressed ? 0.08 : 0.12))
                    )
            )
            .animation(.easeInOut(duration: 0.12), value: configuration.isPressed)
    }
}
