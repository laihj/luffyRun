//
//  HeartBeat.swift
//  luffyRun
//
//  Created by laihj on 2022/12/29.
//

import Foundation
import HealthKit

final class DiscreateHKQuanty:NSObject,NSCoding {

    var value: Double
    var date: Date
    
    init(value: Double, date: Date) {
        self.value = value
        self.date = date
    }
    
    convenience init(sample:HKDiscreteQuantitySample, unit:HKUnit) {
        let value = sample.quantity.doubleValue(for: unit)
        let date = sample.startDate
        self.init(value: value, date: date)
    }
    
    required convenience init?(coder: NSCoder) {
        let value = coder.decodeDouble(forKey: "value")
        let date = coder.decodeObject(forKey: "date") as! Date
        self.init(value: value, date: date)
    }
    
    
    func encode(with coder: NSCoder) {
        coder.encode(value,forKey: "value")
        coder.encode(date,forKey: "date")
    }
}

