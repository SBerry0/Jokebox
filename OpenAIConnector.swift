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

        //cURL request
        var request = URLRequest(url: self.openAIURL!)
//        var messages: [[[String : String]]]
//        messages[0].append(["role": "system"])
        // HTTP method is POST, sends data to OpenAI's server
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(self.openAIKey)", forHTTPHeaderField: "Authorization")
        let httpBody: [String: Any] = [
//            "model": "gpt-3.5-turbo",
            "model": "gpt-4",
            
            "messages": [["role": "system", "content": "You are a funny comedian that always provides jokes that are relevant to the given situtation."], ["role": "user", "content": prompt]],
            /// Adjust this to control the maxiumum amount of tokens OpenAI can respond with.
            "max_tokens" : 175,
            /// You can add more parameters below, but make sure they match the ones in the OpenAI API Reference.
            "temperature" : 0.9,
            
//            "response_format" : ["type" : "json_object"],
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
            
            return responseHandler.decodeJson(jsonString: jsonStr)?.choices.first?.message.content
            
        }
        
        return nil
    }
}
