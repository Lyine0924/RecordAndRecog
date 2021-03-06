//
//  ViewController.swift
//  DemoRecorder
//
//  Created by Kiran Kumar on 3/15/19.
//  Copyright © 2019 Kiran Kumar. All rights reserved.
//

import UIKit
import AVFoundation
import Speech
import RealmSwift

class ViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate { // KRKNOTES - Looks like protocols and superclasses are part of the same list. Here, I'm inheriting from UIViewController and conforming to two protocols

    //MARK: UI var
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var inputValue: UILabel!
    
    @IBOutlet weak var recogTextView: UITextView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var meterTimerLabel : UILabel!
    
    let playImage = UIImage(contentsOfFile:Bundle.main.path(forResource: "play", ofType: "png")!)
    let pauseImage = UIImage(contentsOfFile:Bundle.main.path(forResource: "pause", ofType: "png")!)
    
    let playImageID = "ButtonPlay"
    let pauseImageID = "ButtonPause"
    let tutorialText = "녹음 후 재생버튼을 누르면 텍스트 변환 결과를 확인할 수 있습니다."
    
    
    //MARK: VoiceService Var
    var recorderAndPlayer : VoiceService = VoiceService.sharedInstance
    var utils : Utils = Utils.sharedInstance
    var timer : Timer! // db values
    var meterTimer:Timer! // 파일 녹음 시간
    
    let DEFAULT_FILE_NAME = fileName.RawValue()//"audioFile"
    let FILE_FORMAT = fileFormat.wav
    //let DEFAULT_PATH:URL?
    
    // MARK: - View Override function
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        initNotification()
        recorderAndPlayer.setUpPlayer()
    }
    
    //MARK: - init
    func initUI(){
        playPauseButton.isEnabled = false
        playPauseButton.accessibilityIdentifier = playImageID
        stopButton.isEnabled = false
        inputValue.isHidden = true
    }
    
    func initNotification(){
        NotificationCenter.default.addObserver(self, selector: #selector(_recordingDidStart(_:)), name: RecordingDidStartNotification, object: recorderAndPlayer)
        NotificationCenter.default.addObserver(self, selector: #selector(_recordingDidFinish(_:)), name: RecordingDidFinishNotification, object: recorderAndPlayer)
        NotificationCenter.default.addObserver(self, selector: #selector(_playbackDidStart(_:)), name: PlaybackDidStartNotification, object: recorderAndPlayer)
        NotificationCenter.default.addObserver(self, selector: #selector(_playbackDidPause(_:)), name: PlaybackDidPauseNotification, object: recorderAndPlayer)
        NotificationCenter.default.addObserver(self, selector: #selector(_playbackDidFinish(_:)), name: PlaybackDidFinishNotification, object: recorderAndPlayer)
    }
    
    //MARK: IBActions
    @IBAction func recordTouchUp(_ sender: Any) {
        recorderAndPlayer.record()
        saveButton.isEnabled = false
    }
    
    @IBAction func playPauseTouchUp(_ sender: Any) {
        let identifier = playPauseButton.accessibilityIdentifier!
        if (identifier.elementsEqual(playImageID)) {
            print(recorderAndPlayer.isRecording())
            recorderAndPlayer.play()
            meterTimer =  Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self._metertimerUpdate),userInfo: nil,repeats: true)
//            recorderAndPlayer.recognizeSpeech() { recognizedText in
//                DispatchQueue.main.async {
//                    self.recogTextView.text = recognizedText
//                }
//            }
        } else if (identifier.elementsEqual(pauseImageID)) {
            recorderAndPlayer.pausePlayback()
        } else {
            assert(false, "ViewController::playPauseTouchUp -> Unexpected button identifier")
        }
    }
    
    @IBAction func stopTouchUp(_ sender: Any) {
        if (recorderAndPlayer.isRecording()) {
            let totalTime = recorderAndPlayer.updateAudioMeter()
            recorderAndPlayer.stopRecording()
            let path = utils.getFullPath(forFilename: "\(DEFAULT_FILE_NAME).\(FILE_FORMAT.rawValue)")
            // 여기에 realm을 등록
//            addAudio(title: DEFAULT_FILE_NAME, totalTime:totalTime, size: utils.fileSize(forURL: path), path: path)
            saveButton.isEnabled = true
            //saveFile()
            meterTimer.invalidate()
        }
        else if (recorderAndPlayer.isPlaying() || recorderAndPlayer.isPaused()) {
            recorderAndPlayer.stopPlayback()
        }
    }
    
    @IBAction func save(_ sender: Any) {
        saveFile()
    }
    
    func saveFile(){
        /* 파일 이름을 변경하시겠습니까?
         default : audioFile, Yes or No
         No ==> 바로 저장, 저장완료 알림 띄우기
         Yes ==> 새로운 커스텀 알림창 -> Label 확인, 취소 버튼 ==> 완료시, 취소시 알림.
         */
        let alert = UIAlertController(title: "저장 하기", message: "저장할 파일명을 입력해주세요.", preferredStyle: .alert)
        
        alert.addTextField { (tf) in
            tf.placeholder = "\(self.DEFAULT_FILE_NAME)"
        }
        
        let ok = UIAlertAction(title: "저장", style: .default) { (ok) in
            var rename = alert.textFields?[0].text
            if rename!.isEmpty {
                rename = "\(self.DEFAULT_FILE_NAME)"
            }
            self.recorderAndPlayer.renameAudio(newTitle:rename!)
//            self.updateAudio(title: rename!)
            print("saved!!")
        }
        
        let cancel = UIAlertAction(title: "취소", style: .cancel)
        
        alert.addAction(ok)
        alert.addAction(cancel)
        
        self.saveButton.isEnabled = false
        
        self.present(alert, animated: false)
    }
    
    //MARK: Notification Responders
    @objc func _recordingDidStart(_ notification:Notification) {
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(_timerUpdate), userInfo: nil, repeats: true)
        timer.tolerance = 0.05
        meterTimer =  Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self._metertimerUpdate),userInfo: nil,repeats: true) // 타이머 실행
        
        playPauseButton.isEnabled = false
        recordButton.isEnabled = false
        stopButton.isEnabled = true
    }
    
    @objc func _recordingDidFinish(_ notification:Notification) {
        timer.invalidate()
        meterTimer.invalidate()
        
        recordButton.isEnabled = true
        playPauseButton.isEnabled = true
        stopButton.isEnabled = false
    }
    
    @objc func _playbackDidStart(_ notification:Notification) {
        recordButton.isEnabled = false
        updateButton(button : playPauseButton, image: pauseImage!, identifer: pauseImageID)
        stopButton.isEnabled = true
    }
    
    @objc func _playbackDidPause(_ notification:Notification) {
        updateButton(button : playPauseButton, image: playImage!, identifer: playImageID)
    }
    
    @objc func _playbackDidFinish(_ notification:Notification) {
        meterTimer.invalidate()
        _metertimerUpdate()
        updateButton(button : playPauseButton, image: playImage!, identifer: playImageID)
        self.recogTextView.text = tutorialText
        recordButton.isEnabled = true;
        stopButton.isEnabled = false
    }
    
    //MARK: - Other
    func updateButton(button : UIButton, image : UIImage, identifer : String) {
        button.setImage(image, for: .normal)
        button.accessibilityIdentifier = identifer
    }
    
    //MARK: - Timer
    @objc func _timerUpdate() {
        recorderAndPlayer.updateRecordingMeters()
        let levels : [Float] = recorderAndPlayer.getMeterLevel()
        inputValue.text = String(format: "%.2f", levels[0]) + " dB"
    }
    
    @objc func _metertimerUpdate(){
        var result: String = "00:00"
        if (recorderAndPlayer.isRecording()) {
            recorderAndPlayer.updateRecordingMeters()
            result = recorderAndPlayer.updateAudioMeter()
        }
        else if (recorderAndPlayer.isPlaying()) {
            recorderAndPlayer.updatePlayingMeters()
            result = recorderAndPlayer.updateAudioMeter()
        }
        meterTimerLabel.text = result
    }
    
    //title, path 는 혹시 몰라서.
    func addAudio(title:String,totalTime:String,size:Double,path:URL){
        let audio = Audio()
        audio.title = title
        audio.totalTime = totalTime
        audio.size = size
        audio.path = path
        audio.regDate = utils.dateString(date: Date.init())
        
        let realm = try! Realm()
        try! realm.write {
            realm.add(audio)
            print("realm create success")
        }
    }
    
    func updateAudio(title:String,path:URL){
        let audioFilename = utils.getFullPath(forFilename: "\(DEFAULT_FILE_NAME).\(FILE_FORMAT.rawValue)")
        let realm = try! Realm()
        let audio = realm.objects(Audio.self).filter("path == \(audioFilename)").first
        try! realm.write {
            audio?.title = title
            audio?.path = path
            print("realm update success")
        }
    }
    
    func updateAudio(title:String){
        let audioFilename = utils.getFullPath(forFilename: "\(DEFAULT_FILE_NAME).\(FILE_FORMAT.rawValue)")
        let realm = try! Realm()
        let audio = realm.objects(Audio.self).filter("path == \(audioFilename)").first
        try! realm.write {
            audio?.title = title
//            audio?.path = path
            print("realm update success")
        }
    }
}
