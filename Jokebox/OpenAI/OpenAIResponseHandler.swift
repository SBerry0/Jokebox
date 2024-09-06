//
//  OpenAIResponseHandler.swift
//  Jokester
//
//  Created by Sohum Berry on 6/11/23.
//

import Foundation

struct OpenAIResponseHandler {
    func decodeJson(jsonString: String) -> OpenAIResponse? {
        let json = jsonString.data(using: .utf8)!
//        print(jsonString)
        let decoder = JSONDecoder()
        do {
            let product = try decoder.decode(OpenAIResponse.self, from: json)
            print("PRODUCT CONTENT")
            print(product.choices.first?.message.content)
            return product
            
        } catch {
            print("Error decoding OpenAI API Response")
        }
        
        return nil
    }
}

struct Messaging: Codable {
    var role: String
    var content: String
    var refusal: String?
}

struct Usage: Codable {
    let prompt_tokens: Int
    let completion_tokens: Int
    let total_tokens: Int
}

struct OpenAIResponse: Codable {
    var id: String
    var object: String
    var created: Int
    var model: String
    var choices: [Choice]
    var usage: Usage
}

struct Choice: Codable {
    var index: Int
    var message: Messaging
    var logprobs: String?
    var finish_reason: String
}


