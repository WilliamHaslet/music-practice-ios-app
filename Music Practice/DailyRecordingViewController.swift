//
//  DailyRecordingViewController.swift
//  Music Practice
//
//  Created by William Haslet on 12/14/22.
//

import UIKit
import CoreData
import AVFoundation

class DailyRecordingTableViewController: UITableViewController, AVAudioRecorderDelegate {
    @IBOutlet weak var recordButton: UIButton!
    var recordings: [NSManagedObject] = []
    let audioManager = AudioManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        audioManager.setup(self)
        //deleteAllrecordings()
        //save("test test tes", "33:300")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Recording")

        do {
            recordings = try managedContext.fetch(fetchRequest)
        }
        catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recordings.count;
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let itemCell = tableView.dequeueReusableCell(withIdentifier: "RecordingCell", for: indexPath) as! DailyRecordingTableViewCell
        itemCell.setup(self, (recordings.count - 1) - indexPath.row)
        return itemCell
    }
    
    func save(_ name: String, _ duration: String, _ path: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }

        let managedContext = appDelegate.persistentContainer.viewContext

        let entity = NSEntityDescription.entity(forEntityName: "Recording", in: managedContext)!

        let recording = NSManagedObject(entity: entity, insertInto: managedContext)

        recording.setValue(name, forKeyPath: "name")
        recording.setValue(duration, forKeyPath: "duration")
        recording.setValue(path, forKeyPath: "path")
        
        do {
            try managedContext.save()
            recordings.append(recording)
        }
        catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func refreshTable() {
        tableView.reloadData()
    }
    
    func deleteAllrecordings() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Recording")
        
        do {
            recordings = try managedContext.fetch(fetchRequest)
            for recording in recordings
            {
                managedContext.delete(recording)
            }
            
            recordings.removeAll()
            try managedContext.save()
        }
        catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func getName(_ index: Int) -> String {
        let recording = recordings[index]
        return recording.value(forKeyPath: "name") as! String
    }
    
    func getDuration(_ index: Int) -> String {
        let recording = recordings[index]
        return recording.value(forKeyPath: "duration") as! String
    }
    
    @IBAction func pressRecordButton(_ sender: UIButton) {
        audioManager.recordTapped()
    }
    
    func play(_ index: Int) {
        let recording = recordings[index]
        let path = recording.value(forKeyPath: "path") as! String
        audioManager.playAudio(path)
    }
}
