//
//  ContentView.swift
//  workout WatchKit Extension
//
//  Created by laihj on 2022/7/1.
//

import SwiftUI
import HealthKit

struct StartView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    
    
    var workoutTypes: [HKWorkoutActivityType] = [.cycling, .running, .walking]
    var body: some View {
        List(workoutTypes) { workoutType in
            NavigationLink(
                workoutType.name,
                destination: SessionPagingView(),
                tag: workoutType,
                selection: $workoutManager.selectedWorkout
            ).padding(
                EdgeInsets(top: 15, leading: 5, bottom: 15, trailing: 5))
        }
        .listStyle(.carousel)
        .navigationBarTitle("18 周")
        .onAppear {
            workoutManager.requestAuthorization()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    
    static var previews: some View {
        StartView()
    }
}


extension HKWorkoutActivityType: Identifiable {
    public var id: UInt {
        rawValue
    }
    
    var name: String {
        switch self {
                case .running:
                    return "Run"
                case .cycling:
                    return "Bike"
                case .walking:
                    return "Walk"
                default:
                    return ""
                }
    }
}
