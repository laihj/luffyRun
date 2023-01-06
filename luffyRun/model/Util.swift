//
//  Util.swift
//  luffyRun
//
//  Created by laihj on 2022/12/15.
//

import Foundation
import HealthKit

extension Sequence where Iterator.Element: AnyObject {
    func containsObjectIdentical(to object: AnyObject) -> Bool {
        return contains { $0 === object }
    }
}

func formatPace(minite:Double) -> String {
    let second = Int(minite * 60)
    return "\(second/60)'\(String(format: "%02d", second % 60))"
}

func formatTime(seconds:Double) -> String {
    let (h, m, s) = secondsToHoursMinutesSeconds(Int(seconds))
    return "\(String(format: "%02d", h)):\(String(format: "%02d", m)) :\(String(format: "%02d", s))"
}

func secondsToHoursMinutesSeconds(_ seconds: Int) -> (Int, Int, Int) {
    return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
}
