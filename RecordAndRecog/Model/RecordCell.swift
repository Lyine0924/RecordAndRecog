//
//  RecordCell.swift
//  RecordAndRecog
//
//  Created by MyeongSoo-Linne on 26/08/2019.
//  Copyright © 2019 Kiran Kumar. All rights reserved.
//

import UIKit
import AVFoundation

class RecordCell: UITableViewCell {

    @IBOutlet weak var fileNameLabel: UILabel!
    @IBOutlet weak var duration: UILabel!
    @IBOutlet weak var fileSizeLabel: UILabel!
    

    let utils : Utils = Utils.sharedInstance
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    /*
     음원 파일을 정보를 가져오기 위해 임시 플레이어 객체를 생성해서, 파일 재생 시간을 가져옴
     파일이 많아지면 플레이어가 차지하는 메모리 양이 많아질 수 있으므로, 메모리 해제 관련 로직을 만들 필요가 있어보임.
     */
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
