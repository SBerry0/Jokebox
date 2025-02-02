//
//  APIManager.swift
//  Jokebox
//
//  Created by Sohum Berry on 1/31/25.
//

import Foundation

class APIManager {
    static let shared = APIManager()
    private init() {}

//    private let baseURL = "http://127.0.0.1:5000/get-completion"
    private let baseURL = "https://sohumberry.pythonanywhere.com/get-completion"
    
    func getGPT4Response(for prompt: String, completion: @escaping (Result<String, Error>) -> Void) {
        // Create the URL
        guard let url = URL(string: baseURL) else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return
        }
        
        // Create the request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add the prompt to the request body
        let requestBody: [String: Any] = ["prompt": prompt]
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
        } catch {
            completion(.failure(error))
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No data received", code: -2, userInfo: nil)))
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
//                    print("Full JSON response: \(json)") // Debugging step
                    if let responseText = json["response"] as? String {
                        completion(.success(responseText))
                    }
                } else {
                    completion(.failure(NSError(domain: "Failed to parse JSON", code: -4, userInfo: nil)))
                }
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()

    }
}

