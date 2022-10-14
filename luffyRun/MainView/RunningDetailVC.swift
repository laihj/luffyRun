//
//  RunningDetailVC.swift
//  luffyRun
//
//  Created by laihj on 2022/10/13.
//

import UIKit
import HealthKit

class RunningDetailVC: UIViewController {
    var workout:HKWorkout?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let workout = self.workout {
            let runningObjectQuery = HKQuery.predicateForObjects(from: workout)
            let heartQuery = HKAnchoredObjectQuery(type: HKSeriesType.heartbeat(), predicate: nil, anchor: nil, limit: HKObjectQueryNoLimit) { query, samples, deletedObjects, anchor, error in
                guard error == nil else {
                    // Handle any errors here.
                    fatalError("The initial query failed.")
                }

                print("cc");
                
            }

//            let routeQuery = HKAnchoredObjectQuery(type: HKSeriesType.workoutRoute(), predicate: runningObjectQuery, anchor: nil, limit: HKObjectQueryNoLimit) { (query, samples, deletedObjects, anchor, error) in
//
//                guard error == nil else {
//                    // Handle any errors here.
//                    fatalError("The initial query failed.")
//                }
//
//                if let workoutroute = samples?.first {
//
//                    let query = HKWorkoutRouteQuery(route: workoutroute as! HKWorkoutRoute) { query, locations, done, error in
//                        print(locations);
//                    }
//                    HKHealthStore().execute(query)
//                }
//
//                print("route");
//
//                // Process the initial route data here.
//            }
//
//            routeQuery.updateHandler = { (query, samples, deleted, anchor, error) in
//
//                guard error == nil else {
//                    // Handle any errors here.
//                    fatalError("The update failed.")
//                }
//
//                // Process updates or additions here.
//            }


            HKHealthStore().execute(heartQuery)
            
        }

    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
