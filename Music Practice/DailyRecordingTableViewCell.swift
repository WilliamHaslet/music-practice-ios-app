//
//  DailyRecordingTableViewCell.swift
//  Music Practice
//
//  Created by William Haslet on 12/14/22.
//

import UIKit

class DailyRecordingTableViewCell: UITableViewCell {
    @IBOutlet weak var nameText: UILabel!
    @IBOutlet weak var durationText: UILabel!
    var controller: DailyRecordingTableViewController!
    var index: Int!
    
    @IBAction func onClickButton(sender: UIButton) {
        controller.play(index)
    }
    
    func setup(_ controller: DailyRecordingTableViewController, _ index: Int) {
        self.controller = controller
        self.index = index
        
        nameText.text = controller.getName(index)
        durationText.text = controller.getDuration(index) + " seconds"
    }
}
