//
//  ViewController.swift
//  MVG Abfahrt Goethe Institut
//
//  Created by Anton Rohr on 17.08.18.
//  Copyright © 2018 Anton Rohr. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
	@IBOutlet var tableView: UITableView!
	@IBOutlet var nextTimeLabel: UILabel!

	var mvgJson: MVGJson?

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.

		self.tableView.dataSource = self
		self.tableView.register(
			UINib(nibName: "DepartureCellTableViewCell", bundle: nil),
			forCellReuseIdentifier: "departureCell"
		)

		Departure.setUp()

		Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [unowned self] (_: Timer) in
			self.requestMVGData()
		}

		Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [unowned self] _ in
			self.tableView.reloadData()

			guard let mvgJson = self.mvgJson, let departure = mvgJson.departures.filter({ (departure) -> Bool in
				let name = departure.destination.lowercased()
				return name.contains("karls") || name.contains("veit") || name.contains("einstein") || name.contains("hauptbahnhof")
			}).first else {
				self.nextTimeLabel.text = ""
				return
			}

			self.nextTimeLabel.text = departure.leavesIn
		}

		self.requestMVGData()

		UIDevice.current.isBatteryMonitoringEnabled = true
		NotificationCenter.default.addObserver(
			forName: UIDevice.batteryStateDidChangeNotification, object: nil, queue: nil
		) { _ in
			self.triggerBatteryChanged()
		}
		self.triggerBatteryChanged()
	}

	override var prefersStatusBarHidden: Bool {
		return true
	}

	func triggerBatteryChanged() {
		print("battery full:", UIDevice.current.batteryState == .full)
		print("battery charging:", UIDevice.current.batteryState == .charging)
		print("battery unplugged:", UIDevice.current.batteryState == .unplugged)

		switch UIDevice.current.batteryState {
		case .unknown:
			print("unknown battery state")
		case .unplugged:
			UIApplication.shared.isIdleTimerDisabled = false
		case .charging:
			UIApplication.shared.isIdleTimerDisabled = true
		case .full:
			UIApplication.shared.isIdleTimerDisabled = true
		}
	}

	func requestMVGData() {
		guard let url = URL(string: "https://www.mvg.de/fahrinfo/api/departure/307") else {
			print("url not valid")
			return
		}
		var request = URLRequest(url: url)
		request.httpMethod = "GET"
		request.addValue("5af1beca494712ed38d313714d4caff6", forHTTPHeaderField: "X-MVG-Authorization-Key")

		let task = URLSession.shared.dataTask(with: request) { data, response, error in
			guard let data = data else {
				print("no data received! response:", response ?? "")
				print("error:", error ?? "")
				self.mvgJson = nil
				return
			}

			let decoder = JSONDecoder()
			decoder.dateDecodingStrategy = .millisecondsSince1970
			guard let mvgJson = try? decoder.decode(MVGJson.self, from: data) else {
				print("error while decoding", String(data: data, encoding: .utf8) ?? "")
				return
			}

			self.mvgJson = mvgJson
		}

		task.resume()
	}
}

extension ViewController: UITableViewDataSource {
	func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
		return self.mvgJson?.departures.count ?? 0
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: "departureCell") as? DepartureCellTableViewCell else {
			fatalError("Semantic Error: dequeueReusableCell returned something that is not DepartureCellTableViewCell")
		}

		if let departure = mvgJson?.departures[indexPath.row] {
			cell.setDeparture(departure)
		}

		return cell
	}
}
