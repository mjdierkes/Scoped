import Foundation

struct Launch: Codable, Identifiable, Equatable {
    let id: String
    let name: String
    let date_utc: String
    let success: Bool?
    let details: String?
    let links: LaunchLinks
    let rocket: String
    let upcoming: Bool
    
    var launchDate: Date? {
        ISO8601DateFormatter().date(from: date_utc)
    }
    
    var daysUntilLaunch: Int {
        guard let launchDate = launchDate else { return 0 }
        return Int(ObjectiveCUtilities.days(untilLaunch: launchDate))
    }
    
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

struct Rocket: Codable, Identifiable {
    let id: String
    let name: String
    let type: String
    let description: String
}
