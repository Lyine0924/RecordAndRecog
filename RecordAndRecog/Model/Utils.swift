//
//  Utils.swift
//  RecordAndRecog
//
//  Created by MyeongSoo-Linne on 20/08/2019.
//  Copyright © 2019 Kiran Kumar. All rights reserved.
//

import Foundation

enum fileName:String {
    case name = "audioFile"
}

enum fileFormat:String {
    case wav = "wav"
    case mp4 = "mp4"
    case m4a = "m4a"
}

class Utils: NSObject {
    
    static let sharedInstance = Utils()
    
    func time <A> (f: @autoclosure () -> A) -> (result:A, duration: String) {
        let startTime = CFAbsoluteTimeGetCurrent()
        let result = f()
        let endTime = CFAbsoluteTimeGetCurrent()
        return (result, "Elapsed time is \(endTime - startTime) seconds.")
    }
    
    //MARK: - Utilities
    func getDocumentDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func getFullPath(forFilename : String) -> URL{
        let audioFullFilename = getDocumentDirectory().appendingPathComponent(forFilename)
        return audioFullFilename
    }
    
    func getFileList(type: String)->[String]? {
        
        var fileList = [String]()
        // Get the document directory url
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        do {
            // Get the directory contents urls (including subfolders urls)
            let directoryContents = try FileManager.default.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil, options: [])
            print(directoryContents)
            
            // if you want to filter the directory contents you can do like this:
            let Files = directoryContents.filter{ $0.pathExtension == "\(type)" }
            debugPrint("\(type) urls:",Files)
            let FileNames = Files.map{ $0.deletingPathExtension().lastPathComponent }
            print("\(type) list:", FileNames)
            
            fileList = FileNames
            
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        return fileList
    }
    
    func removeFile(fileName:String)->Bool{
        let file = getFullPath(forFilename: fileName)
        do {
            try FileManager.default.removeItem(at: file)
            return true
        } catch {
            print(error)
            return false
        }
    }
    
    func fileSize(forURL url: Any) -> Double {
        var fileURL: URL?
        var fileSize: Double = 0.0
        if (url is URL) || (url is String)
        {
            if (url is URL) {
                fileURL = url as? URL
            }
            else {
                fileURL = URL(fileURLWithPath: url as! String)
            }
            var fileSizeValue = 0.0
            try? fileSizeValue = (fileURL?.resourceValues(forKeys: [URLResourceKey.fileSizeKey]).allValues.first?.value as! Double?)!
            if fileSizeValue > 0.0 {
                fileSize = (Double(fileSizeValue) / (1024 * 1024))
            }
        }
        return fileSize
    }
    
    func totalTime(currentTime interval:TimeInterval)->String{
        let hr = Int((interval / 60) / 60)
        let min = Int(interval / 60)
        let sec = Int(interval.truncatingRemainder(dividingBy: 60))
        let totalTimeString = String(format: "%02d:%02d:%02d", hr, min, sec)
        return totalTimeString
    }
    
    func dateFormat()->DateFormatter{
        let formatter: DateFormatter = .init()
        formatter.dateFormat = "yyMMddHHmmss"
        return formatter
    }
    
    func dateString(date:Date)->String{
        let formatter = dateFormat()
        return formatter.string(from: date)
    }
}
