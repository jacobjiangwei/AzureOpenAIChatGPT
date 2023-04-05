//
//  XCAChatGPTApp.swift
//  XCAChatGPT
//
//  Created by Alfian Losari on 01/02/23.
//

import SwiftUI

@main
struct XCAChatGPTApp: App {
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
