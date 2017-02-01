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
    
    let mic = AKMicrophone()
    
    
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setUpPlot()
        
        AudioKit.start()
        
        self.myTableView.delegate = self
        self.myTableView.dataSource = self
        self.myTableView.tableFooterView = UIView()
        
        self.myTableView.emptyDataSetSource = self
    }
    
    
    
    //MARK: Actions
    
    @IBAction func recordLongPress(_ sender: UILongPressGestureRecognizer) {
        
        switch sender.state {
        case .began:
            self.record.setImage(UIImage(named: "Record"), for: UIControlState.normal)
            self.plot?.color = UIColor.green
        case .ended:
            self.record.setImage(UIImage(named: "StopRecord"), for: UIControlState.normal)
            self.plot?.color = UIColor.red
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
    
    
}

extension RecordViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let Cell = tableView.dequeueReusableCell(withIdentifier: "RecordingCell") as? RecordCell else {
            return UITableViewCell()
        }
        
        Cell.delegate = self
        Cell.path = indexPath
        
        
        
        
        return Cell
    }
    
}

extension RecordViewController: RecordCellInteraction {
    func uploadPressed(_ path: IndexPath?) {
        
        
    }
    
    func playPressed(_ path: IndexPath?) {
        
        
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
