import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [SortDescriptor(\Item.createdAt, order: .reverse)]) private var items: [Item]

    @State private var searchText = ""
    @State private var isShowingConfirmation = false
    @State private var selectedItem: Item?

    var body: some View {
        NavigationView {
            HStack(spacing: 0) {
                VStack(spacing: 0) {
                    searchBar

                    List {
                        ForEach(filteredItems) { item in
                            Button {
                                selectedItem = item
                            } label: {
                                ClipboardItemView(text: item.content)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .background(selectedItem?.persistentModelID == item.persistentModelID ? Color.gray.opacity(0.2) : Color.clear)
                        }
                        .onDelete(perform: deleteItems)
                    }
                    .listStyle(PlainListStyle())
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Divider()

                if let selectedItem = selectedItem {
                    VStack(alignment: .leading) {
                        Text("Preview")
                            .font(.headline)
                            .padding([.top, .horizontal])

                        ScrollView {
                            TextEditor(text: .constant(selectedItem.content))
                                .padding()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(Color(platformBackgroundColor))
                                .cornerRadius(8)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .frame(maxWidth: .infinity)
                } else {
                    VStack {
                        Text("No Selection")
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .navigationTitle("Clipboard History")
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    clearButton
                }
            }
        }
        .alert(isPresented: $isShowingConfirmation) {
            Alert(
                title: Text("Clear History"),
                message: Text("Are you sure you want to clear all clipboard history?"),
                primaryButton: .destructive(Text("Clear")) {
                    clearClipboardHistory()
                },
                secondaryButton: .cancel()
            )
        }
    }

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            TextField("Search", text: $searchText)
        }
        .padding()
        .background(
            Color(platformBackgroundColor)
        )
    }

    #if os(macOS)
    private let platformBackgroundColor = NSColor.controlBackgroundColor
    #elseif os(iOS)
    private let platformBackgroundColor = UIColor.secondarySystemBackground
    #endif

    private var clearButton: some View {
        Button(action: {
            isShowingConfirmation = true
        }) {
            Image(systemName: "trash")
        }
    }

    private var filteredItems: [Item] {
        if searchText.isEmpty {
            return items
        } else {
            return items.filter { $0.content.localizedCaseInsensitiveContains(searchText) }
        }
    }

    private func deleteItems(at offsets: IndexSet) {
        let targets = offsets.map { filteredItems[$0] }
        targets.forEach { modelContext.delete($0) }
        try? modelContext.save()

        if let selectedItem, targets.contains(where: { $0.persistentModelID == selectedItem.persistentModelID }) {
            self.selectedItem = nil
        }
    }

    private func clearClipboardHistory() {
        items.forEach { modelContext.delete($0) }
        try? modelContext.save()
        selectedItem = nil
    }
}

struct ClipboardItemView: View {
    let text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(text)
                .lineLimit(2)

            HStack {
                Text(String(text.prefix(50)))
                    .font(.caption)
                    .foregroundColor(.gray)
                Spacer()
                Button(action: {
                    #if os(iOS)
                    UIPasteboard.general.string = text
                    #elseif os(macOS)
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(text, forType: .string)
                    #endif
                }) {
                    Image(systemName: "doc.on.doc")
                        .foregroundColor(.blue)
                }
            }
        }
        .padding(.vertical, 8)
    }
}
