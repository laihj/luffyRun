//
//  ActivityListVC.swift
//  luffyRun
//
//  Created by laihj on 2022/9/22.
//

import UIKit
import HealthKit
import CoreData

class ActivityListVC: UIViewController {
    var context:NSManagedObjectContext? {
        didSet {
            self.refreshTable()
            self.refreshHeaderView()
        }
        

    }
    var workouts:[HKWorkout]?
    @IBOutlet var headerView: HeaderView?
    @IBOutlet var tableView: UITableView?
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    fileprivate var dataSource: TableViewDataSource<ActivityListVC>!
    
    func refreshTable() {
        let request = Record.sortedFetchRequest
        request.fetchBatchSize = 20
        request.returnsObjectsAsFaults = false
        let frc = NSFetchedResultsController(fetchRequest: request,
                                             managedObjectContext: context!,
                                             sectionNameKeyPath: nil,
                                             cacheName: nil)
        self.tableView?.delegate = self
        dataSource = TableViewDataSource(tableView: tableView!, cellIdentifier: "LRRunningCell", fetchedResultsController: frc, delegate: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
    }
    
    @IBAction func buttonclick() {
        authorizeHealthKit { (success, error) in
            self.readWorkouts()
        }
    }
    
    func readWorkouts () {
        var startDate = Date(timeIntervalSinceNow: -126 * 60 * 24 * 60)
            if let lastedRecord:Record = dataSource.objectAtIndexPath(IndexPath(row: 0, section: 0)) {
                startDate = Date(timeIntervalSince1970:lastedRecord.endDate!.timeIntervalSince1970 + 1)
            }
        
        loadPrancerciseWorkouts(startDate:startDate) { workouts, error in
            self.workouts = workouts
            
            for workout in self.workouts! {
                let sourceName = workout.sourceRevision.source.name
                if !sourceName.contains("luffyRun") && !sourceName.contains("Apple Watch") {
                    continue
                }
                
                let group = DispatchGroup()
                
                var retHeartbeat = Array<DiscreateHKQuanty>()
                group.enter()
                let heartUnit = HKUnit.count().unitDivided(by: HKUnit.minute())
                workout.discreateQuanty(identifier: .heartRate, unit: heartUnit) { heartbeat in
                    group.leave()
                    retHeartbeat = heartbeat
                }
                
                var retRoutes = Array<RouteNode>()
                group.enter()
                workout.route() { routes in
                    group.leave()
                    retRoutes = routes
                }
                
                var retSteps = Array<CumulativeQuantity>()
                group.enter()
                workout.cumulativeQuantity(identifier: .stepCount, unit: HKUnit.count()) { steps in
                    group.leave()
                    retSteps = steps
                }

                var retPower = Array<DiscreateHKQuanty>()
                group.enter()
                workout.discreateQuanty(identifier: .runningPower, unit: HKUnit.watt()) { power in
                    group.leave()
                    retPower = power
                }
                
                group.notify(queue: .main) {
                    self.saveRecord(workout: workout, heartbeat: retHeartbeat,routes: retRoutes,power: retPower, steps: retSteps)
                }
            }

            
            DispatchQueue.main.async {
                self.tableView?.reloadData()
                
            }
        }
    }
    
    func saveRecord(workout:HKWorkout, heartbeat:[DiscreateHKQuanty], routes:[RouteNode],power:[DiscreateHKQuanty],steps:[CumulativeQuantity]) {
        self.context!.performChanges {
            let record = Record.insert(into: self.context!)
            record.startDate = workout.startDate
            record.endDate = workout.endDate
            let workoutEvent = workout.workoutEvents
            for event in workoutEvent! {
                print(event)
            }
            if let distance = workout.sumQuantityFor(.distanceWalkingRunning, unit: HKUnit.meter()) {
                record.distance = NSNumber(value:distance)
            }
            
            if let step = workout.sumQuantityFor(.stepCount, unit: HKUnit.count()) {
                record.step = NSNumber(value: step)
            }
            
            if let kCal = workout.sumQuantityFor(.activeEnergyBurned, unit: HKUnit.kilocalorie()),
                                                 let nkCal = workout.sumQuantityFor(.basalEnergyBurned, unit: HKUnit.kilocalorie()) {
                record.kCal = NSNumber(value: kCal + nkCal)
            }
            
            if let averageSLength = workout.averageQuantityFor(.runningStrideLength, unit: HKUnit.meter()) {
                record.averageSLength = NSNumber(value: averageSLength)
            }
            
            if let (minSpeed,averageSpeed,maxSpeed) = workout.quantityFor(.runningSpeed, unit: HKUnit.meter().unitDivided(by:HKUnit.minute())) {
                let minPace = 1.0/(minSpeed/1000.0)
                record.minPace = NSNumber(value: minPace)
                
                let avaragePace = 1.0/(averageSpeed/1000.0)
                record.avaragePace = NSNumber(value: avaragePace)
                
                let maxPace = 1.0/(maxSpeed/1000.0)
                record.maxPace = NSNumber(value: maxPace)
            }
            
            if let (minHeart,averageHeart,maxHeart) = workout.quantityFor(.heartRate, unit: HKUnit.count().unitDivided(by: HKUnit.minute())) {
                record.minHeart = NSNumber(value: minHeart)
                record.avarageHeart = NSNumber(value: averageHeart)
                record.maxHeart = NSNumber(value: maxHeart)
            }
            
            if let (minWatt,averageWatt,maxWatt) = workout.quantityFor(.runningPower, unit: HKUnit.watt()) {
                record.minWatt = NSNumber(value: minWatt)
                record.avarageWatt = NSNumber(value: averageWatt)
                record.maxWatt = NSNumber(value: maxWatt)
            }
            
            record.heartbeat = heartbeat
            record.routes = routes
            record.power = power
            record.steps = steps
            let sourceName = workout.sourceRevision.source.name
            record.source = sourceName
        }
    }
    
    func refreshHeaderView() {
        let endDate = Date().endOfWeek.addOneDay
        
        let middleDate = endDate.addingTimeInterval(-30 * 24 * 3600)
        let startDate = endDate.addingTimeInterval(-18 * 7 * 24 * 3600)
        let request = Record.sortedFetchRequest
        let predicate = NSPredicate(format: "%K BETWEEN {%@,%@}", #keyPath(Record.startDate),startDate as NSDate,endDate as NSDate)
        request.predicate = predicate
        request.returnsObjectsAsFaults = false
        if let records = try? self.context!.fetch(request) {
            let currentData = records.filter { record in
                return record.startDate >= middleDate
            }
            
            let dayDurationInSeconds: TimeInterval = 60*60*24
            var dayRunningDatas = [DayRunningData]()
            for date in stride(from: startDate, to: endDate, by: dayDurationInSeconds) {
                let dayEndDate = date.addOneDay
                let dayData = records.filter { record in
                    return record.startDate > date && record.startDate <= dayEndDate
                }
                
                let dayRunningData = DayRunningData(records: dayData, date: dayEndDate)
                dayRunningDatas.append(dayRunningData)
            }
            
            self.headerView?.dayRunningDatas = dayRunningDatas
            
            
            self.headerView?.stats = headerViewData(records: currentData);
            
//            let lastData = records.filter { record in
//                return record.startDate < middleDate
//            }
//            self.headerView?.lastStats = headerViewData(records: lastData);
        }
    }
}

extension ActivityListVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let record = dataSource.objectAtIndexPath(indexPath) else { fatalError("no record")}
        let runningDetail = RunningDetailVC.init()
        runningDetail.record = record
        self.navigationController?.pushViewController(runningDetail, animated: true)
    }
    
}

extension ActivityListVC: TableViewDataSourceDelegate {
    
    func configure(_ cell: LRRunningRecordCell, for object: Record) {
        cell.configure(for: object)
    }
}


extension Date {
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }

    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay)!
    }
    
    var startOfWeek: Date {
        Calendar.current.dateComponents([.calendar, .yearForWeekOfYear, .weekOfYear], from: self).date!
    }
    
    var endOfWeek: Date {
        var components = DateComponents()
        components.weekOfYear = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfWeek)!
    }
    
    var addOneDay:Date {
        let date = self.addingTimeInterval(24 * 3600)
        return date
    }
    
    var startOfMonth: Date {
        let components = Calendar.current.dateComponents([.year, .month], from: startOfDay)
        return Calendar.current.date(from: components)!
    }

    var endOfMonth: Date {
        var components = DateComponents()
        components.month = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfMonth)!
    }
    
    func isSameDay(date: Date) -> Bool {
        return Calendar.current.isDate(self, inSameDayAs: date)
    }
    
}
