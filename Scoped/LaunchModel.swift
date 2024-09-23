import Foundation

struct Launch: Codable, Identifiable, Equatable {
    let id: String
    let name: String
    let date_utc: String
    let success: Bool?
    let details: String?
    let links: LaunchLinks
    
    static func == (lhs: Launch, rhs: Launch) -> Bool {
        lhs.id == rhs.id
    }
}

struct LaunchLinks: Codable, Equatable {
    let patch: PatchLinks
    let webcast: String?
}

struct PatchLinks: Codable, Equatable {
    let small: String?
    let large: String?
}