//
//  DepartureCellTableViewCell.swift
//  MVG Abfahrt Goethe Institut
//
//  Created by Anton Rohr on 17.08.18.
//  Copyright © 2018 Anton Rohr. All rights reserved.
//

import UIKit

class DepartureCellTableViewCell: UITableViewCell {

    @IBOutlet var destinationLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setDeparture(_ departure: Departure) {
        
        destinationLabel.text = departure.destination
        
        timeLabel.text = departure.leavesIn
        
        
        
    }
    
}
