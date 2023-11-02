//
//  AudioManager.swift
//  Music Practice
//
//  Created by William Haslet on 12/14/22.
//

import UIKit
import AVFoundation

class AudioManager {
    var recordingSession: AVAudioSession!
    var whistleRecorder: AVAudioRecorder!
    var controller: DailyRecordingTableViewController!
    var player: AVAudioPlayer! = nil
    var entryName: String!
    var entryPath: String!
    
    func setup(_ controller: DailyRecordingTableViewController) {
        self.controller = controller
        recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        
                    } else {
                        print("recording not allowed")
                    }
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func recordTapped() {
        if whistleRecorder == nil {
            startRecording()
        } else {
            finishRecording(success: true)
        }
    }
    
    private func generatePath() -> URL {
        return getDocumentsDirectory().appendingPathComponent(String(Date.now.timeIntervalSince1970) + ".m4a")
    }
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    private func startRecording() {
        controller.recordButton.setTitle("Finish Recording", for: .normal)
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = DateFormatter.Style.none
        dateFormatter.dateStyle = DateFormatter.Style.short
        entryName = dateFormatter.string(from: Date.now)
        
        let audioURL = generatePath()
        print(audioURL.absoluteString)
        entryPath = audioURL.absoluteString
        
        let settings = [
            AVFormatIDKey: NSNumber(value: kAudioFormatMPEG4AAC as UInt32),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 2
        ]
        
        do {
            whistleRecorder = try AVAudioRecorder(url: audioURL, settings: settings)
            whistleRecorder.delegate = controller
            whistleRecorder.record()
        } catch {
            finishRecording(success: false)
        }
    }
    
    private func finishRecording(success: Bool) {
        controller.recordButton.setTitle("Start Recording", for: .normal)
        
        let duration = Int(whistleRecorder.currentTime.rounded())
        whistleRecorder.stop()
        whistleRecorder = nil
        
        if (success) {
            controller.save(entryName, String(duration), entryPath)
            controller.refreshTable()
        }
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
    
    func playAudio(_ path: String) {
        do {
            try AVAudioSession.sharedInstance().setCategory(
                AVAudioSession.Category.soloAmbient
            )

            try AVAudioSession.sharedInstance().setActive(true)

            player = try AVAudioPlayer(
                contentsOf: URL(string: path)!
            )

            player.play()
        }
        catch {
            print(error.localizedDescription)
        }
    }
}
