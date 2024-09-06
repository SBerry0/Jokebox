//
//  ContentFilter.swift
//  Jokebox
//
//  Created by Sohum Berry on 8/7/23.
//

import Foundation

public func containsSwearWord(text: String) -> Bool {
    let badwords = Constants.PottyWords.components(separatedBy: ",")
    let words_str = text.lowercased()
    let formatted_words_str = removeSpecialCharsFromString(text: words_str)
    let words = formatted_words_str.components(separatedBy: .whitespacesAndNewlines)
    for word in words {
        for badword in badwords {
            if badword == word{
                return true
            }
        }
    }
    return false
}

public func removeSpecialCharsFromString(text: String) -> String {
    let okayChars = Set("abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890")
    return text.filter {okayChars.contains($0) }
}
