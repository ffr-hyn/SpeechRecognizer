//
//  ContentView.swift
//  SpeechRecognizer
//
//  Created by 河村健太 on 2023/05/07.
//

import SwiftUI

struct RecognizerView: View {
    @ObservedObject private var viewModel = RecognizerViewModel()
    var body: some View {
        ZStack {
            VStack {
                Color.init(.init(gray: 0.2, alpha: 1))
                    .frame(maxWidth: .infinity)
                    .frame(height: UIScreen.main.bounds.height / 2)
                    .overlay {
                        Text(viewModel.speechResult)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                            .multilineTextAlignment(.leading)
                            .padding()
                    }
                    .padding(.horizontal, 32)
                    .padding(.top, 64)
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
                .padding(.bottom, 32)
                .animation(.default, value: viewModel.isRecognizing)
            }
        }
        .background(.black)
    }
}

struct RecognizerView_Previews: PreviewProvider {
    static var previews: some View {
        RecognizerView()
    }
}
