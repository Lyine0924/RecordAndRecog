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

class VoiceService : NSObject {

    private var _soundRecorder : AVAudioRecorder!
    private var _soundPlayer : AVAudioPlayer!
    private var _soundRecognzer: SFSpeechRecognizer!
    private var _audioSession = AVAudioSession.sharedInstance()
    
    private var FILE_NAME = fileName.RawValue()
    private var FILE_FORMAT = fileFormat.wav
    
    private var duration : TimeInterval!
    
    private var _playbackVolume : Float = 1.0
    private var _isPaused : Bool = false
    
    static let sharedInstance = VoiceService()
    let utils : Utils = Utils.sharedInstance
    
    private override init() { // Is it that easy to make the init private?
        
        super.init()
        setUpRecorder()
//        setUpPlayer()
        
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
        let audioFilename = utils.getFullPath(forFilename: "\(FILE_NAME).\(FILE_FORMAT.rawValue)")
        let recordSettings = [AVFormatIDKey : kAudioFormatLinearPCM,
                              AVLinearPCMBitDepthKey : 16,
                              AVNumberOfChannelsKey : 2,
                              AVSampleRateKey : 16000,
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
    
    func setUpPlayer() {
        let audioFilename = utils.getFullPath(forFilename: "\(FILE_NAME).\(FILE_FORMAT.rawValue)")
        do {
            _soundPlayer = try AVAudioPlayer(contentsOf: audioFilename,fileTypeHint:fileFormat.wav.rawValue)
            _soundPlayer.delegate = self
            _soundPlayer.prepareToPlay()
            _soundPlayer.volume = _playbackVolume
        } catch {
            print(error)
        }
    }
    
    func setPlayerFile(name:String) {
        let audioFilename = utils.getFullPath(forFilename: "\(name)")
        do {
            _soundPlayer = try AVAudioPlayer(contentsOf: audioFilename)
            _soundPlayer.delegate = self
            _soundPlayer.prepareToPlay()
            _soundPlayer.volume = _playbackVolume
        } catch {
            print(error)
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
    
    //MARK: Playback
    func play() {
        _soundPlayer.play()
        //_soundPlayer.play(atTime: <#T##TimeInterval#>) 음성 인식을 분기별로 나눌 수 있을지도 모름.
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
    
    //MARK: update
    func updateRecordingMeters() {
        _soundRecorder.updateMeters()
    }
    
    func updatePlayingMeters(){
        _soundPlayer.updateMeters()
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
                
                self._soundRecognzer = SFSpeechRecognizer(locale: Locale.init(identifier: "ko-KR"))
                
                let request = SFSpeechURLRecognitionRequest(url: self.utils.getFullPath(forFilename: "\(self.FILE_NAME).\(self.FILE_FORMAT.rawValue)"))
                
                self._soundRecognzer?.recognitionTask(with: request, resultHandler: { (result, error) in
                    if let error = error {
                        print("Error recognizing audio: \(error.localizedDescription)")
                    } else {
                        if let transcribedText = result?.bestTranscription.formattedString{
                            let resultWord = String(describing: transcribedText)
                            recognizedText = resultWord
                            print("recognitionWord is : \(recognizedText)")
                        } else {
                            let resultWord = "The transcribed text has not available"
                            //self._recognizedText = resultWord
                            recognizedText = resultWord
                        }
                        completion(recognizedText) // 인식된 글자를 전달
                    }
                }) //end of recognitionTask
            } else {
                print("There is not authtorization to access Speech Framework")
            }
        }
    }
    
    // MARK: - Extra function
    func updateAudioMeter() -> String
    {
        if _soundRecorder.isRecording
        {
            return totalTime(currentTime: _soundRecorder.currentTime)
        }
        else if _soundPlayer.isPlaying {
            return totalTime(currentTime: _soundPlayer.currentTime)
        }
        else {
            return totalTime(currentTime: 0)
        }
    }
    
    private func totalTime(currentTime interval:TimeInterval)->String{
        let hr = Int((interval / 60) / 60)
        let min = Int(interval / 60)
        let sec = Int(interval.truncatingRemainder(dividingBy: 60))
        let totalTimeString = String(format: "%02d:%02d:%02d", hr, min, sec)
//        let totalTimeString = String(format: "%02d:%02d", min, sec)
        return totalTimeString
    }
    
    func renameAudio(newTitle: String) {
        let today: Date = .init()
        
        let dateString = utils.dateString(date: today)
        
        let fileName = "\(newTitle)-\(dateString).\(FILE_FORMAT.rawValue)"  // 20190820 190823-newTitle.m4a
        
        do {
            let originPath = utils.getFullPath(forFilename: "\(FILE_NAME).\(FILE_FORMAT.rawValue)")
            let destinationPath = utils.getFullPath(forFilename:"\(fileName)")
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
    
    public func getDuration()->String{
        print("voice duration is : \(self.duration)")
        return totalTime(currentTime: self.duration)
    }
    
    public func getDuration(fileName: String)->String{
        let audioFilename = utils.getFullPath(forFilename: fileName)
        do {
            let Player = try AVAudioPlayer(contentsOf: audioFilename)
            let duration = utils.totalTime(currentTime: Player.duration)
            Player.prepareToPlay()
            Player.volume = 1.0
            Player.stop() // 메모리 해제를 위함, 추후 음원을 재생시 해당 부분을 삭제 하고 델리게이트 패턴으로 대체할 예정
            return duration
        } catch {
            print(error)
        }
        return utils.totalTime(currentTime: TimeInterval.init())
    }
}

//MARK: - AVAudioRecorderDelegate
extension VoiceService: AVAudioRecorderDelegate{
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        setUpPlayer()
        NotificationCenter.default.post(name: RecordingDidFinishNotification, object: self)
    }
}

//MARK: - AVAudioPlayerDelegate
extension VoiceService: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        _isPaused = false
        NotificationCenter.default.post(name: PlaybackDidFinishNotification, object: self)
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
