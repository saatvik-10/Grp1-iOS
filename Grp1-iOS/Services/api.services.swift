import Foundation

final class APIService {
    static let shared = APIService()

    var baseURL: String
    private let session: URLSession

    private init(session: URLSession = .shared) {
        if let configuredURL = Bundle.main.object(forInfoDictionaryKey: "API_BASE_URL") as? String,
           !configuredURL.isEmpty {
            self.baseURL = configuredURL
        } else {
            self.baseURL = "http://localhost:8081"
        }
        self.session = session
    }

    // ─────────────────────────────────────────────
    // MARK: - URL Builder
    // ─────────────────────────────────────────────

    private func makeURL(path: String, queryItems: [URLQueryItem] = []) -> URL? {
        guard var components = URLComponents(string: baseURL + path) else { return nil }
        if !queryItems.isEmpty { components.queryItems = queryItems }
        return components.url
    }

    // ─────────────────────────────────────────────
    // MARK: - Date Decoder
    // ─────────────────────────────────────────────

    private func decoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        let plain = ISO8601DateFormatter()
        plain.formatOptions = [.withInternetDateTime]
        let fractional = ISO8601DateFormatter()
        fractional.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        decoder.dateDecodingStrategy = .custom { dateDecoder in
            let container = try dateDecoder.singleValueContainer()
            let raw = try container.decode(String.self)
            if let value = fractional.date(from: raw) ?? plain.date(from: raw) { return value }
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Invalid ISO8601 date: \(raw)"
            )
        }
        return decoder
    }

    // ─────────────────────────────────────────────
    // MARK: - JSON Request (for non-image endpoints)
    // ─────────────────────────────────────────────

    private struct EmptyBody: Encodable {}

    private func request<Response: Decodable, Body: Encodable>(
        method: APIMethod,
        path: String,
        token: String? = nil,
        queryItems: [URLQueryItem] = [],
        body: Body? = nil,
        completion: @escaping (Result<Response, APIError>) -> Void
    ) {
        guard let url = makeURL(path: path, queryItems: queryItems) else {
            completion(.failure(.invalidURL)); return
        }

        var req = URLRequest(url: url)
        req.httpMethod = method.rawValue
        req.setValue("application/json", forHTTPHeaderField: "Accept")

        if let token { req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization") }

        if let body {
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
            do {
                req.httpBody = try JSONEncoder().encode(body)
            } catch {
                completion(.failure(.transport(error))); return
            }
        }

        session.dataTask(with: req) { [weak self] data, response, error in
            self?.handleResponse(data: data, response: response, error: error, completion: completion)
        }.resume()
    }

    private func requestStatus<Body: Encodable>(
        method: APIMethod,
        path: String,
        token: String? = nil,
        body: Body? = nil,
        completion: @escaping (Result<Void, APIError>) -> Void
    ) {
        guard let url = makeURL(path: path) else {
            completion(.failure(.invalidURL)); return
        }

        var req = URLRequest(url: url)
        req.httpMethod = method.rawValue
        req.setValue("application/json", forHTTPHeaderField: "Accept")

        if let token { req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization") }

        if let body {
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
            do {
                req.httpBody = try JSONEncoder().encode(body)
            } catch {
                completion(.failure(.transport(error))); return
            }
        }

        session.dataTask(with: req) { data, response, error in
            if let error {
                DispatchQueue.main.async { completion(.failure(.transport(error))) }; return
            }
            guard let http = response as? HTTPURLResponse else {
                DispatchQueue.main.async { completion(.failure(.invalidResponse)) }; return
            }
            if http.statusCode == 401 {
                DispatchQueue.main.async { completion(.failure(.unauthorized)) }; return
            }
            guard (200...299).contains(http.statusCode) else {
                let message = data.flatMap { String(data: $0, encoding: .utf8) }
                DispatchQueue.main.async {
                    completion(.failure(.server(statusCode: http.statusCode, message: message)))
                }
                return
            }
            DispatchQueue.main.async { completion(.success(())) }
        }.resume()
    }

    // ─────────────────────────────────────────────
    // MARK: - Multipart Form-Data Request
    // ─────────────────────────────────────────────

    private func multipartRequest<Response: Decodable>(
        method: APIMethod,
        path: String,
        token: String? = nil,
        fields: [String: String],
        tagsField: [String]? = nil,
        imageData: Data? = nil,
        imageFileName: String? = nil,
        imageFieldName: String = "threadImage",
        completion: @escaping (Result<Response, APIError>) -> Void
    ) {
        guard let url = makeURL(path: path) else {
            completion(.failure(.invalidURL)); return
        }

        let boundary = "Boundary-\(UUID().uuidString)"
        var body = Data()

        func appendField(_ name: String, value: String) {
            body.append(contentsOf: "--\(boundary)\r\n".utf8)
            body.append(contentsOf: "Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n".utf8)
            body.append(contentsOf: "\(value)\r\n".utf8)
        }

        func appendImageData(_ data: Data, fieldName: String, fileName: String) {
            let mimeType = fileName.lowercased().hasSuffix(".png") ? "image/png" : "image/jpeg"
            body.append(contentsOf: "--\(boundary)\r\n".utf8)
            let disposition = "Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(fileName)\"\r\n"
            body.append(contentsOf: disposition.utf8)
            body.append(contentsOf: "Content-Type: \(mimeType)\r\n\r\n".utf8)
            body.append(data)
            body.append(contentsOf: "\r\n".utf8)
        }

        for (key, value) in fields {
            appendField(key, value: value)
        }

        if let tags = tagsField {
            for tag in tags {
                appendField("tags[]", value: tag)
            }
        }

        if let imageData, let imageFileName {
            appendImageData(imageData, fieldName: imageFieldName, fileName: imageFileName)
        }

        body.append(contentsOf: "--\(boundary)--\r\n".utf8)

        var req = URLRequest(url: url)
        req.httpMethod = method.rawValue
        req.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        if let token { req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization") }
        req.httpBody = body

        session.dataTask(with: req) { [weak self] data, response, error in
            self?.handleResponse(data: data, response: response, error: error, completion: completion)
        }.resume()
    }

    // ─────────────────────────────────────────────
    // MARK: - Shared Response Handler
    // ─────────────────────────────────────────────

    private func handleResponse<Response: Decodable>(
        data: Data?,
        response: URLResponse?,
        error: Error?,
        completion: @escaping (Result<Response, APIError>) -> Void
    ) {
        if let error {
            DispatchQueue.main.async { completion(.failure(.transport(error))) }
            return
        }

        guard let http = response as? HTTPURLResponse else {
            DispatchQueue.main.async { completion(.failure(.invalidResponse)) }
            return
        }

        if http.statusCode == 401 {
            DispatchQueue.main.async { completion(.failure(.unauthorized)) }
            return
        }

        guard (200...299).contains(http.statusCode) else {
            let message = data.flatMap { String(data: $0, encoding: .utf8) }
            DispatchQueue.main.async {
                completion(.failure(.server(statusCode: http.statusCode, message: message)))
            }
            return
        }

        guard let data else {
            DispatchQueue.main.async { completion(.failure(.invalidResponse)) }
            return
        }

        do {
            let parsed = try self.decoder().decode(Response.self, from: data)
            DispatchQueue.main.async { completion(.success(parsed)) }
        } catch {
            if let raw = String(data: data, encoding: .utf8) {
                print("[APIService] Decode error. Raw response: \(raw)")
            }
            DispatchQueue.main.async { completion(.failure(.decodingError)) }
        }
    }
}
