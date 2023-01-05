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
    var context:NSManagedObjectContext?
    var workouts:[HKWorkout]?
    @IBOutlet var headerView: HeaderView?
    @IBOutlet var tableView: UITableView?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        context =  appDelegate.persistentContainer.viewContext
        // Do any additional setup after loading the view.
        self.refreshTable()
        self.refreshHeaderView()
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
        var startDate = Date(timeIntervalSinceNow: -60 * 60 * 24 * 60)
        if let lastedRecord:Record = dataSource.objectAtIndexPath(IndexPath(row: 0, section: 0)) as? Record {
            startDate = Date(timeIntervalSince1970:lastedRecord.endDate.timeIntervalSince1970 + 1)
        }
        
        loadPrancerciseWorkouts(startDate:startDate) { workouts, error in
            self.workouts = workouts
            
            for workout in self.workouts! {
                let sourceName = workout.sourceRevision.source.name
                if !sourceName.contains("luffyRun") && !sourceName.contains("Apple Watch") {
                    continue
                }
                let group = DispatchGroup()
                
                var retHeartbeat = Array<HeartBeat>()
                var retRoutes = Array<RouteNode>()
                
                group.enter()
                workout.heartRate() { heartbeat in
                    group.leave()
                    retHeartbeat = heartbeat
                }
                
                group.enter()
                workout.route() { routes in
                    group.leave()
                    retRoutes = routes
                }
                
//                group.enter()
//                workout.stepCount { steps in
//                    group.leave()
//                }
//
//                group.enter()
//                workout.power { power in
//                    group.leave()
//                }
                
                group.notify(queue: .main) {
                    self.saveRecord(workout: workout, heartbeat: retHeartbeat,routes: retRoutes)
                }
            }

            
            DispatchQueue.main.async {
                self.tableView?.reloadData()
                self.refreshHeaderView()
            }
        }
    }
    
    func refreshHeaderView() {
        
        let endDate = Date()
        let middleDate = endDate.addingTimeInterval(-30 * 24 * 3600)
        let startDate = middleDate.addingTimeInterval(-60 * 24 * 3600)
        let request = Record.sortedFetchRequest
        let predicate = NSPredicate(format: "%K BETWEEN {%@,%@}", #keyPath(Record.startDate),startDate as NSDate,endDate as NSDate)
        request.predicate = predicate
        request.returnsObjectsAsFaults = false
        if let records = try? self.context!.fetch(request) {
            let currentData = records.filter { record in
                return record.startDate >= middleDate
            }
            
            self.headerView?.stats = headerViewData(records: currentData);
            
            let lastData = records.filter { record in
                return record.startDate < middleDate
            }
            self.headerView?.lastStats = headerViewData(records: lastData);
        }
    }
    
    
    func saveRecord(workout:HKWorkout, heartbeat:[HeartBeat], routes:[RouteNode]) {
        self.context!.performChanges {
            let record = Record.insert(into: self.context!)
            record.startDate = workout.startDate
            record.endDate = workout.endDate

            if let distance = workout.sumQuantityFor(HKQuantityTypeIdentifier.distanceWalkingRunning, unit: HKUnit.meter()) {
                record.distance = NSNumber(value:distance)
            }
            
            if let step = workout.sumQuantityFor(HKQuantityTypeIdentifier.stepCount, unit: HKUnit.count()) {
                record.step = NSNumber(value: step)
            }
            
            if let kCal = workout.sumQuantityFor(HKQuantityTypeIdentifier.activeEnergyBurned, unit: HKUnit.kilocalorie()) {
                record.kCal = NSNumber(value: kCal)
            }
            
            if let averageSLength = workout.averageQuantityFor(HKQuantityTypeIdentifier.runningStrideLength, unit: HKUnit.meter()) {
                record.averageSLength = NSNumber(value: averageSLength)
            }
            
            if let averageRunningSpeed = workout.averageQuantityFor(HKQuantityTypeIdentifier.runningSpeed, unit: HKUnit.meter().unitDivided(by:HKUnit.minute())) {
                let avaragePace = 1.0/(averageRunningSpeed/1000.0)
                record.avaragePace = NSNumber(value: avaragePace)
            }
            
            if let avarageHeart = workout.averageQuantityFor(HKQuantityTypeIdentifier.heartRate, unit: HKUnit.count().unitDivided(by: HKUnit.minute())) {
                record.avarageHeart = NSNumber(value: avarageHeart)
            }
            
            if let avarageWatt = workout.averageQuantityFor(HKQuantityTypeIdentifier.runningPower, unit: HKUnit.watt()) {
                record.avarageWatt = NSNumber(value: avarageWatt)
            }
            
            record.heartbeat = heartbeat
            record.routes = routes
            let sourceName = workout.sourceRevision.source.name
            record.source = sourceName
        }
    }
}

extension ActivityListVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let record = dataSource.objectAtIndexPath(indexPath) as? Record else { fatalError("no record")}
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
