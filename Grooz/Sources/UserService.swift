import Foundation
import Alamofire

/// Fetches random users from the public randomuser.me API using Alamofire.
enum UserService {
    // Decoding shapes matching the randomuser.me JSON response.
    private struct Response: Decodable {
        let results: [Result]
    }

    private struct Result: Decodable {
        struct Name: Decodable { let first: String; let last: String }
        let name: Name
        let email: String
    }

    static func fetchUsers(count: Int = 10) async throws -> [User] {
        let url = "https://randomuser.me/api/?results=\(count)"
        let response = try await AF.request(url)
            .serializingDecodable(Response.self)
            .value

        return response.results.map {
            User(email: $0.email, firstName: $0.name.first, lastName: $0.name.last)
        }
    }
}
