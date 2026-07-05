import Foundation
import XCTest
import GRDB
import Collections
@testable import Grooz

final class UserTests: XCTestCase {
    func test_id_isEmail() {
        let user = User(email: "a@example.com", firstName: "Ada", lastName: "Lovelace")
        XCTAssertEqual(user.id, "a@example.com")
    }

    func test_fullName_joinsFirstAndLast() {
        let user = User(email: "a@example.com", firstName: "Ada", lastName: "Lovelace")
        XCTAssertEqual(user.fullName, "Ada Lovelace")
    }

    func test_decodesFromJSON() throws {
        let json = #"{"email":"a@example.com","firstName":"Ada","lastName":"Lovelace"}"#
        let user = try JSONDecoder().decode(User.self, from: Data(json.utf8))
        XCTAssertEqual(user, User(email: "a@example.com", firstName: "Ada", lastName: "Lovelace"))
    }
}

final class UserDedupeTests: XCTestCase {
    // Mirrors ContentView's OrderedSet dedupe: drop duplicates, preserve first-seen order.
    func test_orderedSet_dropsDuplicatesPreservingOrder() {
        let a = User(email: "a@example.com", firstName: "Ada", lastName: "L")
        let b = User(email: "b@example.com", firstName: "Bob", lastName: "M")
        let aDuplicate = a

        let deduped = Array(OrderedSet([a, b, aDuplicate]))

        XCTAssertEqual(deduped, [a, b])
    }
}

final class UserStoreTests: XCTestCase {
    private func makeStore() throws -> UserStore {
        // In-memory DB — isolated per test, no disk, no shared state.
        UserStore(dbQueue: try DatabaseQueue())
    }

    func test_load_isEmptyInitially() throws {
        let store = try makeStore()
        XCTAssertTrue(store.load().isEmpty)
    }

    func test_replaceAll_thenLoad_roundtrips() throws {
        let store = try makeStore()
        let users = [
            User(email: "ada@example.com", firstName: "Ada", lastName: "Lovelace"),
            User(email: "bob@example.com", firstName: "Bob", lastName: "Marley"),
        ]

        store.replaceAll(users)

        XCTAssertEqual(Set(store.load()), Set(users))
    }

    func test_load_isOrderedByFirstName() throws {
        let store = try makeStore()
        store.replaceAll([
            User(email: "z@example.com", firstName: "Zoe", lastName: "Z"),
            User(email: "a@example.com", firstName: "Ada", lastName: "A"),
            User(email: "m@example.com", firstName: "Mia", lastName: "M"),
        ])

        XCTAssertEqual(store.load().map(\.firstName), ["Ada", "Mia", "Zoe"])
    }

    func test_replaceAll_replacesRatherThanAppends() throws {
        let store = try makeStore()
        store.replaceAll([User(email: "old@example.com", firstName: "Old", lastName: "User")])

        store.replaceAll([User(email: "new@example.com", firstName: "New", lastName: "User")])

        XCTAssertEqual(store.load().map(\.email), ["new@example.com"])
    }

    func test_replaceAll_dedupesByEmailPrimaryKey() throws {
        let store = try makeStore()
        // Same email (primary key), different name — last write wins, one row.
        store.replaceAll([
            User(email: "dup@example.com", firstName: "First", lastName: "Write"),
            User(email: "dup@example.com", firstName: "Second", lastName: "Write"),
        ])

        let loaded = store.load()
        XCTAssertEqual(loaded.count, 1)
        XCTAssertEqual(loaded.first?.firstName, "Second")
    }
}
