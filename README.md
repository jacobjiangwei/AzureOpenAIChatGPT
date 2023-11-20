

# ChatGPT SwiftUI macOS App

![Alt text](https://github.com/jacobjiangwei/AzureOpenAIChatGPT/blob/main/whisperandazureai.jpg?raw=true "image")

这是一个专为macOS设计的原生App，用于与ChatGPT进行交互，使用了SwiftUI和OpenAPI API。它使用了官方的ChatGPT端点和`gpt-3.5-turbo`模型。

## 要求
- Xcode 14 
- 在azure.microsoft.com上注册
- 在Azure OpenAI上部署GPT模型
- 创建API Key
- 在ContentView中声明ChatGPTAPI实例时粘贴API key
- 输入Azure OpenAI的key和deployment URL

这是一个专为macOS用户设计的App，只需输入Azure OpenAI的key和deployment URL，您就可以在家中享受类似于OpenAI的ChatGPT Plus的体验！

我们实现了whisper v3的大模型，你可以直接语音输入提问，macOS可以高效本地语音识别，并且利用了苹果自带的speech framework的text to speech功能。



# ChatGPT SwiftUI macOS App

![Alt text](https://github.com/jacobjiangwei/AzureOpenAIChatGPT/blob/main/whisperandazureai.jpg?raw=true "image")

This is a native macOS App for interacting with ChatGPT, built using SwiftUI and OpenAPI API. It's using the official ChatGPT endpoint with the `gpt-3.5-turbo` model.

## Requirements
- Xcode 14 
- Register at azure.microsoft.com
- Deploy the GPT model on Azure OpenAI
- Create an API Key
- Paste the API key where the ChatGPTAPI instance is declared in ContentView
- Input Azure OpenAI's key and deployment URL

This is a macOS exclusive app. By inputting Azure OpenAI's key and deployment URL, you can enjoy an experience similar to OpenAI's ChatGPT Plus at home!

We have implemented the large model of whisper v3, macOS can supports voice recongition quickly, and it utilizes Apple's built-in speech framework's text to speech feature.