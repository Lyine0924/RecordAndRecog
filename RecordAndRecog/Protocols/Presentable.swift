//
//  Presentable.swift
//  RecordAndRecog
//
//  Created by Myeong Soo on 2020/04/29.
//  Copyright © 2020 Kiran Kumar. All rights reserved.
//

import Foundation

// 화면이동이 필요한 뷰 컨트롤러에서 사용할 프로토콜
public protocol Presentable {
    associatedtype Presenter
    var destination:Presenter {get} // 목적지 문자열을 저장할 프로퍼티 segue, storyboard 방식 모두에서 사용
    func display(_ destination:String?)
}
