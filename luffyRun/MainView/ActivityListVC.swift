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
        self.authorizeHealthKit { (success, error) in
            self.readWorkouts()
        }
        
//        context!.performChanges {
//            let record = Record.insert(into: self.context!)
//        }
    }
    
    func readWorkouts () {
        self.loadPrancerciseWorkouts { workouts, error in
            self.workouts = workouts
            
            for workout in self.workouts! {
//                self.context!.performChanges {
                    
                    
                    let group = DispatchGroup()
                    
                    var retHeartbeat = Array<HeartBeat>()
                    var retRoutes = Array<RouteNode>()
                    
                    group.enter()
                    self.bindRecordHeartRate(workout: workout) { heartbeat in
                        group.leave()
                        retHeartbeat = heartbeat
                    }
                
                
                group.enter()
                self.bindRoute(workout: workout) { routes in
                    group.leave()
                    retRoutes = routes
                }
                    group.notify(queue: .main) {
                        print("aaaa")
                        self.saveRecord(workout: workout, heartbeat: retHeartbeat,routes: retRoutes)
                    }
                }
//            }

//            if let workout = self.workouts?[2] {
//                self.context!.performChanges {
//                    let record = Record.insert(into: self.context!)
//                    record.startDate = workout.startDate
//                    record.endDate = workout.endDate
//
//                    self.bindRecordHeartRate(record: record, workout:workout)
//                    self.bindRoute(record: record, workout: workout)
//                }
//            }

            
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
            record.heartbeat = heartbeat
            record.routes = routes
        }
    }
    
    func bindRoute(workout:HKWorkout, completion: @escaping ([RouteNode])->()) {
        let runningObjectQuery = HKQuery.predicateForObjects(from: workout)
        let heartQuery = HKAnchoredObjectQuery(type: HKSeriesType.heartbeat(), predicate: nil, anchor: nil, limit: HKObjectQueryNoLimit) { query, samples, deletedObjects, anchor, error in
            guard error == nil else {
                fatalError("The initial query failed.")
            }
        }

        let routeQuery = HKAnchoredObjectQuery(type: HKSeriesType.workoutRoute(), predicate: runningObjectQuery, anchor: nil, limit: HKObjectQueryNoLimit) { (query, samples, deletedObjects, anchor, error) in

            guard error == nil else {
                // Handle any errors here.
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
            // Process the initial route data here.
        }

        routeQuery.updateHandler = { (query, samples, deleted, anchor, error) in
            guard error == nil else {
                // Handle any errors here.
                fatalError("The update failed.")
            }
            // Process updates or additions here.
        }
        HKHealthStore().execute(routeQuery)
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
                
                
                // Check to see if the sample is a series.
                if sample.count == 1 {
                    // This is a single sample.
                    // Use the sample.
                    let heart = sample.mostRecentQuantity.doubleValue(for: heartRateUnit)
                    let recordHeartRate:HeartBeat = HeartBeat(heart: Int16(heart), date: sample.startDate)
                    heartbeat.append(recordHeartRate)
                }
                else {
                    // This is a series.
                    // Get the detailed items for the series.
                    self.myGetDetailedItems(sample:sample)
                }
                
               
            }
            print("bbbb")
            completion(heartbeat)
        }
        
        // Run  the query.
        HKHealthStore().execute(heartRateQuery)
        
    }
    
    func myGetDetailedItems(sample:HKDiscreteQuantitySample) {
        let inSeriesSample = HKQuery.predicateForObject(with: sample.uuid)

        // Create the query.
        let detailQuery = HKQuantitySeriesSampleQuery(quantityType: HKSampleType.quantityType(forIdentifier:.heartRate)!,
                                                      predicate: inSeriesSample)
        { query, quantity, dateInterval, HKSample, done, error in
            
            guard let quantity = quantity, let dateInterval = dateInterval else {
                fatalError("*** An error occurred: \(error!.localizedDescription) ***")
            }
            
            // Use the data.
            print("\(quantity.doubleValue(for: HKUnit(from: "count/min"))): \(dateInterval)");
        }

        // Run the query.
        HKHealthStore().execute(detailQuery)
    }
    
    func loadPrancerciseWorkouts(completion: @escaping ([HKWorkout]?, Error?) -> Void) {
        
        
        let workoutPredication = HKQuery.predicateForWorkouts(with: .running)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        
//        let compond = NSCompoundPredicate(andPredicateWithSubpredicates: [workoutPredication,sourcePredicte])
        
        let query = HKSampleQuery(sampleType: .workoutType(), predicate: workoutPredication, limit: 10, sortDescriptors: [sortDescriptor]) { query, samples, error in
            let samples = samples as? [HKWorkout]
            
            completion(samples, nil)
        }
        
        HKHealthStore().execute(query)
    }
    
    func authorizeHealthKit(completion: @escaping (Bool, Error?) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false, nil)
            return;
        }
        let healthKitTypesToWrite: Set<HKSampleType> = [HKObjectType.workoutType(),
                                                        HKSeriesType.workoutRoute(),
                                                        HKSeriesType.heartbeat(),
                                                        HKSampleType.quantityType(forIdentifier: .distanceWalkingRunning)!,
                                                        HKSeriesType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!,
                                                        HKQuantityType.quantityType(forIdentifier: .heartRate)!]
        
        let healthKitTypesToRead: Set<HKSampleType> = [HKObjectType.workoutType(),
                                                       HKSeriesType.workoutRoute(),
                                                       HKSeriesType.heartbeat(),
                                                       HKSampleType.quantityType(forIdentifier: .distanceWalkingRunning)!,
                                                       HKSeriesType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!,
                                                       HKQuantityType.quantityType(forIdentifier: .heartRate)!]
        
        HKHealthStore().requestAuthorization(toShare: healthKitTypesToRead, read: healthKitTypesToWrite) { (success, error) in
            completion(success, error)
        }
    }
}

extension ActivityListVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let record = dataSource.objectAtIndexPath(indexPath) as? Record else { fatalError("no record")}
        let runningDetail = RunningDetailVC.init()
        runningDetail.record = record
        self.navigationController?.pushViewController(runningDetail, animated: true)
//        if let workout = self.workouts?[indexPath.row] {
//            let runningDetail = RunningDetailVC.init()
//            runningDetail.workout = workout
//
//
//            let statistics = workout.statistics(for: HKQuantityType(.distanceWalkingRunning))
//            statistics?.averageQuantity()
//
//            let speed = workout.statistics(for: HKQuantityType(.runningSpeed));
////            speed?.sumQuantity()?.doubleValue(for:.)
////            speed?.averageQuantity()
//            let heart = workout.statistics(for: HKQuantityType(.heartRate));
//
//
//            HKUnit.minute()
//        }
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
