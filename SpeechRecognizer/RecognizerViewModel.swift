//
//  RecognizerViewModel.swift
//  SpeechRecognizer
//
//  Created by 河村健太 on 2023/05/07.
//

import SwiftUI
import Speech
import AVFoundation
import Combine

final class RecognizerViewModel: NSObject, ObservableObject {
    @Published var speechResult = ""
    @Published var isRecognizing = false
    @Published var errorAlertFlag = false

    private let speechRecognizer = SFSpeechRecognizer(locale: .init(identifier: "ja_JP"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var audioEngin: AVAudioEngine?

    override init() {
        super.init()
        speechRecognizer?.delegate = self
    }

    func checkEnableRecognition() {
        Task {
            guard await checkMicrophoneAuthorization() else {
                errorAlertFlag = true
                return
            }
            checkRecognizerAuthorization { isAuthorized in
                if isAuthorized {
                    self.startRecognition()
                } else {
                    self.errorAlertFlag = true
                }
            }
        }
    }

    private func checkMicrophoneAuthorization() async -> Bool {
        switch AVCaptureDevice.authorizationStatus(for: .audio) {
            case .notDetermined:
                return await AVCaptureDevice.requestAccess(for: .audio)
            case .restricted, .denied:
                return false
            case .authorized:
                return true
            @unknown default:
                fatalError()
        }
    }

    private func checkRecognizerAuthorization(didCheck: @escaping ((Bool) -> Void)) {
        switch SFSpeechRecognizer.authorizationStatus() {
            case .notDetermined:
                SFSpeechRecognizer.requestAuthorization { status in
                    didCheck(status == .authorized)
                }
            case .denied, .restricted:
                didCheck(false)
            case .authorized:
                didCheck(true)
            @unknown default:
                fatalError()
        }
    }

    private func startRecognition() {
        // リセットのため終了時の処理を呼ぶ
        stopRecognition()

        // オーディオセッションの変更
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            stopRecognition()
            return
        }

        // 音声認識リクエストの作成
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            stopRecognition()
            return
        }
        // リアルタイムで結果を返すか
        recognitionRequest.shouldReportPartialResults = true
        // 音声データをデバイス上だけで認識を行うか、falseでネットを介して結果を取得
        recognitionRequest.requiresOnDeviceRecognition = false
        // 句読点を結果に含むか
        if #available(iOS 16, *) {
            recognitionRequest.addsPunctuation = true
        }

        //音声認識タスクの生成（delegateじゃなくコールバックでハンドリングも可能）
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, delegate: self)

        // マイク入力ノードの準備
        audioEngin = AVAudioEngine()
        let inputNode = audioEngin?.inputNode
        let recordingFormat = inputNode?.outputFormat(forBus: 0)
        // ノード出力の監視
        inputNode?.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat, block: { buffer, when in
            // 録音データをrecognizerに渡す
            recognitionRequest.append(buffer)
        })
        // エンジンの用意
        audioEngin?.prepare()
        do {
            // 音声取得スタート
            try audioEngin?.start()
            Task { @MainActor in
                speechResult = ""
                isRecognizing = true
            }
        } catch {
            stopRecognition()
        }
    }

    func stopRecognition() {
        // 音声の取得と認識に使うものをリセットする
        audioEngin?.stop()
        audioEngin?.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        recognitionTask?.finish()
        recognitionTask = nil
        let audioSession = AVAudioSession.sharedInstance()
        try? audioSession.setCategory(.soloAmbient, mode: .default)
        try? audioSession.setActive(false)
        Task { @MainActor in
            isRecognizing = false
        }
    }
}

extension RecognizerViewModel: SFSpeechRecognitionTaskDelegate, SFSpeechRecognizerDelegate {
    func speechRecognitionDidDetectSpeech(_ task: SFSpeechRecognitionTask) {
        // 初めて音声を検出
    }

    func speechRecognitionTaskFinishedReadingAudio(_ task: SFSpeechRecognitionTask) {
        // オーディオ入力が終わった
        stopRecognition()
    }

    func speechRecognitionTask(_ task: SFSpeechRecognitionTask, didHypothesizeTranscription transcription: SFTranscription) {
        // 中間結果を受け取る
        speechResult = transcription.formattedString
    }

    func speechRecognitionTask(_ task: SFSpeechRecognitionTask, didFinishRecognition recognitionResult: SFSpeechRecognitionResult) {
        // 最後の音声が認識された
        // リアルタイムではなく、最終的な認識結果が欲しい場合はこちらから取得
//        speechResult = recognitionResult.bestTranscription.formattedString
    }

    func speechRecognitionTask(_ task: SFSpeechRecognitionTask, didFinishSuccessfully successfully: Bool) {
        // 音声認識が成功で終了したか
        stopRecognition()
    }

    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        // 音声認識の可用性が変更された
        if !available {
            stopRecognition()
        }
    }

    func speechRecognitionTaskWasCancelled(_ task: SFSpeechRecognitionTask) {
        // 音声認識タスクがキャンセルされた
        stopRecognition()
    }
}
