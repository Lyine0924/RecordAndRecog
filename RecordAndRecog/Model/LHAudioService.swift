//
//  LHAudioPlayer.swift
//  RecordAndRecog
//
//  Created by Myeong Soo on 2020/04/29.
//  Copyright © 2020 Kiran Kumar. All rights reserved.
//

import Foundation
import AVFoundation

protocol PlaybackCallBackDelegate {
    func didFinish()
    func didStart()
    func didPause()
}

class LHAudioService: NSObject {

    private var player: AVAudioPlayer!
    private var session = AVAudioSession.sharedInstance()
    
    let utils: Utils = Utils.sharedInstance

    private var fileName: String?
    private var playbackVolume: Float = 10.0
    
    private var isPaused: Bool = true

    var delegate: PlaybackCallBackDelegate?

    init(fileName: String) {
        self.fileName = fileName

        do {
            try session.setCategory(AVAudioSession.Category.playAndRecord, mode: .measurement, options: .defaultToSpeaker)
            try session.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
    }

    func setPlayer() {
        guard let name = self.fileName else {
            return
        }
        
        let audioURLPath = utils.getFullPath(forFilename: "\(name)")
        do {
            player = try AVAudioPlayer(contentsOf: audioURLPath)
            player.delegate = self
            player.prepareToPlay()
            player.volume = playbackVolume
        } catch {
            print(error.localizedDescription)
        }
    }

    func setVoulme(value: Float) {
        self.playbackVolume = value
    }
    
    //MARK: Playback
    func play() {
        player.play()
        isPaused = false
        //_soundPlayer.play(atTime: <#T##TimeInterval#>) 음성 인식을 분기별로 나눌 수 있을지도 모름.
        delegate?.didStart()
    }
    
    func pausePlayback() {
        player.pause()
        isPaused = true
        delegate?.didPause()
    }
    
    func stopPlayback() {
        player.stop()
        player.currentTime = 0
        isPaused = false
        delegate?.didFinish()
    }
    
    func rewind(interval: TimeInterval) {
        let wind = player.currentTime - interval
        if wind > 0 {
            player.currentTime = wind
        } else {
            player.currentTime = 0
        }
    }
    
    func forward(interval: TimeInterval) {
        var forward = player.currentTime + interval
        
        if forward > player.duration {
            forward = player.duration
            stopPlayback()
        } else {
            player.currentTime = forward
        }
    }
    
    func isPlaying() -> Bool {
        return player.isPlaying
    }
    
    func updatePlayingMeters(){
        player.updateMeters()
    }

    private func totalTime(currentTime interval: TimeInterval) -> String {
        let hr = Int((interval / 60) / 60)
        let min = Int(interval / 60)
        let sec = Int(interval.truncatingRemainder(dividingBy: 60))
        let totalTimeString = String(format: "%02d:%02d:%02d", hr, min, sec)
        //        let totalTimeString = String(format: "%02d:%02d", min, sec)
        return totalTimeString
    }
    
    public func getProgress() -> Float {
        return Float(player.currentTime / player.duration)
    }
    
    
    public func getDuration() -> String {
        return utils.totalTime(currentTime: player.duration)
    }
    
    // MARK: - Extra function
    func updateAudioMeter() -> String {
        if player.isPlaying {
            return totalTime(currentTime: player.currentTime)
        }
        else {
            return totalTime(currentTime: 0)
        }
    }
}

//MARK: - AVAudioPlayerDelegate
extension LHAudioService: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPaused = false
        delegate?.didFinish()
    }
}
