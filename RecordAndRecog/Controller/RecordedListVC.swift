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
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    
    override func viewWillAppear(_ animated: Bool) {
        list.removeAll()
        list = utils.getFileList(type: FILE_TYPE.rawValue)!
        self.tableView.reloadData()
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
        let newURL = utils.getFullPath(forFilename: "\(filename).\(FILE_TYPE)")
        
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "recordCell", for: indexPath)
        
        cell.textLabel?.text = "\(list[indexPath.row])"
        // Configure the cell...

        return cell
    }
 

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
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
