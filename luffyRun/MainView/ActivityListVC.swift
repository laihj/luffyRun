//
//  ActivityListVC.swift
//  luffyRun
//
//  Created by laihj on 2022/9/22.
//

import UIKit
import HealthKit
import CoreData
import Toast_Swift

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
        self.fixedOldRecord()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
//            startDate = Date(timeIntervalSince1970:lastedRecord.startDate.timeIntervalSince1970 + 1)
        }
        
        
        loadPrancerciseWorkouts(startDate:startDate) { workouts, error in
            self.workouts = workouts
            let listgroup = DispatchGroup()
            for workout in self.workouts! {
                listgroup.enter()
                if let matadata = workout.metadata {
                    if let indoor = matadata["HKIndoorWorkout"] as? Int {
                        if indoor == 1 {
                            continue
                        }
                    }
                }
                
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
                    listgroup.leave()
                }
            }
            
            listgroup.notify(queue: .main) {
                self.refreshHeaderView()
            }
        }
    }
    
    func reloadData() {
        self.tableView?.reloadData()
        self.refreshHeaderView()
        self.fixedOldRecord()
    }
    
    func saveRecord(workout:HKWorkout, heartbeat:[DiscreateHKQuanty], routes:[RouteNode],power:[DiscreateHKQuanty],steps:[CumulativeQuantity]) {
        guard routes.count > 0 else {
            self.view.makeToast("retry a minute", duration: 1, position: .top)
            return
        }
        
        self.context!.performChanges {
            let record = Record.insert(into: self.context!)
            record.startDate = workout.startDate
            record.endDate = workout.endDate
            record.udid = workout.uuid
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
            
            if let matadata = workout.metadata {
                if let temperature = matadata["HKWeatherTemperature"] as? HKQuantity {
                    let c = temperature.doubleValue(for: HKUnit.degreeCelsius())
                    record.temperature = NSNumber(value: c)
                }
                if let humidity = matadata["HKWeatherHumidity"] as? HKQuantity {
                    let h = humidity.doubleValue(for: .percent())
                    record.humidity = NSNumber(value: h)
                }
                if let averageMETS = matadata["HKAverageMETs"] as? HKQuantity {
                    let mets = averageMETS.doubleValue(for: .kilocalorie().unitDivided(by: (.hour().unitMultiplied(by: .gramUnit(with: .kilo)))))
                    record.mets = NSNumber(value: mets)
                }
            }
            
        }
    }
    
    func refreshHeaderView() {
        guard self.context != nil else { return }
        let endDate = Date().endOfWeek.addOneDay
        
        let middleDate = endDate.addingTimeInterval(-30 * 24 * 3600)
        let startDate = endDate.addingTimeInterval(-18 * 7 * 24 * 3600)
        
        if let records = dataSource.allRecords() {
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
        }
    }
    
    func fixedOldRecord() {
        if let records = dataSource.allRecords() {
            records.forEach { record in
                if record.routes?.count == 0 {
                    loadWorkoutWith(udid: record.udid) { workout, error in
                        if let workout = workout {
                            workout.route { routes in
                                record.routes = routes
                                record.heartPace = nil
                                try? record.managedObjectContext?.save()
                            }
                        }
                    }
                }
            }
        }
    }
}



extension ActivityListVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let record = dataSource.objectAtIndexPath(indexPath) else { fatalError("no record")}
        let runningDetail = RunningDetailVC.init()
        runningDetail.record = record
        let lastIndexPath = IndexPath(row: indexPath.row + 1, section: indexPath.section)
        if let lastRecord = dataSource.objectAtIndexPath(lastIndexPath) {
            runningDetail.lastRecord = lastRecord
        }
    
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
