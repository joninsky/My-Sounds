//
//  RecordViewController.swift
//  MySounds
//
//  Created by Jon Vogel on 1/31/17.
//  Copyright © 2017 Jon Vogel. All rights reserved.
//

import UIKit
import AudioKit
import DZNEmptyDataSet

class RecordViewController: UIViewController {
    //MARK: Properties
    
    @IBOutlet weak var soundWave: EZAudioPlot!
    
    @IBOutlet weak var myTableView: UITableView!
    
    @IBOutlet weak var record: UIButton!
    
    //MARK: Audio Stuff
    var plot: AKNodeOutputPlot?
    
    //MARK: Recording Manager
    let manager = RecordingController()
    
    let fileManager = MyFileManager()
    
    //MARK: Objects needed for recording
    let mic = AKMicrophone()
    var recorder: AVAudioRecorder?
    let session = AVAudioSession.sharedInstance()
    let recordSettings: [String: Any] = [AVSampleRateKey: 12000, AVFormatIDKey: Int(kAudioFormatMPEG4AAC), AVNumberOfChannelsKey: 1, AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue]
    var player: AVAudioPlayer?
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        //Set up table view
        self.myTableView.delegate = self
        self.myTableView.dataSource = self
        self.myTableView.tableFooterView = UIView()
        self.myTableView.emptyDataSetSource = self
        self.myTableView.estimatedRowHeight = 75
        self.myTableView.rowHeight = UITableViewAutomaticDimension
        
        //Set up audio stuff
        do{
            try self.session.setCategory(AVAudioSessionCategoryPlayAndRecord)
        }catch{
            
        }
        self.recorder?.delegate = self
        self.recorder?.prepareToRecord()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AudioKit.start()
        
        //Set up plot
        self.setUpPlot()
       
    }
    
    
    //MARK: Actions
    
    @IBAction func recordLongPress(_ sender: UILongPressGestureRecognizer) {
        
        switch sender.state {
        case .began:
            self.record.setImage(UIImage(named: "Record"), for: UIControlState.normal)
            self.plot?.color = UIColor.green
            
            if let recordingURL = self.fileManager.makeFileForRecording(fileName: "Recording_\(self.manager.recordings.count + 1).m4a") {
                do{
                    try self.recorder = AVAudioRecorder(url: recordingURL, settings: self.recordSettings)
                }catch{
                    AppDelegate.quickAlert("Error", "Failed to start recording: \(error)")
                }
                self.recorder?.delegate = self
                self.recorder?.record()
            }else{
                print("Could not construct URL for recording")
            }
            
        case .ended:
            self.record.setImage(UIImage(named: "StopRecord"), for: UIControlState.normal)
            self.plot?.color = UIColor.red
            self.recorder?.stop()
        default:
            return
        }
    }
    
    func setUpPlot() {
        self.plot = AKNodeOutputPlot(self.mic, frame: self.soundWave.bounds)
        plot?.plotType = .buffer
        plot?.shouldFill = true
        plot?.shouldMirror = true
        plot?.color = UIColor.red
        guard let p = self.plot else {
            return
        }
        self.soundWave.addSubview(p)
    }
    
    
    func configureAudioOutputRoute() {
        
        for outPut in self.session.currentRoute.outputs {
            if outPut.portType == AVAudioSessionPortBuiltInReceiver {
                do{
                    try self.session.overrideOutputAudioPort(.speaker)
                }catch{
                    
                }
            }
        }
    }
    
}

extension RecordViewController: AVAudioRecorderDelegate {
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        
        let newRecording = Recording()
        newRecording.localFileName = recorder.url.lastPathComponent
        newRecording.name = "Recording - \(self.manager.recordings.count + 1)"
        newRecording.recordedDate = Date()
        do{
            try self.manager.addRecording(theRecording: newRecording)
            self.recorder = nil
        }catch{
            AppDelegate.quickAlert("Error", "Failed to add recording to Realm: \(error)")
        }
        
        self.myTableView.reloadData()
        
    }
    
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        
        AppDelegate.quickAlert("Encode Error", "Encoding error from recorder delegate: \(error)")
        
    }
    
}

extension RecordViewController: AVAudioPlayerDelegate {
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        
        self.player = nil
        
    }
    
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        
        AppDelegate.quickAlert("Decode Error", "Decode error from player delegate: \(error)")
        
    }
    
    
}

extension RecordViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.manager.recordings.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let Cell = tableView.dequeueReusableCell(withIdentifier: "RecordingCell") as? RecordCell else {
            return UITableViewCell()
        }
        
        Cell.delegate = self
        Cell.path = indexPath
        
        let recording = self.manager.recordings[indexPath.row]
        
        var string = ""
        
        if let name = recording.name {
            Cell.name.text = "Name: \(name)"
        }else{
            Cell.name.text = "Name: No Name"
        }
        
        if let localURL = recording.localURL?.absoluteString {
            string += "\n\nLocal URL: \(localURL)"
        }else{
            string += "\n\nLocal URL: None"
        }
        
        if let remoteURL = recording.remoteURL?.absoluteString {
            string += "\n\nRemote URL: \(remoteURL)"
        }else{
            string += "\n\nRemote URL: None"
        }
        
        if let date = recording.recordedDate {
            string += "\n\nRecorded at: \(date)"
        }else{
            string += "\n\nRecorded at: Unknown"
        }
        
        if recording.uploaded {
            string += "\n\nUploaded: TRUE"
            Cell.upload.setImage(UIImage(named: "Check"), for: UIControlState.normal)
        }else{
            string += "\n\nUploaded: FALSE"
            Cell.upload.setImage(UIImage(named: "Upload"), for: UIControlState.normal)
        }
        
        if let uploadDate = recording.uploadDate {
            string += "\n\nUploaded at: \(uploadDate)"
        }else {
            string += "\n\nUploaded at: Unknown"
        }
        
        Cell.info.text = string
        
        return Cell
    }
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            guard let url = self.manager.recordings[indexPath.row].localURL else {
                return
            }
            
            do{
                try self.fileManager.removeFile(fileURL: url)
                try self.manager.recordings[indexPath.row].removeRecording()
            }catch{
                AppDelegate.quickAlert("Error", "Failed to remove recording from Realm: \(error)")
                return
            }
            self.myTableView.reloadData()
        default:
            return
        }
    }
    
}

extension RecordViewController: RecordCellInteraction {
    func uploadPressed(_ path: IndexPath?) {
        
        guard let p = path else {
            AppDelegate.quickAlert("Error", "No index path")
            return
        }
        
        let recording = self.manager.recordings[p.row]
        
        guard !recording.uploaded else {
            return
        }
        
        let cell = self.myTableView.cellForRow(at: p) as? RecordCell
        
        cell?.progress.isHidden = false
        cell?.progress.progress = 0.0
        let uploadManager = S3Controller()
        
        uploadManager.uploadSound(theRecording: recording, completion: { (error) in
            if let e = error {
                switch e {
                case .badUploadRequest:
                    AppDelegate.quickAlert("Error", "Could not construct upload request")
                case .couldNotMakeRemoteURL:
                    AppDelegate.quickAlert("Error", "Could not make remote URL")
                case .noLocalFile:
                    AppDelegate.quickAlert("Error", "No local file found to upload")
                case .noLocalFileName:
                    AppDelegate.quickAlert("Error", "No local file name found to construct path")
                case .noResult:
                    AppDelegate.quickAlert("Error", "No result returned from AWS")
                case .realmError(let e):
                    AppDelegate.quickAlert("Error", "Realm Error: \(e)")
                case .transferError(let e):
                    AppDelegate.quickAlert("Error", "Transfer Error: \(e)")
                }
                
            }else{
                self.myTableView.reloadRows(at: [p], with: UITableViewRowAnimation.none)
            }
            cell?.progress.isHidden = true
        }) { (progress) in
            print(progress)
            cell?.progress.progress = progress
        }
    }
    
    func playPressed(_ path: IndexPath?) {
        
        
        guard let r = path?.row, let url = self.manager.recordings[r].localURL else {
            AppDelegate.quickAlert("Error", "No index path or local URL")
            return
        }
        
        do{
            try self.player = AVAudioPlayer(contentsOf: url)
        }catch{
            AppDelegate.quickAlert("Error", "Failed to play recording: \(error)")
        }
        self.configureAudioOutputRoute()
        self.player?.delegate = self
        self.player?.play()
    }
    
}

extension RecordViewController: DZNEmptyDataSetSource {
    //MARK: Source
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "Instructions")
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: "Record Audio!")
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: "Press and hold the red record button to record audio.")
    }
    
}
