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
    @IBOutlet var tableView: UITableView?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        context =  appDelegate.persistentContainer.viewContext
        // Do any additional setup after loading the view.
        self.refreshTable()
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
//        if let lastedRecord:Record = dataSource.objectAtIndexPath(IndexPath(row: 0, section: 0)) as? Record {
//            startDate = Date(timeIntervalSince1970:lastedRecord.endDate.timeIntervalSince1970 + 1)
//        }
        
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
                self.bindRecordHeartRate(workout: workout) { heartbeat in
                    group.leave()
                    retHeartbeat = heartbeat
                }
                
                group.enter()
                workout.route() { routes in
                    group.leave()
                    retRoutes = routes
                }
                self.getStepCount(workout: workout) {steps in
                    
                }
                group.notify(queue: .main) {
                    self.saveRecord(workout: workout, heartbeat: retHeartbeat,routes: retRoutes)
                }
            }

            
            DispatchQueue.main.async {
                self.tableView?.reloadData()
            }
        }
    }
    
    
    func saveRecord(workout:HKWorkout, heartbeat:[HeartBeat], routes:[RouteNode]) {
        self.context!.performChanges {
            let record = Record.insert(into: self.context!)
            record.startDate = workout.startDate
            record.endDate = workout.endDate

            let distance = workout.sumQuantityFor(HKQuantityTypeIdentifier.distanceWalkingRunning, unit: HKUnit.meter())
            
            let step = workout.sumQuantityFor(HKQuantityTypeIdentifier.stepCount, unit: HKUnit.count())
            
            let kCal = workout.sumQuantityFor(HKQuantityTypeIdentifier.activeEnergyBurned, unit: HKUnit.kilocalorie())
            
            let averageSLength = workout.averageQuantityFor(HKQuantityTypeIdentifier.runningStrideLength, unit: HKUnit.meter())
            
            let averageRunningSpeed = workout.averageQuantityFor(HKQuantityTypeIdentifier.runningSpeed, unit: HKUnit.meter().unitDivided(by:HKUnit.minute()))
            
            let avaragePace = 1.0/(averageRunningSpeed!/1000.0)
            
            let avarageHeart = workout.averageQuantityFor(HKQuantityTypeIdentifier.heartRate, unit: HKUnit.count().unitDivided(by: HKUnit.minute()))
            
            let avarageWatt = workout.averageQuantityFor(HKQuantityTypeIdentifier.runningPower, unit: HKUnit.watt())
            
            record.heartbeat = heartbeat
            record.routes = routes
            let sourceName = workout.sourceRevision.source.name
            record.source = sourceName
        }
    }
    
    func getStepCount(workout:HKWorkout,completion: @escaping ([RouteNode])->()) {
        let stepUnit: HKUnit = HKUnit.watt()
        let forWorkout = HKQuery.predicateForObjects(from: workout)
        let stepDescriptor = HKQueryDescriptor(sampleType: HKSampleType.quantityType(forIdentifier: .runningPower)!, predicate: forWorkout)
        let stepQuery = HKSampleQuery(queryDescriptors: [stepDescriptor], limit: HKObjectQueryNoLimit) { query, samples, error in
            guard let samples = samples else {

                completion([])
                fatalError("*** An error occurred: \(error!.localizedDescription) ***")
            }
            
            for sample in samples {
                
                guard let sample = sample as? HKDiscreteQuantitySample  else {
                    fatalError("*** Unexpected Sample Type ***")
                }
                
                if sample.count == 1 {
                    let step = sample.quantity.doubleValue(for: stepUnit)
                    print(step)

                }
            }
            
        }
        HKHealthStore().execute(stepQuery)
        
    }
    
    func bindRecordHeartRate(workout:HKWorkout, completion: @escaping ([HeartBeat])->()) {
        let heartRateUnit: HKUnit = HKUnit.count().unitDivided(by: HKUnit.minute())
        let forWorkout = HKQuery.predicateForObjects(from: workout)
        let heartRateDescriptor = HKQueryDescriptor(sampleType: HKSampleType.quantityType(forIdentifier:.heartRate)! ,
                                                    predicate: forWorkout)
        
        // Create the query.
        let heartRateQuery = HKSampleQuery(queryDescriptors: [heartRateDescriptor],
                                           limit: HKObjectQueryNoLimit)
        { query, samples, error in
            // Process the samples.
            guard let samples = samples else {
                // Handle the error.
                completion([])
                fatalError("*** An error occurred: \(error!.localizedDescription) ***")
                
            }
            
            var heartbeat = Array<HeartBeat>()
            // Iterate over all the samples.
            for sample in samples {
                
                guard let sample = sample as? HKDiscreteQuantitySample else {
                    fatalError("*** Unexpected Sample Type ***")
                }
                
                if sample.count == 1 {
                    let recordHeartRate:HeartBeat = HeartBeat(sample: sample, unit: heartRateUnit)
                    heartbeat.append(recordHeartRate)
                }
            }
            completion(heartbeat)
        }
        
        // Run  the query.
        HKHealthStore().execute(heartRateQuery)
        
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

extension ActivityListVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let workouts = self.workouts {
            return workouts.count;
        }
        return 0;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LRRunningCell", for: indexPath) as! LRRunningRecordCell
        if let workout = self.workouts?[indexPath.row] {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            cell.label?.text = dateFormatter.string(from: workout.startDate)
            cell.sourceName?.text = workout.sourceRevision.source.name
            
            print(workout.totalDistance)
            print(workout.allStatistics)
//            print(workout.metadata)
//            print(workout.allStatistics)
//            print(workout.device)
            print(workout.sourceRevision.source.name)
            print("=======")

            
        }
        return cell;
    }
}

extension HKWorkout {
    func sumQuantityFor(_ identifier:HKQuantityTypeIdentifier, unit:HKUnit) -> Double? {
        let statistics = self.statistics(for: HKQuantityType(identifier))
        let quantity =  statistics?.sumQuantity()
        let value = quantity?.doubleValue(for: unit)
        return value
    }
    
    func averageQuantityFor(_ identifier:HKQuantityTypeIdentifier, unit:HKUnit) -> Double? {
        let statistics = self.statistics(for: HKQuantityType(identifier))
        let quantity =  statistics?.averageQuantity()
        let value = quantity?.doubleValue(for: unit)
        return value
    }
    
    func route(completion: @escaping ([RouteNode])->()) {
        let runningObjectQuery = HKQuery.predicateForObjects(from: self)

        let routeQuery = HKAnchoredObjectQuery(type: HKSeriesType.workoutRoute(), predicate: runningObjectQuery, anchor: nil, limit: HKObjectQueryNoLimit) { (query, samples, deletedObjects, anchor, error) in

            guard error == nil else {
                fatalError("The initial query failed.")
            }
            
            var routes = Array<RouteNode>()

            if let workoutroute = samples?.first {
                let query = HKWorkoutRouteQuery(route: workoutroute as! HKWorkoutRoute) { query, locations, done, error in
                    if let locas = locations {
                        for location in locas {
                            let route = RouteNode(location: location, date: location.timestamp)
                            routes.append(route)
                        }
                    }
                    if(done) {
                        completion(routes)
                    }
                }
                HKHealthStore().execute(query)
            }
        }

        routeQuery.updateHandler = { (query, samples, deleted, anchor, error) in
            guard error == nil else {
                fatalError("The update failed.")
            }
        }
        HKHealthStore().execute(routeQuery)
    }
}
