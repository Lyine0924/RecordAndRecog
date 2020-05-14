//
//  Record.swift
//  RecordAndRecog
//
//  Created by MyeongSoo-Linne on 04/09/2019.
//  Copyright © 2019 Kiran Kumar. All rights reserved.
//

import Foundation
import RealmSwift

class Audio: Object {
    @objc dynamic var title = ""
    @objc dynamic var size = 0.0
    @objc dynamic var path:URL?
    @objc dynamic var totalTime = ""
    @objc dynamic var regDate = ""
}
