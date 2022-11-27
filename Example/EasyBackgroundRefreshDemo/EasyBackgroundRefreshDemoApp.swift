//
//  EasyBackgroundRefreshDemoApp.swift
//  EasyBackgroundRefreshDemo
//
//  Created by Yonat Sharon on 15/08/2022.
//

import EasyBackgroundRefresh
import SwiftUI

@main
struct EasyBackgroundRefreshDemoApp: App {
    // force init before app finishes launching:
    let backgroundRefresh = EasyBackgroundRefresh.default

    // detect when app goes to background (for testing and debugging):
    @Environment(\.scenePhase) var scenePhase

    // keep track of background refresh times (just for demo):
    @State var backgroundRefreshTimes: [Date] = []

    var body: some Scene {
        WindowGroup {
            ContentView(times: $backgroundRefreshTimes)
                .onAppear {
                    backgroundRefresh.action = self.refresh
                }
        }
        .onChange(of: scenePhase) { newPhase in
            switch newPhase {
            case .background:
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    // just a breakpoint placeholder for simulating background fetch:
                    print("")
                    // to simulate background fetch, execute the following debugger command:
                    //   e -l objc -- (void)[[BGTaskScheduler sharedScheduler] _simulateLaunchForTaskWithIdentifier:@"io.yonat.EasyBackgroundRefreshDemo"]
                }
            default:
                break
            }
        }
    }

    func refresh(backgroundRefresh: EasyBackgroundRefresh) {
        // mark processing of background refresh:
        // (you can omit this if you are sure it will take less than `backgroundRefresh.autoCompleteDelay`)
        backgroundRefresh.isProcessing = true
        defer {
            backgroundRefresh.isProcessing = false
        }

        // perform the background refresh:
        let now = Date.now
        backgroundRefreshTimes.append(now)
        print("Background fetch occurred at", now)
    }
}
