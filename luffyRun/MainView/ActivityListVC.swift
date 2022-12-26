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

//        let record:Record = context.insertObject()
//        record.startDate = Date()
//        record.endDate = Date()
//        try! context.save()
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
//        self.authorizeHealthKit { (success, error) in
//            self.readWorkouts()
//        }
        
        context!.performChanges {
            let record = Record.insert(into: self.context!)
        }
    }
    
    func readWorkouts () {
        self.loadPrancerciseWorkouts { workouts, error in
            self.workouts = workouts
            
            for workout in self.workouts! {
                
                
            }

            let workout = self.workouts?.first;
            
            DispatchQueue.main.async {
                self.tableView?.reloadData()
            }
        }
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
