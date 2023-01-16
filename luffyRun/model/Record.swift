//
//  Record.swift
//  luffyRun
//
//  Created by laihj on 2022/12/14.
//

import Foundation
import CoreData

final class Record:NSManagedObject {
    @NSManaged var startDate: Date
    @NSManaged var endDate: Date?
    @NSManaged var heartRate:HeartRate
    @NSManaged var paceZone:PaceZone
    @NSManaged var heartbeat:[DiscreateHKQuanty]?
    @NSManaged var power:[DiscreateHKQuanty]?
    @NSManaged var steps:[CumulativeQuantity]?
    @NSManaged var routes:[RouteNode]?
    @NSManaged var source: String
    @NSManaged var distance:NSNumber?
    @NSManaged var step:NSNumber?
    @NSManaged var kCal:NSNumber?
    @NSManaged var averageSLength:NSNumber?
    
    @NSManaged var minPace:NSNumber?
    @NSManaged var minHeart:NSNumber?
    @NSManaged var minWatt:NSNumber?
    
    @NSManaged var avaragePace:NSNumber?
    @NSManaged var avarageHeart:NSNumber?
    @NSManaged var avarageWatt:NSNumber?
    
    @NSManaged var maxPace:NSNumber?
    @NSManaged var maxHeart:NSNumber?
    @NSManaged var maxWatt:NSNumber?
    
    static func insert(into context:NSManagedObjectContext) -> Record {
        let record:Record = context.insertObject()
        record.startDate = Date()
        record.heartRate = HeartRate.lastedHeadRate(in: context)!
        record.paceZone = PaceZone.lastedPaceZone(in: context)!
        return record
    }
    
}

extension Record: Managed {
    static var defaultSortDescriptors: [NSSortDescriptor] {
        return [NSSortDescriptor(key: #keyPath(startDate), ascending: false)]
    }
    
}

//for chart
extension Record {
    func heartRateChartData() -> [BarData] {
        if let heartBeat = heartbeat {
            var (zone5,zone4,zone3,zone2,zone1) = (0.0,0.0,0.0,0.0,0.0)
            var allSecond = 0.0
            for (current,next) in zip(heartBeat,heartBeat.dropFirst()) {
                let second = next.date.timeIntervalSince1970 -  current.date.timeIntervalSince1970
                let value = Int(current.value)
                if value >= heartRate.zone5 {
                    zone5 += second
                } else if value >= heartRate.zone4 {
                    zone4 += second
                } else if value >= heartRate.zone3 {
                    zone3 += second
                } else if value >= heartRate.zone2 {
                    zone2 += second
                } else {
                    zone1 += second
                }
                allSecond += second
            }
            return [
                BarData(name: ">\(heartRate.zone5)", time: zone5/allSecond * 100, color: .purple),
                BarData(name: "\(heartRate.zone4)~\(heartRate.zone5)", time: zone4/allSecond * 100, color: .red),
                BarData(name: "\(heartRate.zone3)~\(heartRate.zone4)", time: zone3/allSecond * 100, color: .blue),
                BarData(name: "\(heartRate.zone2)~\(heartRate.zone3)", time: zone2/allSecond * 100, color: .yellow),
                BarData(name: "<\(heartRate.zone2)", time: zone1/allSecond * 100, color: .green)
            ]
        }
        return []
    }
    
    func paceChartData() -> [BarData] {
        if let routes = routes {
            var (zone5,zone4,zone3,zone2,zone1) = (0.0,0.0,0.0,0.0,0.0)
            var allSecond = 0.0
            let filterdRoute = routes.filter { route in
                let value = 1.0/(route.location.speed * 60 / 1000)
                return value < (minPace?.doubleValue ?? 0.0) && value > (maxPace?.doubleValue ?? 0.0)
            }

            for (current,next) in zip(filterdRoute,filterdRoute.dropFirst()) {
                let second = next.date.timeIntervalSince1970 -  current.date.timeIntervalSince1970
                let value:Int16 = Int16(1.0/(current.location.speed / 1000))
                
                if value > paceZone.zone1 {
                    zone1 += second
                } else if value > paceZone.zone2 {
                    zone2 += second
                } else if value > paceZone.zone3 {
                    zone3 += second
                } else if value > paceZone.zone4 {
                    zone4 += second
                } else {
                    zone5 += second
                }
                allSecond += second
            }
            
            return [
                BarData(name: paceZone.formatZone(zone: 5), time: zone5/allSecond * 100, color: .purple),
                BarData(name: paceZone.formatZone(zone: 4), time: zone4/allSecond * 100, color: .red),
                BarData(name: paceZone.formatZone(zone: 3), time: zone3/allSecond * 100, color: .blue),
                BarData(name: paceZone.formatZone(zone: 2), time: zone2/allSecond * 100, color: .yellow),
                BarData(name: paceZone.formatZone(zone: 1), time: zone1/allSecond * 100, color: .green)
            ]
        }
        return []
    }
}
