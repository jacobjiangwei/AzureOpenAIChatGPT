//
//  AzureOpenAIApp.swift
//  AzureOpenAI
//
//  Created by jacob on 2023/4/5.
//

import SwiftUI

@main
struct AzureOpenAIApp: App {
    @StateObject var vm = ViewModel(api: AzureOpenAIAPI(apiKey: REPLACE_WITH_API_KEY))

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ContentView(vm: vm)
                    .toolbar {
                        ToolbarItem {
                            Button("Clear") {
                                vm.clearMessages()
                            }
                            .disabled(vm.isInteractingWithChatGPT)
                        }
                    }
            }
        }
    }
}
