//
//  ContentView.swift
//  EasyBackgroundRefreshDemo
//
//  Created by Yonat Sharon on 15/08/2022.
//

import SwiftUI

struct ContentView: View {
    @Binding var times: [Date]

    var body: some View {
        NavigationView {
            Group {
                if times.isEmpty {
                    Text(LocalizedStringKey(instructions))
                        .padding()
                } else {
                    List(times.reversed()) { time in
                        Text(time.description)
                    }
                }
            }
            .navigationTitle("Background Refresh Times")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    let instructions = """
    Move the app to background, and let it stay there for a while.
    Background refresh times will be shown here when you later open the app.

    To test, add breakpoint that executes the following debugger command:

    `e -l objc -- (void)[[BGTaskScheduler sharedScheduler] _simulateLaunchForTaskWithIdentifier:@"io.yonat.EasyBackgroundRefreshDemo"]`
    """
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(times: .constant([]))
    }
}

extension Date: Identifiable {
    // bad, don't do that - just for demo:
    public var id: Date { self }
}
