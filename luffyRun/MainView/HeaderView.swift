//
//  HeaderView.swift
//  luffyRun
//
//  Created by laihj on 2023/1/5.
//

import UIKit

struct headerViewData {
    var times:String
    var distance:String
    var duration:String
    var pace:String
    
    init(times: String, distance: String, duration: String, pace: String) {
        self.times = times
        self.distance = distance
        self.duration = duration
        self.pace = pace
    }
    
    init(records:[Record]) {
        self.times = "\(records.count)"
        
        let distance = records.reduce(0.0) { result, record in
            return result + (record.distance?.doubleValue ?? 0.0)
        }
        self.distance = String(format: "%.2fkm", distance/1000.0)
        
        let duration = records.reduce(0.0) { result, record in
            return result + (record.endDate.timeIntervalSince1970 - record.startDate.timeIntervalSince1970)
        }
    
        self.duration = formatTime(seconds: duration)
        let averagePace = (duration/60.0) / (distance/1000.0)
        self.pace = formatPace(minite: averagePace)
    }
}


class HeaderView: UIView {
    @IBOutlet var times:UILabel?
    @IBOutlet var distance:UILabel?
    @IBOutlet var duration:UILabel?
    @IBOutlet var pace:UILabel?
    
    @IBOutlet var lastTimes:UILabel?
    @IBOutlet var lastDistance:UILabel?
    @IBOutlet var lastDuration:UILabel?
    @IBOutlet var lastPace:UILabel?
    
    var stats:headerViewData? {
        willSet(newStats) {
            if let stats = newStats {
                times?.text = stats.times
                distance?.text = stats.distance
                duration?.text = stats.duration
                pace?.text = stats.pace
            }
        }
    }
    
    var lastStats:headerViewData? {
        willSet(newStats) {
            if let lastStats = newStats {
                lastTimes?.text = "/\(lastStats.times)"
                lastDistance?.text = "/\(lastStats.distance)"
                lastDuration?.text = "/\(lastStats.duration)"
                lastPace?.text = "/\(lastStats.pace)"
            }
        }
    }
}
