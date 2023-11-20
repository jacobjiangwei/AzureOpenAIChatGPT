//
//  ViewModel.swift
//  XCAChatGPT
//
//  Created by Alfian Losari on 02/02/23.
//

import Foundation
import SwiftUI
import AVKit

class ViewModel: ObservableObject {
    
    @Published var isInteractingWithChatGPT = false
    @Published var messages: [MessageRow] = []
    @Published var inputMessage: String = ""
    @Published var modelDeploymentURL: String = "" {
        didSet {
            api.modelDeploymentURL = modelDeploymentURL
            UserDefaults.standard.setValue(modelDeploymentURL, forKey: "ModelDeploymentURL")
        }
    }
    @Published var azureopenaiKey: String = "" {
        didSet {
            api.apiKey = azureopenaiKey
            UserDefaults.standard.setValue(azureopenaiKey, forKey: "azureopenaiKey")
        }
    }


    private var synthesizer: AVSpeechSynthesizer?
    
    private let api: AzureOpenAIAPI
    
    init(api: AzureOpenAIAPI, enableSpeech: Bool = true) {
        self.api = api
        synthesizer = .init()
        if let modelDeploymentURL = UserDefaults.standard.string(forKey: "ModelDeploymentURL") {
            self.modelDeploymentURL = modelDeploymentURL
        }
        if let azureopenaiKey = UserDefaults.standard.string(forKey: "azureopenaiKey") {
            self.azureopenaiKey = azureopenaiKey
        }
    }
    
    @MainActor
    func sendTapped() async {
        let text = inputMessage
        inputMessage = ""
        await send(text: text)
    }
    
    @MainActor
    func clearMessages() {
        stopSpeaking()
        api.deleteHistoryList()
        withAnimation { [weak self] in
            self?.messages = []
        }
    }
    
    @MainActor
    func retry(message: MessageRow) async {
        guard let index = messages.firstIndex(where: { $0.id == message.id }) else {
            return
        }
        self.messages.remove(at: index)
        await send(text: message.sendText)
    }
    
    @MainActor
    private func send(text: String) async {
        isInteractingWithChatGPT = true
        var streamText = ""
        var messageRow = MessageRow(
            isInteractingWithChatGPT: true,
            sendImage: "command",
            sendText: text,
            responseImage: "cloud",
            responseText: streamText,
            responseError: nil)
        
        self.messages.append(messageRow)
        
        do {
            let botMessage = try await api.sendMessage(text)
            messageRow.responseText = botMessage.trimmingCharacters(in: .whitespacesAndNewlines)
            self.messages[self.messages.count - 1] = messageRow
//            for try await text in stream {
//                streamText += text
//                messageRow.responseText = streamText.trimmingCharacters(in: .whitespacesAndNewlines)
//                self.messages[self.messages.count - 1] = messageRow
//            }
        } catch {
            messageRow.responseError = error.localizedDescription
        }
        
        messageRow.isInteractingWithChatGPT = false
        self.messages[self.messages.count - 1] = messageRow
        isInteractingWithChatGPT = false
        speakLastResponse()
        
    }
    
    func speakLastResponse() {
        guard let synthesizer, let responseText = self.messages.last?.responseText, !responseText.isEmpty else {
            return
        }
        stopSpeaking()
        let utterance = AVSpeechUtterance(string: responseText)
        if let language = NSLinguisticTagger.dominantLanguage(for: responseText) {
            utterance.voice = .init(language: language)
            
            utterance.rate = 0.5
            utterance.pitchMultiplier = 0.8
            utterance.postUtteranceDelay = 0.2
            synthesizer.speak(utterance )
        }
    }
    
    func stopSpeaking() {
        synthesizer?.stopSpeaking(at: .immediate)
    }
    
}
