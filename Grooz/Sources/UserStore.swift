import Foundation
import GRDB

/// Local SQLite persistence for `User`, backed by GRDB.
final class UserStore {
    private let dbQueue: DatabaseQueue

    /// Uses the on-disk app database by default; tests can inject an in-memory queue.
    init(dbQueue: DatabaseQueue = UserStore.defaultQueue()) {
        self.dbQueue = dbQueue
        try! migrate()
    }

    private static func defaultQueue() -> DatabaseQueue {
        let url = try! FileManager.default
            .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("grooz.sqlite")
        return try! DatabaseQueue(path: url.path)
    }

    private func migrate() throws {
        try dbQueue.write { db in
            try db.create(table: User.databaseTableName, ifNotExists: true) { t in
                t.primaryKey("email", .text)
                t.column("firstName", .text).notNull()
                t.column("lastName", .text).notNull()
            }
        }
    }

    func load() -> [User] {
        (try? dbQueue.read { db in
            try User.order(Column("firstName")).fetchAll(db)
        }) ?? []
    }

    func replaceAll(_ users: [User]) {
        try? dbQueue.write { db in
            try User.deleteAll(db)
            // Upsert so duplicate emails in a batch overwrite (last write wins)
            // instead of throwing on the primary-key conflict.
            try users.forEach { try $0.insert(db, onConflict: .replace) }
        }
    }
}
