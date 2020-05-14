//
//  RecordPlayViewController.swift
//  RecordAndRecog
//
//  Created by Myeong Soo on 2020/04/29.
//  Copyright © 2020 Kiran Kumar. All rights reserved.
//

import UIKit
import AVFoundation

class RecordPlayViewController: UIViewController {

    var fileName: String!

    enum PlayerPhase {
        case play
        case pause
    }

    //IBOutlets
    @IBOutlet weak var rewindButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var forwardButton: UIButton!

    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!

    @IBOutlet weak var playProgressView: UIProgressView!

    var playPhase: PlayerPhase = .pause {
        didSet {
            switch playPhase {
            case .play:
                self.playButton.setImage(UIImage.init(named: "icon_pause"), for: .normal)
            case .pause:
                self.playButton.setImage(UIImage.init(named: "icon_play"), for: .normal)
            }
        }
    }

    // 빨리 재생, 뒤로 재생 인터벌
    var interval: TimeInterval = 10.0
    var meterTimer: Timer!

    //변수 및 상수
    var service: LHAudioService! //avaudioplayer인스턴스 변수

    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationTitle()
        initService()
        initLabels()
        initProgressView()
        // Do any additional setup after loading the view.
    }

    private func setNavigationTitle() {
        self.navigationItem.title = fileName
    }


    private func initService() {
        service = LHAudioService.init(fileName: self.fileName)
        service.setPlayer()
        service.delegate = self
    }

    private func initLabels() {
        self.endTimeLabel.text = service.getDuration()
    }

    private func initProgressView() {
        playProgressView.progress = 0.0
    }


//    func initNotification(){
//        NotificationCenter.default.addObserver(self, selector: #selector(_playbackDidStart(_:)), name: PlaybackDidStartNotification, object: player)
//        NotificationCenter.default.addObserver(self, selector: #selector(_playbackDidPause(_:)), name: PlaybackDidPauseNotification, object: player)
//        NotificationCenter.default.addObserver(self, selector: #selector(_playbackDidFinish(_:)), name: PlaybackDidFinishNotification, object: player)
//    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @objc func _metertimerUpdate() {
        updateIndicator()
    }

    func updateIndicator() {
        var result: String = "00:00:00"
        if service.isPlaying() {
            service.updatePlayingMeters()
            result = service.updateAudioMeter()
        } else {
            service.updatePlayingMeters()
            result = service.updateAudioMeter()
        }

        currentTimeLabel.text = result
        playProgressView.progress = service.getProgress()
    }
    
    func audioPlay() {
        switch playPhase {
        case .play:
            service.play()
            meterTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self._metertimerUpdate), userInfo: nil, repeats: true) // 타이머 실행
        case .pause:
            service.pausePlayback()
        }
    }

    @IBAction func playAndPause(_ sender: Any) {
        playPhase = playPhase == .pause ? .play : .pause

        audioPlay()
    }

    @IBAction func rewind(_ sender: Any) {
        switch playPhase {
        case .play:
            service.rewind(interval: self.interval)
            DispatchQueue.main.async {
                self.updateIndicator()
            }
        default:
            break
        }
    }


    @IBAction func forward(_ sender: Any) {
        switch playPhase {
        case .play:
            service.forward(interval: self.interval)
            DispatchQueue.main.async {
                self.updateIndicator()
            }
        default:
            break
        }
    }
}

extension RecordPlayViewController: PlaybackCallBackDelegate {
    func didFinish() {
        print(#function)
        meterTimer.invalidate()
        _metertimerUpdate()
        self.playPhase = .pause
    }

    func didStart() {
        print(#function)
    }

    func didPause() {
        print(#function)
    }
}
