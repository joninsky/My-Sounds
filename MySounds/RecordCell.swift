//
//  RecordCell.swift
//  MySounds
//
//  Created by Jon Vogel on 1/31/17.
//  Copyright © 2017 Jon Vogel. All rights reserved.
//

import UIKit
protocol RecordCellInteraction {
    func playPressed(_ path: IndexPath?)
    func uploadPressed(_ path: IndexPath?)
}

class RecordCell: UITableViewCell {

    
    @IBOutlet weak var upload: UIButton!
    
    @IBOutlet weak var info: UILabel!
    
    @IBOutlet weak var play: UIButton!
    
    var path: IndexPath?
    
    var delegate: RecordCellInteraction?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func uploadPressed(_ sender: Any) {
        self.delegate?.uploadPressed(self.path)
    }
    @IBAction func playPressed(_ sender: Any) {
        self.delegate?.playPressed(self.path)
    }

}
