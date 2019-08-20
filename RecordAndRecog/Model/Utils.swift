//
//  Utils.swift
//  RecordAndRecog
//
//  Created by MyeongSoo-Linne on 20/08/2019.
//  Copyright © 2019 Kiran Kumar. All rights reserved.
//

import Foundation

class Utils: NSObject {
    
    static let sharedInstance = Utils()
    
    func time <A> (f: @autoclosure () -> A) -> (result:A, duration: String) {
        let startTime = CFAbsoluteTimeGetCurrent()
        let result = f()
        let endTime = CFAbsoluteTimeGetCurrent()
        return (result, "Elapsed time is \(endTime - startTime) seconds.")
    }
    
}
