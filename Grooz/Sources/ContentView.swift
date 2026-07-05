import SwiftUI
import Collections

public struct ContentView: View {
    public init() {}

    @State private var users: [User] = []
    @State private var isLoading = false

    private let store = UserStore()

    public var body: some View {
        NavigationStack {
            List(users) { user in
                VStack(alignment: .leading, spacing: 2) {
                    Text(user.fullName).font(.headline)
                    Text(user.email).font(.caption).foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Users")
            .toolbar {
                Button(action: refresh) {
                    if isLoading { ProgressView() } else { Image(systemName: "arrow.clockwise") }
                }
                .disabled(isLoading)
            }
            .task {
                // Show persisted users immediately on launch.
                users = store.load()
                if users.isEmpty { refresh() }
            }
        }
    }

    private func refresh() {
        isLoading = true
        Task {
            defer { isLoading = false }
            guard let fetched = try? await UserService.fetchUsers() else { return }

            // Dedupe by email while preserving fetch order (swift-collections).
            let deduped = Array(OrderedSet(fetched))

            store.replaceAll(deduped)      // persist with GRDB
            users = store.load()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
