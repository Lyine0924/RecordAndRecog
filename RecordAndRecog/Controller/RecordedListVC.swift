//
//  RecordedListVC.swift
//  RecordAndRecog
//
//  Created by MyeongSoo-Linne on 20/08/2019.
//  Copyright © 2019 Kiran Kumar. All rights reserved.
//

import UIKit
import AudioKit

class RecordedListVC: UITableViewController {
    
    let utils: Utils = Utils.sharedInstance
    let FILE_TYPE = fileFormat.wav
    var list = [String]()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        list = utils.getFileList(type: FILE_TYPE.rawValue)!
        //list = utils.getFileList(type: "wav")!
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    
    override func viewWillAppear(_ animated: Bool) {
        if(list.count > 0){
            print("View will Appear called!")
            list.removeAll()
            list = utils.getFileList(type: FILE_TYPE.rawValue)!
            self.tableView.reloadData()
        }
    }
    
    // MARK: - conver to fileformat
    
    @IBAction func convertTo(_ sender: Any) {
        self.convert(filename: "test")
    }
    
    // convert to file into wav , caf ,
    func convert(filename:String) {
        var options = AKConverter.Options()
        options.format = FILE_TYPE.rawValue
        options.sampleRate = 48000
        options.bitDepth = 24
        
        //let testname = "20190820-test"
        
        let oldURL = utils.getFullPath(forFilename: "\(filename).m4a")
        //let newURL = utils.getFullPath(forFilename: "\(testname).\(options.format)")
        let newURL = utils.getFullPath(forFilename: "\(filename)\(FILE_TYPE.rawValue)")
        
        let converter = AKConverter(inputURL: oldURL, outputURL: newURL)
        
        converter.start(completionHandler: { error in
            print("error is occured : \(error?.localizedDescription)")
        })
    }
    
// MARK: - Table view data source

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 1
//    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return list.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "recordCell", for: indexPath) as! RecordCell
        
        let fileName = "\(list[indexPath.row]).\(FILE_TYPE.rawValue)"
        
        cell.fileNameLabel.text = fileName
        cell.duration.text = cell.getDuration(fileName: fileName)
        // Configure the cell...
        return cell
    }
 
    
    
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
         if editingStyle == .delete {
         // Delete the row from the data source
         // 파일을 제거 할 때 인덱스의 순서 주의!
         /*
             tableView.deleteRows을 먼저 실행하게 되면 indexPath.row가 1 감소하게 되므로,
             내가 원하는 로직을 구현하는데 애로사항이 생기게 됨.
         */
         let filename = "\(list[indexPath.row]).\(FILE_TYPE.rawValue)"
         if utils.removeFile(fileName: filename) {
                list.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
         } else if editingStyle == .insert {
         // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
         }
     }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    

}
