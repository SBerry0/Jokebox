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
        
        let decoder = JSONDecoder()
        do {
            let product = try decoder.decode(OpenAIResponse.self, from: json)
            return product
            
        } catch {
            print("Error decoding OpenAI API Response")
        }
        
        return nil
    }
}

struct OpenAIResponse: Codable {
    var id: String
    var object: String
    var created: Int
    var model: String
    var usage: [String : Int]
    
    var choices: [Choice]
}

struct Choice: Codable {
    var message: [String: String]
    var finish_reason: String
    var index: Int
}
