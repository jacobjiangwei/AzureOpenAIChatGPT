//
//  AudioRecorder.swift
//  WholeDaySummary
//
//  Created by jacob on 2023/5/23.
//

import Foundation

import AVFoundation

class AudioRecorder: NSObject, AVAudioRecorderDelegate {
    static let shared = AudioRecorder()
    var dataPath:URL!
    private var audioRecorder: AVAudioRecorder!

    private override init() {
        super.init()
    }

    func startRecording(_ fileName: String) {
        do {

            let settings = [
                AVFormatIDKey: Int(kAudioFormatLinearPCM),
                AVSampleRateKey: 16000,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]

            let audioFilename = getDocumentsDirectory().appendingPathComponent("\(fileName).wav")

            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
        } catch {
            print("Error while starting recording: \(error)")
        }
    }

    func stopRecording() {
        if audioRecorder == nil { return }
        audioRecorder.stop()
        audioRecorder = nil
    }

    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }

    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            print("Recording successfully saved. \(recorder.url)")
        } else {
            print("Recording failed.")
        }
    }

    
}
