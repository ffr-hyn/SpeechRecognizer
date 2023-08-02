//
//  ContentView.swift
//  SpeechRecognizer
//
//  Created by 河村健太 on 2023/05/07.
//

import SwiftUI

struct RecognizerView: View {
    @ObservedObject private var viewModel = RecognizerViewModel()
    @State var isSelectionActionSheet = false
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                Color.init(.init(gray: 0.2, alpha: 1))
                    .frame(maxWidth: .infinity)
                    .frame(height: UIScreen.main.bounds.height / 2)
                    .overlay {
                        Text(viewModel.displayText)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                            .multilineTextAlignment(.leading)
                            .padding()
                    }
                    .padding(.horizontal, 32)
                    .padding(.top, 64)
                Spacer()
                HStack(alignment: .center, spacing: 0) {
                    ShareLink(item: viewModel.displayText) {
                        RoundedRectangle(cornerRadius: 4)
                            .foregroundColor(.blue)
                            .frame(width: 64, height: 48)
                            .overlay {
                                Text("共有")
                                    .foregroundColor(.white)
                            }
                            .opacity((viewModel.displayText.isEmpty || viewModel.isRecognizing) ? 0.5 : 1)
                    }
                    .disabled(viewModel.displayText.isEmpty || viewModel.isRecognizing)

                    Spacer()

                    Button {
                        if viewModel.isRecognizing {
                            viewModel.stopRecognition()
                        } else {
                            viewModel.checkEnableRecognition()
                        }
                    } label: {
                        Circle()
                            .strokeBorder(.white, lineWidth: 4, antialiased: true)
                            .frame(width: 64, height:64)
                            .foregroundColor(.clear)
                            .overlay {
                                if !viewModel.isRecognizing {
                                    Circle()
                                        .foregroundColor(.red)
                                        .padding(8)
                                } else {
                                    RoundedRectangle(cornerRadius: 8)
                                        .foregroundColor(.red)
                                        .frame(width: 32, height: 32)
                                }
                            }
                    }
                    .animation(.default, value: viewModel.isRecognizing)

                    Spacer()

                    Button {
                        isSelectionActionSheet = true
                    } label: {
                        RoundedRectangle(cornerRadius: 4)
                            .foregroundColor(.blue)
                            .frame(width: 64, height: 48)
                            .overlay {
                                Text("AI変換")
                                    .foregroundColor(.white)
                            }
                            .opacity((viewModel.displayText.isEmpty || viewModel.isRecognizing) ? 0.5 : 1)
                    }
                    .disabled(viewModel.displayText.isEmpty || viewModel.isRecognizing)
                }
                .padding(.bottom, 32)
                .padding(.horizontal, 32)
            }
        }
        .confirmationDialog("AIで変換します", isPresented: $isSelectionActionSheet, actions: {
            ForEach(ChatGPTManager.TransformType.allCases, id: \.self) { type in
                Button(type.title) {
                    Task {
                        do {
                            viewModel.displayText = try await ChatGPTManager.shared.requestTransform(type: type, text: viewModel.displayText)
                        } catch {
                            print(error)
                        }
                    }
                }
            }
        }, message: {
            Text("解析した音声を指定した口調に変換できます")
        })
        .background(.black)
    }
}

struct RecognizerView_Previews: PreviewProvider {
    static var previews: some View {
        RecognizerView()
    }
}
