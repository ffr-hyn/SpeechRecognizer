//
//  ContentView.swift
//  SpeechRecognizer
//
//  Created by 河村健太 on 2023/05/07.
//

import SwiftUI

struct recognizerView: View {
    @State private var recognizedText = ""

    var body: some View {
        ZStack {
            VStack {
                Text(recognizedText)
                    .frame(maxWidth: .infinity)
                    .frame(height: UIScreen.main.bounds.height / 2)
                    .background(Color.init(.init(gray: 0.2, alpha: 1)))
                    .padding(.horizontal, 32)
                    .padding(.top, 64)
                Spacer()
                Button {
                    print("ボタン")
                } label: {
                    Circle()
                        .frame(width: 64, height:64)
                        .foregroundColor(.clear)
                        .
                }

            }
        }
//        .frame(maxWidth: .infinity, minHeight: .infinity)
        .background(.black)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        recognizerView()
    }
}
