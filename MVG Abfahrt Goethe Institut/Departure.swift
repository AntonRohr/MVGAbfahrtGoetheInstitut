//
//  Departure.swift
//  MVG Abfahrt Goethe Institut
//
//  Created by Anton Rohr on 17.08.18.
//  Copyright © 2018 Anton Rohr. All rights reserved.
//

import Foundation

struct Departure: Codable {
	static let formatter = DateComponentsFormatter()
	static func setUp() {
		self.formatter.allowedUnits = [.hour, .minute, .second]
		self.formatter.unitsStyle = .abbreviated
	}

	let destination: String
	let departureTime: Date
	var leavesIn: String {
		return Departure.formatter.string(from: self.departureTime.timeIntervalSinceNow)!
	}
}
