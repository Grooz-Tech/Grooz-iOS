import Foundation
import GRDB

/// A user shown in the list, persisted with GRDB and decoded from randomuser.me.
struct User: Identifiable, Hashable, Codable, FetchableRecord, PersistableRecord {
    var id: String { email }
    var email: String
    var firstName: String
    var lastName: String

    var fullName: String { "\(firstName) \(lastName)" }

    static let databaseTableName = "user"
}
