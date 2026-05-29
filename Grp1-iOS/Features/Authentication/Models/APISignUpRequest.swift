// import Foundation
//
//// MARK: - Enums
// enum APIGender: String, Encodable {
//    case male
//    case female
//    case other
//    
//    var rawValue: String {
//        switch self {
//        case .male: return "male"
//        case .female: return "female"
//        case .other: return "other"
//        }
//    }
// }
//
// enum APILevel: String, Encodable {
//    case beginner
//    case intermediate
//    case advanced
//    
//    var rawValue: String {
//        switch self {
//        case .beginner: return "BEGINNER"
//        case .intermediate: return "INTERMEDIATE"
//        case .advanced: return "ADVANCE"
//        }
//    }
// }
//
//// MARK: - Request Models
// struct APISignUpRequest: Encodable {
//    let name: String
//    let email: String
//    let password: String
//    let phone: String
//    let level: APILevel
//    let dob: String
//    let gender: APIGender
//    let hasOnboarding: Bool
//    let profileImageUrl: String?
// }
//
// struct APISignInRequest: Encodable {
//    let email: String
//    let password: String
// }
//
//// MARK: - Response Models
// struct APISignInResponse: Decodable {
//    let token: String
//    let userId: String?
//    let email: String?
// }
