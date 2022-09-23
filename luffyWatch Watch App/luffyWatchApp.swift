//
//  luffyWatchApp.swift
//  luffyWatch Watch App
//
//  Created by laihj on 2022/9/22.
//

import SwiftUI

@main
struct luffyWatch_Watch_AppApp: App {
    @StateObject var workoutManager = WorkoutManager()
    
    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                StartView()
            }
            .environmentObject(workoutManager)
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}
