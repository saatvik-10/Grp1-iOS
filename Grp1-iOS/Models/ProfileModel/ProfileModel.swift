import UIKit

enum UserLevel: String {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"

    var color: UIColor {
        switch self {
        case .beginner:
            return .systemGreen
        case .intermediate:
            return .systemYellow
        case .advanced:
            return .systemRed
        }
    }
}

struct ProgressSectionModel {
    let progressPercentage: Double
    let progressLevel: Int
    let requirementNextLevel: String
}

struct InterestsSectionModel {
    let interests: [String]
}

struct BookmarksSectionModel {
    let totalBookmarks: Int
    let totalFolders: Int
}

enum ProfileSection {
    case progress(ProgressSectionModel)
    case interests(InterestsSectionModel)
    case bookmarks(BookmarksSectionModel)
    case about
    case logout
}

enum InterestType {
    case domain
//    case company
    case preference

    var title: String {
        switch self {
        case .domain: return "Add New Domain"
//        case .company: return "Add New Company"
        case .preference: return "Add New Preferences"
        }
    }

    var searchPlaceholder: String {
        switch self {
        case .domain: return "Search Domains"
//        case .company: return "Search Companies"
        case .preference: return "Search Preferences"
        }
    }
}

struct InterestModel {
    let title: String
    let subtitle: String?
    let icon: String?
}

struct ProfileView {
    let image: String
    let name: String
    let userName: String
}

enum Gender: String {
    case male = "Male"
    case female = "Female"
}

struct UserProfile {
    let image: String
    let name: String
    let phone: String
    let email: String
    let level: UserLevel
    let dob: String
    let gender: Gender
}

struct BookmarkItem {
    let icon: UIImage
    let id: String
    let title: String
}

struct OverallProgress {
    let progressPercentage: Double
    let quizCompletionNumber: String
    let levelNumber: Int
}

struct ProgressStats {
    let dayStreak: Int
    let totalXP: Int
    let accuracyPercentage: Int
}

struct Quiz {
    let title: String
    let date: String
    let accuracy: Int
}
