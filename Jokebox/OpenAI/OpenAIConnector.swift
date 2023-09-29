//
//  OpenAIConnector.swift
//  Jokester
//
//  Created by Sohum Berry on 6/11/23.
//

import Foundation

public class OpenAIConnector {
//    let openAIURL = URL(string: "https://api.openai.com/v1/engines/text-davinci-003/completions")
    let openAIURL = URL(string: "https://api.openai.com/v1/chat/completions")
    var openAIKey: String {
        return Constants.OpenAIAPIKey
    }
    var loading: Bool = false
    
    /// DO NOT EVER TOUCH THIS FUNCTION. EVER.
    private func executeRequest(request: URLRequest, withSessionConfig sessionConfig: URLSessionConfiguration?) -> Data? {
        let semaphore = DispatchSemaphore(value: 0)
        let session: URLSession
        if (sessionConfig != nil) {
            session = URLSession(configuration: sessionConfig!)
        } else {
            session = URLSession.shared
        }
        var requestData: Data?
        let task = session.dataTask(with: request as URLRequest, completionHandler:{ (data: Data?, response: URLResponse?, error: Error?) -> Void in
            if error != nil {
                print("error: \(error!.localizedDescription): \(error!.localizedDescription)")
            } else if data != nil {
                requestData = data
            }
            
            print("Semaphore signalled")
            semaphore.signal()
        })
        task.resume()
        
        // Handle async with semaphores. Max wait of 10 seconds
        let timeout = DispatchTime.now() + .seconds(20)
        print("Waiting for semaphore signal")
        let retVal = semaphore.wait(timeout: timeout)
        print("Done waiting, obtained - \(retVal)")
        return requestData
    }
    
    // Function to represent the request to the server, doesn't actually send it
    public func processPrompt(prompt: String) -> Optional<String> {
//        let logit_bias = [
//            37696:-50,
//            22037:-50,
//            47114:-50,
//            1416:-50,
//            533:-50,
//            19437:-50
//        ]
        //cURL request
        var request = URLRequest(url: self.openAIURL!)
//        var messages: [[[String : String]]]
//        messages[0].append(["role": "system"])
        // HTTP method is POST, sends data to OpenAI's server
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(self.openAIKey)", forHTTPHeaderField: "Authorization")
        let httpBody: [String: Any] = [
            "model": "gpt-3.5-turbo",
            
            "messages": [["role": "system", "content": "You are a funny and kid friendly comedian that always provides jokes that are relevant to the user's situtation."], ["role": "user", "content": prompt]],
            /// Adjust this to control the maxiumum amount of tokens OpenAI can respond with.
            "max_tokens" : 100,
            /// You can add more parameters below, but make sure they match the ones in the OpenAI API Reference.
            "temperature" : 0.9,
            
//            "logit_bias" : [37696:-50, 22037:-50, 47114:-50, 1416:-50, 533:-50, 19437:-50]
//            "logit_bias" : logit_bias.mapValues({ Int in
//                return Int
//            })
        ]
        
        var httpBodyJson: Data
        
        do {
            httpBodyJson = try JSONSerialization.data(withJSONObject: httpBody, options: .prettyPrinted)
        } catch {
            print("Unable to convert to JSON \(error)")
            return nil
        }
        
        request.httpBody = httpBodyJson
        if let requestData = executeRequest(request: request, withSessionConfig: nil) {
            let jsonStr = String(data: requestData, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!
            print(jsonStr)
            let responseHandler = OpenAIResponseHandler()
//            guard let text = responseHandler.decodeJson(jsonString: jsonStr)?.choices[0].message["content"] else { return nil }
//            let formatted_text = removeSpecialCharsFromString(text: text).lowercased()
//            let text_array = formatted_text.components(separatedBy: .whitespacesAndNewlines)
//            let formatted_prompt = removeSpecialCharsFromString(text: prompt).lowercased()
//            var joke = ""
//            let prompt_array = formatted_prompt.components(separatedBy: .whitespacesAndNewlines)
            
//            if formatted_prompt.contains("atom") {
//                if !formatted_text.contains("atom") {
//                    return responseHandler.decodeJson(jsonString: self.processPrompt(prompt: "\(prompt) Make sure it is not about an atom") ?? "nil")?.choices[0].message["content"]
//                }
//            }
//            if formatted_prompt.contains("scarecrow") {
//                if !formatted_text.contains("scarecrow") {
//                    return responseHandler.decodeJson(jsonString: self.processPrompt(prompt: "\(prompt) Make sure it is not about a scarecrow") ?? "nil")?.choices[0].message["content"]
//                }
//            }
//            if text.prefix(upTo: text.index(text.startIndex, offsetBy: 4)) == "Sure" {
//                print(text)
//                print("Has sure")
//                joke = String(text.split(separator: ":")[1].dropFirst())
//            }
            
            return responseHandler.decodeJson(jsonString: jsonStr)?.choices[0].message["content"]
//            return joke
        }
        
        return nil
    }
}
