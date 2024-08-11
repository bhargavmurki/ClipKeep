import SwiftUI

struct ContentView: View {
    @State private var clipboardHistoryState: [String] = []
    @State private var searchText = ""
    @State private var isShowingConfirmation = false
    @State private var selectedClipboardItem: String? = nil // State variable to track the selected item

    var body: some View {
        NavigationView {
            HStack(spacing: 0) {
                VStack(spacing: 0) {
                    searchBar
                    
                    List {
                        ForEach(filteredClipboardHistory.indices, id: \.self) { index in
                            Button(action: {
                                selectedClipboardItem = filteredClipboardHistory[index]
                            }) {
                                ClipboardItemView(text: filteredClipboardHistory[index])
                            }
                            .buttonStyle(PlainButtonStyle()) // So the button doesn’t look like a button
                            .background(selectedClipboardItem == filteredClipboardHistory[index] ? Color.gray.opacity(0.2) : Color.clear) // Highlight selected item
                        }
                        .onDelete(perform: deleteItems)
                    }
                    .listStyle(PlainListStyle())
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Divider() // Adds a divider between the list and the preview
                
                if let selectedItem = selectedClipboardItem {
                    VStack(alignment: .leading) {
                        Text("Preview")
                            .font(.headline)
                            .padding([.top, .horizontal])
                        
                        ScrollView {
                            TextEditor(text: .constant(selectedItem))
                                .padding()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(Color(platformBackgroundColor)) // Match the background with the rest of the app
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
        .onAppear {
            loadClipboardHistory()
            updateHistory()
            NotificationCenter.default.addObserver(forName: NSNotification.Name("ClipboardHistoryUpdated"), object: nil, queue: .main) { _ in
                updateHistory()
            }
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
            Color(platformBackgroundColor) // Using a cross-platform color
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

    private var filteredClipboardHistory: [String] {
        if searchText.isEmpty {
            return clipboardHistoryState
        } else {
            return clipboardHistoryState.filter { $0.localizedCaseInsensitiveContains(searchText) }
        }
    }

    private func deleteItems(at offsets: IndexSet) {
        clipboardHistory.remove(atOffsets: offsets)
        saveClipboardHistory()
        updateHistory()
    }

    private func updateHistory() {
        DispatchQueue.main.async {
            self.clipboardHistoryState = clipboardHistory
        }
    }

    private func loadClipboardHistory() {
        clipboardHistory = UserDefaults.standard.stringArray(forKey: "clipboardHistory") ?? []
        clipboardHistoryState = clipboardHistory
    }

    private func clearClipboardHistory() {
        clipboardHistory.removeAll()
        saveClipboardHistory()
        updateHistory()
    }

    private func saveClipboardHistory() {
        UserDefaults.standard.set(clipboardHistory, forKey: "clipboardHistory")
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
