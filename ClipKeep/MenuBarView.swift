import SwiftUI
import SwiftData
import AppKit

struct MenuBarView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [SortDescriptor(\Item.createdAt, order: .reverse)]) private var items: [Item]

    @State private var searchText = ""
    @State private var hoverID: PersistentIdentifier?
    @FocusState private var isSearchFocused: Bool

    private let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()

    private var filteredItems: [Item] {
        let terms = searchText
            .split(whereSeparator: { $0.isWhitespace })
            .map { $0.lowercased() }

        guard !terms.isEmpty else { return items }

        return items.filter { item in
            guard item.kind == .text, let content = item.content?.lowercased() else { return false }
            return terms.allSatisfy { content.contains($0) }
        }
    }

    var body: some View {
        VStack(spacing: 14) {
            header
            searchBar
            content
            footer
        }
        .padding(20)
        .frame(width: 380)
        .frame(maxHeight: 900, alignment: .top)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial)
                .shadow(color: Color.black.opacity(0.12), radius: 18, x: 0, y: 10)
        )
        .animation(.easeInOut(duration: 0.18), value: filteredItems.count)
    }

    private var header: some View {
        HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                Text("ClipKeep")
                    .font(.system(.title3, design: .rounded, weight: .semibold))
                Text("Menu bar clipboard. Cmd+Shift+V")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Label("New", systemImage: "bolt.fill")
                .font(.caption.weight(.semibold))
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(
                    Capsule(style: .continuous)
                        .fill(Color.accentColor.opacity(0.12))
                )
                .foregroundStyle(Color.accentColor)
        }
        .padding(.horizontal, 2)
    }

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            TextField("Search clips", text: $searchText)
                .textFieldStyle(.plain)
                .focused($isSearchFocused)
                .onSubmit { searchText = searchText.trimmingCharacters(in: .whitespacesAndNewlines) }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.primary.opacity(0.04))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(Color.primary.opacity(0.08))
        )
        .onAppear {
            DispatchQueue.main.async {
                isSearchFocused = true
            }
        }
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
                                       image: thumbnail(for: item),
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
        .frame(maxHeight: 640)
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
        if item.kind == .image, let data = item.imageData {
            let pasteboardType = item.imagePasteboardType ?? .png
            NSPasteboard.general.setData(data, forType: pasteboardType)
        } else if let content = item.content {
            NSPasteboard.general.setString(content, forType: .string)
        }
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

    private func thumbnail(for item: Item) -> NSImage? {
        guard item.kind == .image, let data = item.imageData else { return nil }
        return NSImage(data: data)
    }
}

private struct MenuBarRow: View {
    let item: Item
    let isHovered: Bool
    let subtitle: String
    let source: String
    let copyCount: Int
    let image: NSImage?
    let copyAction: () -> Void

    var body: some View {
        Button(action: copyAction) {
            VStack(alignment: .leading, spacing: 4) {
                if let image {
                    HStack(spacing: 10) {
                        Image(nsImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 42, height: 32)
                            .clipped()
                            .cornerRadius(6)
                        Text("Image")
                            .font(.system(.body, design: .rounded))
                            .lineLimit(1)
                            .foregroundStyle(.primary)
                        Spacer()
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                } else {
                    Text(item.content?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "")
                        .font(.system(.body, design: .rounded))
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentTransition(.opacity)
                }

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
            .padding(.vertical, 9)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color.primary.opacity(isHovered ? 0.09 : 0.04))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(Color.primary.opacity(isHovered ? 0.14 : 0.06), lineWidth: 0.8)
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
