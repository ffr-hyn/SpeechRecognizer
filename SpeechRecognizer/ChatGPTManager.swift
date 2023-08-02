//
//  ChatGPTManager.swift
//  SpeechRecognizer
//
//  Created by 河村健太 on 2023/07/17.
//

import Foundation
import SwiftUI

final class ChatGPTManager {
    struct OpenIAKey {
        let apiKey = "hogehoge"
        let orgKey = "haguhagu"
    }
    enum TransformType: CaseIterable {
        case honorific
        case casual
        case ojyosama

        var title: String {
            switch self {
                case .honorific:
                    return "です・ます調"
                case .casual:
                    return "タメ語"
                case .ojyosama:
                    return "お嬢様風"
            }
        }

        var instruction: String {
            switch self {
                case .honorific:
                    return "以下の文章の語尾を「です」もしくは「ます」に変えてください。"
                case .casual:
                    return "以下の文章の語尾を砕けた表現に変えてください。"
                case .ojyosama:
                    return "以下の文章をお嬢様風に変えてください。"
            }
        }
    }

    static let shared = ChatGPTManager()
    private let apiKey = "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"
    private let orgKey = "org-tqmCOoThQnP1Org88EUJdMM0"


    func requestTransform(type: TransformType, text: String) async throws -> String {
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = ["Authorization" : "Bearer \(apiKey)"
                                       ,"OpenAI-Organization": orgKey
                                       ,"Content-Type" : "application/json"]
        let messages = [ChatGPTParam.ChatGPTMassage(role: "system", content: type.instruction),
                        ChatGPTParam.ChatGPTMassage(role: "user", content: text)]
        let requestBody = ChatGPTParam.ChatGPTRequest(model: "gpt-3.5-turbo", messages: messages)
        let encordedRequestBody = try JSONEncoder().encode(requestBody)
        request.httpBody = encordedRequestBody
        let (data, response) = try await URLSession.shared.data(for: request)

        let result = try JSONDecoder().decode(ChatGPTParam.ChatGPTResponse.self, from: data)
        return result.choices.first?.message.content ?? "解答なし"
    }
}



class ChatGPTParam {
    struct ChatGPTRequest: Codable {
        let model: String
        let messages: [ChatGPTMassage]
    }

    struct ChatGPTMassage: Codable {
        let role: String
        let content: String
    }

    struct ChatGPTResponse: Codable {
        let id: String
        let object: String
        let created: Int
        let model: String
        let usage: ChatGPTUsage
        let choices: [ChatGPTChoices]
    }

    struct ChatGPTUsage: Codable {
        let prompt_tokens: Int
        let completion_tokens: Int
        let total_tokens: Int
    }

    struct ChatGPTChoices: Codable {
        let message: ChatGPTMassage
        let finish_reason: String
        let index: Int
    }
}
