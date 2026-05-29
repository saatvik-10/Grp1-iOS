// import Foundation

// class OnboardingAPIService {
//     static let shared = OnboardingAPIService()
//     private init() {}

//     // ✅ Use APIService's baseURL instead of hardcoded localhost
//     private var baseURL: String {
//         return APIService.shared.baseURL
//     }

//     /// Save the user's level to the backend (updates the User record)
//     func saveLevel(_ level: String, token: String, completion: @escaping (Bool) -> Void) {
//         let levelEnum: String
//         switch level.lowercased() {
//         case "beginner":    levelEnum = "BEGINNER"
//         case "intermediate": levelEnum = "INTERMEDIATE"
//         case "advanced":    levelEnum = "ADVANCE"
//         default:            levelEnum = "BEGINNER"
//         }

//         guard let url = URL(string: "\(baseURL)api/profile/level") else {
//             print("❌ Invalid URL for saveLevel")
//             completion(false)
//             return
//         }

//         print("📤 Saving level: \(levelEnum) to \(url.absoluteString)")

//         var request = URLRequest(url: url)
//         request.httpMethod = "PATCH"
//         request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//         request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
//         request.httpBody = try? JSONSerialization.data(withJSONObject: ["level": levelEnum])

//         URLSession.shared.dataTask(with: request) { data, response, error in
//             if let error = error {
//                 print("❌ Level save error: \(error)")
//             }

//             let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
//             let success = statusCode == 200

//             print("📊 Level save status: \(statusCode)")
//             if success {
//                 print("✅ Level saved successfully")
//             } else {
//                 print("❌ Level save failed")
//             }

//             DispatchQueue.main.async { completion(success) }
//         }.resume()
//     }

//     /// Save a single interest (domain or preference) to the backend
//     func saveInterest(interestId: String, token: String, completion: @escaping (Bool) -> Void) {
//         guard let url = URL(string: "\(baseURL)api/profile/interests") else {
//             print("❌ Invalid URL for saveInterest")
//             completion(false)
//             return
//         }

//         print("📤 Saving interest: \(interestId) to \(url.absoluteString)")

//         var request = URLRequest(url: url)
//         request.httpMethod = "POST"
//         request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//         request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
//         request.httpBody = try? JSONSerialization.data(withJSONObject: ["interestId": interestId])

//         URLSession.shared.dataTask(with: request) { data, response, error in
//             if let error = error {
//                 print("❌ Interest save error: \(error)")
//             }

//             let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
//             let success = statusCode == 201 || statusCode == 200

//             print("📊 Interest save status: \(statusCode)")
//             if success {
//                 print("✅ Interest saved: \(interestId)")
//             } else {
//                 print("❌ Interest save failed: \(interestId)")
//             }

//             DispatchQueue.main.async { completion(success) }
//         }.resume()
//     }

//     /// Fetch all available interests from the backend (to get their IDs)
//     func fetchAvailableInterests(type: String? = nil, completion: @escaping ([[String: Any]]) -> Void) {
//         var urlString = "\(baseURL)api/profile/interests/available"
//         if let type = type {
//             urlString += "?type=\(type)"
//         }

//         guard let url = URL(string: urlString) else {
//             print("❌ Invalid URL for fetchAvailableInterests")
//             completion([])
//             return
//         }

//         print("📥 Fetching interests from: \(url.absoluteString)")

//         URLSession.shared.dataTask(with: url) { data, response, error in
//             if let error = error {
//                 print("❌ Fetch interests error: \(error)")
//                 DispatchQueue.main.async { completion([]) }
//                 return
//             }

//             let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
//             print("📊 Fetch interests status: \(statusCode)")

//             guard let data = data,
//                   let json = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
//                 print("❌ Failed to decode interests")
//                 DispatchQueue.main.async { completion([]) }
//                 return
//             }

//             print("✅ Fetched \(json.count) interests")
//             DispatchQueue.main.async { completion(json) }
//         }.resume()
//     }

//     /// Mark onboarding as complete
//     func markOnboardingComplete(token: String, completion: @escaping (Bool) -> Void) {
//         guard let url = URL(string: "\(baseURL)api/profile/onboarding-complete") else {
//             print("❌ Invalid URL for onboarding complete")
//             completion(false)
//             return
//         }

//         print("📤 Marking onboarding as complete")

//         var request = URLRequest(url: url)
//         request.httpMethod = "PATCH"
//         request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//         request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

//         URLSession.shared.dataTask(with: request) { data, response, error in
//             if let error = error {
//                 print("❌ Onboarding complete error: \(error)")
//             }

//             let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
//             let success = statusCode == 200

//             print("📊 Onboarding complete status: \(statusCode)")
//             if success {
//                 print("✅ Onboarding marked as complete")
//             } else {
//                 print("❌ Failed to mark onboarding complete")
//             }

//             DispatchQueue.main.async { completion(success) }
//         }.resume()
//     }
// }
