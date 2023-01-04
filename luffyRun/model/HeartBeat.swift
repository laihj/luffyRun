//
//  HeartBeat.swift
//  luffyRun
//
//  Created by laihj on 2022/12/29.
//

import Foundation
import HealthKit

final class HeartBeat:NSObject,NSCoding,DiscreateHKQuanty {

    var heart: Int16
    var date: Date
    
    init(heart: Int16, date: Date) {
        self.heart = heart
        self.date = date
    }
    
    convenience init(sample:HKDiscreteQuantitySample, unit:HKUnit) {
        let heart = sample.quantity.doubleValue(for: unit)
        let date = sample.startDate
        self.init(heart: Int16(heart), date: date)
    }
    
    required convenience init?(coder: NSCoder) {
        let heart = coder.decodeObject(forKey: "heart") as! Int16
        let date = coder.decodeObject(forKey: "date") as! Date
        self.init(heart: heart, date: date)
    }
    
    
    func encode(with coder: NSCoder) {
        coder.encode(heart,forKey: "heart")
        coder.encode(date,forKey: "date")
    }
}

