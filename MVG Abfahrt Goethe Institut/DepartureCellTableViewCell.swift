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
		self.destinationLabel.text = departure.destination
        self.timeLabel.text = departure.leavesIn

        if isCorrectDirection(name: departure.destination) {
            self.destinationLabel.font = UIFont.boldSystemFont(ofSize: 17)
            self.timeLabel.font = UIFont.systemFont(ofSize: 22)
        } else {
            self.destinationLabel.font = UIFont.systemFont(ofSize: 13)
            self.timeLabel.font = UIFont.systemFont(ofSize: 13)
        }

	}
}
