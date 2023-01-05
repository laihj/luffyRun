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

protocol DiscreateHKQuanty {
    init(sample:HKDiscreteQuantitySample, unit:HKUnit)
}

func formatPace(minite:Double) -> String {
    let second = Int(minite * 60)
    return "\(second/60):\(String(format: "%02d", second % 60))"
}
