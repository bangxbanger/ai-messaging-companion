//
//  APIService.swift
//  Bro
//

import Foundation

class APIService {
    static let shared = APIService()
    
    private init() {}
    
    // MARK: - Rephrase (Streaming SSE)
    func rephraseStream(text: String,
                       profile: ToneProfile,
                       onChunk: @escaping (String) -> Void,
                       onComplete: @escaping (Result<Void, Error>) -> Void) {
        let urlString = "\(Config.backendURL)/rephrase/stream"
        guard let url = URL(string: urlString) else {
            onComplete(.failure(APIError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = Config.streamTimeout
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = ["text": text, "profile": profile.rawValue]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async { onComplete(.failure(error)) }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async { onComplete(.failure(APIError.noData)) }
                return
            }
            
            // Parse SSE stream
            let text = String(data: data, encoding: .utf8) ?? ""
            let lines = text.components(separatedBy: "\n")
            
            for line in lines {
                if line.hasPrefix("data: ") {
                    let jsonString = String(line.dropFirst(6))
                    if let jsonData = jsonString.data(using: .utf8),
                       let event = try? JSONDecoder().decode(SSEEvent.self, from: jsonData) {
                        if let content = event.content {
                            DispatchQueue.main.async {
                                onChunk(content)
                            }
                        }
                        if event.done == true {
                            DispatchQueue.main.async {
                                onComplete(.success(()))
                            }
                            return
                        }
                        if let error = event.error {
                            DispatchQueue.main.async {
                                onComplete(.failure(APIError.serverError(error)))
                            }
                            return
                        }
                    }
                }
            }
            
            DispatchQueue.main.async {
                onComplete(.success(()))
            }
        }
        
        task.resume()
    }
    
    // MARK: - Rephrase (Synchronous, FastAPI)
    func rephrase(text: String,
                  profile: ToneProfile,
                  completion: @escaping (Result<String, Error>) -> Void) {
        let urlString = "\(Config.backendURL)/rephrase"
        guard let url = URL(string: urlString) else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = Config.requestTimeout
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = ["text": text, "profile": profile.rawValue]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }
            guard let data = data else {
                DispatchQueue.main.async { completion(.failure(APIError.noData)) }
                return
            }
            
            struct Resp: Decodable { let rephrased_text: String }
            if let resp = try? JSONDecoder().decode(Resp.self, from: data) {
                DispatchQueue.main.async { completion(.success(resp.rephrased_text)) }
            } else if let err = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                DispatchQueue.main.async { completion(.failure(APIError.serverError(err.error))) }
            } else {
                DispatchQueue.main.async { completion(.failure(APIError.unknown)) }
            }
        }
        task.resume()
    }
    
    // MARK: - Profiles
    func getProfiles(completion: @escaping (Result<[String], Error>) -> Void) {
        let urlString = "\(Config.backendURL)/profiles"
        guard let url = URL(string: urlString) else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = Config.requestTimeout
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }
            guard let data = data else {
                DispatchQueue.main.async { completion(.failure(APIError.noData)) }
                return
            }
            
            struct Resp: Decodable { let profiles: [String] }
            if let resp = try? JSONDecoder().decode(Resp.self, from: data) {
                DispatchQueue.main.async { completion(.success(resp.profiles)) }
            } else {
                DispatchQueue.main.async { completion(.failure(APIError.unknown)) }
            }
        }
        task.resume()
    }
    
    // MARK: - Health Check
    func healthCheck(completion: @escaping (Result<Bool, Error>) -> Void) {
        let urlString = "\(Config.backendURL)/health"
        guard let url = URL(string: urlString) else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 5
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }
            guard let data = data else {
                DispatchQueue.main.async { completion(.failure(APIError.noData)) }
                return
            }
            
            struct Resp: Decodable { let ok: Bool }
            if let resp = try? JSONDecoder().decode(Resp.self, from: data) {
                DispatchQueue.main.async { completion(.success(resp.ok)) }
            } else {
                DispatchQueue.main.async { completion(.failure(APIError.unknown)) }
            }
        }
        task.resume()
    }
}

// MARK: - API Errors

enum APIError: LocalizedError {
    case invalidURL
    case noData
    case serverError(String)
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received from server"
        case .serverError(let message):
            return message
        case .unknown:
            return "An unknown error occurred"
        }
    }
}

// MARK: - Response Models

struct SSEEvent: Decodable {
    let content: String?
    let done: Bool?
    let error: String?
}

struct ErrorResponse: Decodable {
    let error: String
    
    enum CodingKeys: String, CodingKey {
        case error = "detail"
    }
}
