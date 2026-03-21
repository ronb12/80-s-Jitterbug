import Foundation

/// Uploads images to ImgBB (free) and returns a public URL. No Firebase Storage required.
/// API key is read from Info: ImgbbApiKey. Get one at https://api.imgbb.com/
enum ImgurUploadService {
    private static var apiKey: String? {
        Bundle.main.object(forInfoDictionaryKey: "ImgbbApiKey") as? String
    }

    /// Upload image data to ImgBB; returns the direct image URL.
    static func uploadImage(_ data: Data) async throws -> String {
        guard let key = apiKey, !key.isEmpty else {
            throw UploadError.missingApiKey
        }
        let base64 = data.base64EncodedString()
        let encoded = base64.addingPercentEncoding(withAllowedCharacters: .alphanumerics.union(CharacterSet(charactersIn: "-_.~"))) ?? base64
        let url = URL(string: "https://api.imgbb.com/1/upload")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = "key=\(key)&image=\(encoded)".data(using: .utf8)

        let (responseData, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw UploadError.invalidResponse
        }
        guard http.statusCode == 200 else {
            let json = try? JSONSerialization.jsonObject(with: responseData) as? [String: Any]
            let error = json?["error"] as? [String: Any]
            let message = error?["message"] as? String ?? "HTTP \(http.statusCode)"
            throw UploadError.uploadFailed(message)
        }
        struct ImgbbResponse: Decodable {
            let data: DataPayload
            struct DataPayload: Decodable {
                let url: String
            }
        }
        let decoded = try JSONDecoder().decode(ImgbbResponse.self, from: responseData)
        guard let link = URL(string: decoded.data.url) else {
            throw UploadError.invalidResponse
        }
        return link.absoluteString
    }

    enum UploadError: LocalizedError {
        case missingApiKey
        case invalidResponse
        case uploadFailed(String)
        var errorDescription: String? {
            switch self {
            case .missingApiKey:
                return "ImgBB API key not set. Add ImgbbApiKey in Target → Info."
            case .invalidResponse:
                return "Invalid response from ImgBB."
            case .uploadFailed(let msg):
                return "Upload failed: \(msg)"
            }
        }
    }
}
