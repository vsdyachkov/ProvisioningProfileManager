import SwiftUI

struct ContentView: View {
    @State private var store = ProfileStore()
    @State private var searchText = ""
    @State private var selection = Set<ProvisioningProfile.ID>()
    @State private var sortOrder = [KeyPathComparator<ProvisioningProfile>(\.appName)]

    private var visibleProfiles: [ProvisioningProfile] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        let profiles = query.isEmpty ? store.profiles : store.profiles.filter { $0.matches(query) }
        return profiles.sorted(using: sortOrder)
    }

    var body: some View {
        VStack(spacing: 0) {
            Table(visibleProfiles, selection: $selection, sortOrder: $sortOrder) {
                TableColumn("App", value: \.appName)
                TableColumn("Profile Name", value: \.name)
                TableColumn("Bundle Identifier", value: \.bundleIdentifier)
                TableColumn("Created", value: \.creationDate) { profile in
                    Text(profile.createdText)
                }
            }

            Divider()

            HStack(spacing: 8) {
                if store.isLoading {
                    ProgressView()
                        .controlSize(.small)
                    Text("Loading")
                } else {
                    Text("\(visibleProfiles.count) of \(store.profiles.count) profiles")
                }

                if let message = store.errorMessage {
                    Divider()
                    Text(message)
                        .foregroundStyle(.red)
                        .lineLimit(1)
                }

                Spacer()
            }
            .font(.footnote)
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
        }
        .searchable(text: $searchText)
        .toolbar {
            Button {
                store.reload()
            } label: {
                Label("Reload", systemImage: "arrow.clockwise")
            }
            .disabled(store.isLoading)

            Button(role: .destructive) {
                store.delete(selection)
                selection.removeAll()
            } label: {
                Label("Delete", systemImage: "trash")
            }
            .disabled(selection.isEmpty)
            .keyboardShortcut(.delete, modifiers: [])
        }
        .task {
            store.reloadIfNeeded()
        }
    }
}
