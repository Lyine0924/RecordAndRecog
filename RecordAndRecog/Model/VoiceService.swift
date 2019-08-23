//
//  VoiceService.swift
//  RecordAndRecog
//
//  Created by Lyine on 8/19/19.
//  Copyright © 2019 Kiran Kumar. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import Speech

let RecordingDidStartNotification = Notification.Name("RecordingDidStart")
let RecordingDidFinishNotification = Notification.Name("RecordingDidFinish")
let PlaybackDidStartNotification = Notification.Name("PlaybackDidStart")
let PlaybackDidPauseNotification = Notification.Name("PlaybackDidPause")
let PlaybackDidFinishNotification = Notification.Name("PlaybackDidFinish")

class VoiceService : NSObject, AVAudioRecorderDelegate, AVAudioPlayerDelegate {

    private var _soundRecorder : AVAudioRecorder!
    private var _soundPlayer : AVAudioPlayer!
    private var _soundRecognzer: SFSpeechRecognizer!
    private var _audioSession = AVAudioSession.sharedInstance()
    private var _filename = "audioFile.wav"
//    private var _filename = "audioFile.acc"
    private var _playbackVolume : Float = 1.0
    private var _isPaused : Bool = false
    
    static let sharedInstance = VoiceService()
    let utils : Utils = Utils.sharedInstance
    
    private override init() { // Is it that easy to make the init private?
        
        super.init()
        setUpRecorder()
        setUpPlayer()
        
        /* Initially, I got the following errors everytime I try to play back recorded audio the FIRST TIME ONLY after launching my app:
         DemoRecorder[5930:2262392] [avas] AVAudioSessionPortImpl.mm:56:ValidateRequiredFields: Unknown selected data source for Port Speaker (type: Speaker)
         DemoRecorder[5930:2262392] [avas] AVAudioSessionPortImpl.mm:56:ValidateRequiredFields: Unknown selected data source for Port Receiver (type: Receiver)
         
         These errors would show up, and my first segment of recorded audio would not play back. Subsequent segments would work just fine
         
         The fix below (from https://forums.developer.apple.com/thread/108785) does not get rid of the errors, but it DOES fix the issues that initially prevented me from playing back my first recording. Additionally, it significantly raises the playback volume.
         
         I don't know what these two lines really do. I'll have to investigate
         */
        do {
            try _audioSession.setCategory(AVAudioSession.Category.playAndRecord, mode: .measurement, options: .defaultToSpeaker)
            try _audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
    }
    
    // default
    /*
     1.
     let recordSettings = [AVFormatIDKey : kAudioFormatMPEG4AAC,
     AVEncoderAudioQualityKey : AVAudioQuality.max.rawValue,
     AVNumberOfChannelsKey : 2,
     AVSampleRateKey : 44100.0]
     as [String : Any]
     
     2.
     let recordSettings = [AVFormatIDKey : kAudioFormatLinearPCM,
     AVLinearPCMBitDepthKey : 8,
     AVNumberOfChannelsKey : 1,
     AVSampleRateKey : 600.0]
     as [String : Any]
     
     let recordSettings = [AVFormatIDKey : kAudioFormatLinearPCM,
     AVLinearPCMBitDepthKey : 16,
     AVNumberOfChannelsKey : 2,
     AVSampleRateKey : 44100.0,
     AVLinearPCMIsBigEndianKey:true,
     AVLinearPCMIsFloatKey:true]
     as [String : Any]
     
     3.
     let recordSettings = [AVFormatIDKey : kAudioFormatMPEG4AAC,
     AVEncoderAudioQualityKey : AVAudioQuality.max.rawValue,
     AVNumberOfChannelsKey : 1,
     AVSampleRateKey : 12000.0]
     as [String : Any]
     
     음질에 따라 음성 인식률 달라짐 : 1 >>> 3 >> 2 순임
     파일 사이즈(앞쪽이 작은것) : 2 >> 3 >>> 1
     */
    
    private func setUpRecorder() {
        let audioFilename = utils.getFullPath(forFilename: _filename)
        let recordSettings = [AVFormatIDKey : kAudioFormatLinearPCM,
                              AVLinearPCMBitDepthKey : 16,
                              AVNumberOfChannelsKey : 2,
                              AVSampleRateKey : 44100.0,
                              AVLinearPCMIsBigEndianKey:true,
                              AVLinearPCMIsFloatKey:true]
            as [String : Any]
        
        do {
            _soundRecorder = try AVAudioRecorder(url: audioFilename, settings: recordSettings)
            _soundRecorder.delegate = self
            _soundRecorder.prepareToRecord()
            _soundRecorder.isMeteringEnabled = true
        } catch {
            print(error)
        }
    }
    
    private func setUpPlayer() {
        let audioFilename = utils.getFullPath(forFilename: _filename)
        do {
            _soundPlayer = try AVAudioPlayer(contentsOf: audioFilename)
            _soundPlayer.delegate = self
            _soundPlayer.prepareToPlay()
            _soundPlayer.volume = _playbackVolume
        } catch {
            print(error)
        }
    }
    
    // MARK: recognizeSpeech
    // recognitionTask 함수가 비동기로 실행이 되는듯
    /* 함수 return 시점 이전에 위의 태스크가 완료가 되지 않기 때문에 -> return String 의 형식으로는 인식된 글자를 전달 할 수 없음
       내가 해결한 방법 : Task 가 끝나는 시점을 명확히 알려주기 위해 클로져 구문을 사용하였음. 위 방법이 맞는지는 추후 연구해 볼 것.
     */
    func recognizeSpeech(completion:@escaping (String)->Void){
        
        var recognizedText = "" // 인식된 음성을 문자열로 받을 변수
        
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            if authStatus == SFSpeechRecognizerAuthorizationStatus.authorized {
                
                //let recognizer = SFSpeechRecognizer()
                self._soundRecognzer = SFSpeechRecognizer(locale: Locale.init(identifier: "ko-KR"))
                let request = SFSpeechURLRecognitionRequest(url: self.utils.getFullPath(forFilename: self._filename))
                
                self._soundRecognzer?.recognitionTask(with: request, resultHandler: { (result, error) in
                    if let error = error {
                        //print("Error recognizing audio: \(error.localizedDescription)")
                        print("Error recognizing audio: \(error.localizedDescription)")
                    } else {
                        if let transcribedText = result?.bestTranscription.formattedString{
                            let resultWord = String(describing: transcribedText)
                            //self._recognizedText = resultWord
                            recognizedText = resultWord
                            //print("recognitionWord is : \(self.recognizedText)")
                            print("recognitionWord is : \(recognizedText)")
                        } else {
                            let resultWord = "The transcribed text has not available"
                            //self._recognizedText = resultWord
                            recognizedText = resultWord
                        }
                        completion(recognizedText) // 최종 텍스트를 결과로 내보냄
                    }
                })
            } else {
                //print("There is not authtorization to access Speech Framework")
                print("There is not authtorization to access Speech Framework")
            }
        }
    }
    

    //MARK: Recording
    func record() {
        _soundRecorder.record()
        NotificationCenter.default.post(name: RecordingDidStartNotification, object: self)
    }
    
    func stopRecording() {
        //var checkTime = ""
        print(Utils.sharedInstance.time(f: _soundRecorder.stop()))
    }
    
    func isRecording() -> Bool {
        return _soundRecorder.isRecording
    }
    
    func updateRecordingMeters() {
        _soundRecorder.updateMeters()
    }
    
    func updatePlayingMeters(){
        _soundPlayer.updateMeters()
    }
    
    //MARK: Playback
    func play() {
        _soundPlayer.play()
        //print("voice duration is : \(_soundPlayer.duration)")
        _isPaused = false
        
        
        NotificationCenter.default.post(name: PlaybackDidStartNotification, object: self)
    }
    
    func pausePlayback() {
        _soundPlayer.pause()
        _isPaused = true
        NotificationCenter.default.post(name: PlaybackDidPauseNotification, object: self)
    }
    
    func isPaused() -> Bool {
        return _isPaused
    }
    
    func stopPlayback() {
        _soundPlayer.stop()
        _soundPlayer.currentTime = 0
        _isPaused = false
        NotificationCenter.default.post(name: PlaybackDidFinishNotification, object: self)
    }
    
    func isPlaying() -> Bool {
        return _soundPlayer.isPlaying
    }

    //MARK: - AVAudioRecorderDelegate
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        setUpPlayer()
        NotificationCenter.default.post(name: RecordingDidFinishNotification, object: self)
    }
    
    //MARK: - AVAudioPlayerDelegate
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        _isPaused = false
        NotificationCenter.default.post(name: PlaybackDidFinishNotification, object: self)
    }
    
    
    func updateAudioMeter() -> String
    {
        if _soundRecorder.isRecording
        {
            let hr = Int((_soundRecorder.currentTime / 60) / 60)
            let min = Int(_soundRecorder.currentTime / 60)
            let sec = Int(_soundRecorder.currentTime.truncatingRemainder(dividingBy: 60))
            let totalTimeString = String(format: "%02d:%02d:%02d", hr, min, sec)
            //recordingTimeLabel.text = totalTimeString
            //_soundRecorder.updateMeters()
            return totalTimeString
        }
        else if _soundPlayer.isPlaying {
            let hr = Int((_soundPlayer.currentTime / 60) / 60)
            let min = Int(_soundPlayer.currentTime / 60)
            let sec = Int(_soundPlayer.currentTime.truncatingRemainder(dividingBy: 60))
            let totalTimeString = String(format: "%02d:%02d:%02d", hr, min, sec)
            //recordingTimeLabel.text = totalTimeString
            //_soundRecorder.updateMeters()
            return totalTimeString
        }
        else {
            return String(format: "%02d:%02d:%02d", 0, 0, 0)
        }
    }
    
    func renameAudio(newTitle: String) {
        let today: Date = .init()
        let formatter: DateFormatter = .init()
        formatter.dateFormat = "yyyyMMdd HH:mm:ss"
        let dateString = formatter.string(from: today)
        
        let fileName = dateString + "-" + newTitle // 20190820-newTitle.m4a
        
        do {
//            let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
//            let documentDirectory = URL(fileURLWithPath: path)
//            let originPath = documentDirectory.appendingPathComponent(_filename)
//            let destinationPath = documentDirectory.appendingPathComponent("\(newTitle).m4a")
            let documentDirectory = utils.getDocumentDirectory()
            let originPath = utils.getFullPath(forFilename: _filename)
            let destinationPath = utils.getFullPath(forFilename:"\(fileName).wav")
            try FileManager.default.moveItem(at: originPath, to: destinationPath)
        } catch {
            print(error)
        }
    }
    
    func getMeterLevel() -> [Float] {
        var dbArray : [Float] = []
        let settings = _soundRecorder.settings
        let numChannels : Int = settings[AVNumberOfChannelsKey] as! Int
        for ch in 0...numChannels-1 {
            dbArray.append(_soundRecorder.averagePower(forChannel: ch))
        }
        return dbArray
    }
    
}

// MARK: - SFSpeechRecognitionTaskDelegate -
extension VoiceService: SFSpeechRecognitionTaskDelegate {
    public func speechRecognitionTask(_ task: SFSpeechRecognitionTask, didFinishSuccessfully successfully: Bool) {
        print("didFinishSuccessfully: \(successfully)")
    }
    
    func speechRecognitionTask(_ task: SFSpeechRecognitionTask, didHypothesizeTranscription transcription: SFTranscription) {
        print(transcription.formattedString)
    }
}

// MARK: - SFSpeechRecognizerDelegate -
extension VoiceService: SFSpeechRecognizerDelegate {
    public func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            print("Start Recognition")
        } else {
            print("Recognition not available")
        }
    }
}
