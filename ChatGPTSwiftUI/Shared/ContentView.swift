//
//  ContentView.swift
//  XCAChatGPT
//
//  Created by Alfian Losari on 01/02/23.
//

import SwiftUI
import AVKit

struct ContentView: View {

    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var vm: ViewModel
    @FocusState var isTextFieldFocused: Bool

    @State private var isRecording = false
    @State var currentRecordFileUUID:UUID!

    @StateObject var whisperState = WhisperState()

    
    var body: some View {
        chatListView
            .navigationTitle("Azure OpenAI ChatGPT")
    }

    var chatListView: some View {
        ScrollViewReader { proxy in
            VStack(spacing: 0) {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(vm.messages) { message in
                            MessageRowView(message: message) { message in
                                Task { @MainActor in
                                    await vm.retry(message: message)
                                }
                            }
                        }
                    }
                    .onTapGesture {
                        isTextFieldFocused = false
                    }
                }
#if os(iOS) || os(macOS)
                Divider()
                bottomView(image: "command", proxy: proxy)
                VStack {
                    HStack {
                        Spacer()
                        TextField("Azure GPT Model Deployment URL", text: $vm.modelDeploymentURL, axis: .vertical)
                        Spacer()
                    }
                    HStack {
                        Spacer()
                        TextField("Azure OpenAI Key", text: $vm.azureopenaiKey, axis: .vertical)
                        Spacer()
                    }
                    
                }

                Spacer()
#endif
            }
            .onChange(of: vm.messages.last?.responseText) { _ in  scrollToBottom(proxy: proxy)
            }
        }
        .background(colorScheme == .light ? .white : Color(red: 52/255, green: 53/255, blue: 65/255, opacity: 0.5))
    }

    func bottomView(image: String, proxy: ScrollViewProxy) -> some View {
        HStack(alignment: .top, spacing: 8) {
            if image.hasPrefix("http"), let url = URL(string: image) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .frame(width: 30, height: 30)
                } placeholder: {
                    ProgressView()
                }

            } else {
                Image(systemName: image)
                    .resizable()
                    .frame(width: 30, height: 30)
            }

            TextField("Send message", text: $vm.inputMessage, axis: .vertical)
#if os(iOS) || os(macOS)
                .textFieldStyle(.roundedBorder)
#endif
                .focused($isTextFieldFocused)
                .disabled(vm.isInteractingWithChatGPT)

            if vm.isInteractingWithChatGPT {
                DotLoadingView().frame(width: 60, height: 30)
            } else {
                Button {
                    Task { @MainActor in
                        isTextFieldFocused = false
                        scrollToBottom(proxy: proxy)
                        await vm.sendTapped()
                    }
                } label: {
                    Image(systemName: "paperplane.circle.fill")
                        .rotationEffect(.degrees(45))
                        .font(.system(size: 30))
                }
#if os(macOS)
                .buttonStyle(.borderless)
                .keyboardShortcut(.defaultAction)
                .foregroundColor(.accentColor)
#endif
                .disabled(vm.inputMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

                Button(action: {
                    if self.isRecording {
                        self.stopRecording()
                        // 停止录音
                    } else {
                        // 开始录音
                        self.startRecording()
                    }
                    self.isRecording.toggle()
                }) {
                    if isRecording {
                        Image(systemName: "stop.circle")
                            .font(.title)
                        Text("Stop Recording" )
                    } else {
                        Image(systemName: "mic.circle")
                            .font(.title)
                        Text("Record")
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
    }

    private func scrollToBottom(proxy: ScrollViewProxy) {
        guard let id = vm.messages.last?.id else { return }
        proxy.scrollTo(id, anchor: .bottomTrailing)
    }

    private func startRecording()  {
        currentRecordFileUUID = UUID()
        vm.stopSpeaking()
        AudioRecorder.shared.startRecording(currentRecordFileUUID.uuidString)
    }

    private func stopRecording()  {
        AudioRecorder.shared.stopRecording()
        let audioFilename = getDocumentsDirectory().appendingPathComponent("\(currentRecordFileUUID.uuidString).wav")
        Task {
            await whisperState.transcribeAudio(audioFilename)
            print(whisperState.transcript)
            vm.inputMessage = whisperState.transcript
            await vm.sendTapped()

        }
    }

    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ContentView(vm: ViewModel(api: AzureOpenAIAPI(apiKey: "PROVIDE_API_KEY"), enableSpeech: true))
        }
    }
}
