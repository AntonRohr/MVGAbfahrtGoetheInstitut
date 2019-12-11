//
//  ViewController.swift
//  MVG Abfahrt Goethe Institut
//
//  Created by Anton Rohr on 17.08.18.
//  Copyright © 2018 Anton Rohr. All rights reserved.
//

import UIKit

let mvgUrl = URL(string: "https://www.mvg.de/api/fahrinfo/departure/de:09162:307")!
var destHBFidentifiers = ["karls", "veit", "einstein", "hauptbahnhof"]

func isCorrectDirection(name: String) -> Bool {
    return destHBFidentifiers.contains { name.lowercased().contains($0) }
}

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
        self.tableView.delegate = self

		Departure.setUp()

		Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [unowned self] (_: Timer) in
			self.requestMVGData()
		}

		Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [unowned self] _ in
			self.tableView.reloadData()

			guard let mvgJson = self.mvgJson, let departure = mvgJson.departures.filter({ (departure) -> Bool in
                return isCorrectDirection(name: departure.destination)
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
		default:
			UIApplication.shared.isIdleTimerDisabled = true
		}
	}

	func requestMVGData() {

		var request = URLRequest(url: mvgUrl)
		request.httpMethod = "GET"

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

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        guard let departure = mvgJson?.departures[indexPath.row] else {
            fatalError("clicked on non existent departure")
        }

        let name = departure.destination.lowercased()
        if isCorrectDirection(name: name) {
            destHBFidentifiers = destHBFidentifiers.filter { !name.contains($0) }
        } else {
            destHBFidentifiers.append(name)
        }
    }
}
