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

class ViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate { // KRKNOTES - Looks like protocols and superclasses are part of the same list. Here, I'm inheriting from UIViewController and conforming to two protocols

    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var inputValue: UILabel!
    
    @IBOutlet weak var recogTextView: UITextView!
    @IBOutlet weak var saveButton: UIButton!
    
    
    
    var recorderAndPlayer : VoiceService = VoiceService.sharedInstance
    var utils : Utils = Utils.sharedInstance
    
    var timer : Timer!
    
    let playImage = UIImage(contentsOfFile:Bundle.main.path(forResource: "play", ofType: "png")!)
    let pauseImage = UIImage(contentsOfFile:Bundle.main.path(forResource: "pause", ofType: "png")!)
    
    let playImageID = "ButtonPlay"
    let pauseImageID = "ButtonPause"
    
 
    override func viewDidLoad() {
        super.viewDidLoad()
       
        playPauseButton.isEnabled = false
        playPauseButton.accessibilityIdentifier = playImageID
        stopButton.isEnabled = false
        
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
            recorderAndPlayer.play()
            recorderAndPlayer.recognizeSpeech() { recognizedText in
                DispatchQueue.main.async {
                    self.recogTextView.text = recognizedText
                }
            }
        } else if (identifier.elementsEqual(pauseImageID)) {
            recorderAndPlayer.pausePlayback()
        } else {
            assert(false, "ViewController::playPauseTouchUp -> Unexpected button identifier")
        }
    }
    
    @IBAction func stopTouchUp(_ sender: Any) {
        if (recorderAndPlayer.isRecording()) {
            recorderAndPlayer.stopRecording()
            saveButton.isEnabled = true
        }
        else if (recorderAndPlayer.isPlaying() || recorderAndPlayer.isPaused()) {
            recorderAndPlayer.stopPlayback()
        }
    }
    
    @IBAction func save(_ sender: Any) {
        // 이 버튼을 눌렀을 때, 알림창을 띄워줌
        /* 파일 이름을 변경하시겠습니까?
         default : audioFile, Yes or No
         No ==> 바로 저장, 저장완료 알림 띄우기
         Yes ==> 새로운 커스텀 알림창 -> Label 확인, 취소 버튼 ==> 완료시, 취소시 알림.
         */
        let alert = UIAlertController(title: "저장 하기", message: "변경할 파일명을 입력해주세요.", preferredStyle: .alert)
        
        alert.addTextField { (tf) in
            tf.placeholder = "audioFile"
        }
        
        let ok = UIAlertAction(title: "저장", style: .default) { (ok) in
            var rename = alert.textFields?[0].text
            if rename!.isEmpty {
                rename = "audioFile"
            }
           self.recorderAndPlayer.renameAudio(newTitle:rename!)
        }
        
        let cancel = UIAlertAction(title: "취소", style: .cancel)
        
        alert.addAction(ok)
        alert.addAction(cancel)
        
        self.saveButton.isEnabled = false
        
        self.present(alert, animated: false) {
            print("saved!!")
        }
    }
    
    
    //MARK: Notification Responders
    @objc func _recordingDidStart(_ notification:Notification) {
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(_timerUpdate), userInfo: nil, repeats: true)
        timer.tolerance = 0.05
        playPauseButton.isEnabled = false
        recordButton.isEnabled = false
        stopButton.isEnabled = true
    }
    
    @objc func _recordingDidFinish(_ notification:Notification) {
        timer.invalidate()
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
        updateButton(button : playPauseButton, image: playImage!, identifer: playImageID)
        recordButton.isEnabled = true;
        stopButton.isEnabled = false
    }
    
    //MARK: - Other
    func updateButton(button : UIButton, image : UIImage, identifer : String) {
        button.setImage(image, for: .normal)
        button.accessibilityIdentifier = identifer
    }
    
    @objc func _timerUpdate() {
        recorderAndPlayer.updateRecordingMeters()
        let levels : [Float] = recorderAndPlayer.getMeterLevel()
        inputValue.text = String(format: "%.2f", levels[0]) + " dB"
    }
}
