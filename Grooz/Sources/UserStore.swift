import Foundation
import GRDB

/// Local SQLite persistence for `User`, backed by GRDB.
final class UserStore {
    private let dbQueue: DatabaseQueue

    init() {
        let url = try! FileManager.default
            .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("grooz.sqlite")

        dbQueue = try! DatabaseQueue(path: url.path)
        try! migrate()
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
            for user in users {
                try user.insert(db)
            }
        }
    }
}
