//
//  EasyBackgroundRefresh.swift
//
//  Created by Yonat Sharon on 11/07/2022.
//

import BackgroundTasks
import UIKit

/// Handles background refresh registration, scheduling, execution, and completion.
///
/// Usage:
///   1. Enable background refresh and add Info.plist keys as described in [Apple docs](https://developer.apple.com/documentation/uikit/app_and_environment/scenes/preparing_your_ui_to_run_in_the_background/using_background_tasks_to_update_your_app).
///   2. Create an `EasyBackgroundRefresh` instance (e.g. `EasyBackgroundRefresh.default`) in your `App` or `AppDelegate`.
///     **Note**: The instance must be created before app finished launching, because it registers the task identifier.
///   3. To have you code called when the refresh occurs, set the `action` of the instance you created:
///     `backgroundRefresh.action = { /* your code */ }`
///   4. If your action might take more than `autoCompleteDelay`, set `backgroundRefresh.isProcessing` to `true`
///     to mark the refresh is active, and when completing the refresh - set it to `false`.
open class EasyBackgroundRefresh {
    /// Handles tasks with identifier ==`Bundle.main.bundleIdentifier!`
    public static let `default` = EasyBackgroundRefresh()

    /// Must match Info.plist value for `BGTaskSchedulerPermittedIdentifiers`
    public let taskIdentifier: String

    /// Code to execute when app refresh occurs. Should set `isProcessing` to `true` to get processing time, and then to `false` when done.
    public var action: ((EasyBackgroundRefresh) -> Void)?

    /// Number of seconds to wait before marking the background task as completed, unless `isProcessing` is set to `true`.
    public var autoCompleteDelay: TimeInterval = 1

    /// Seconds to delay background refresh (the OS may decide to delay it even more). Similar to `UIApplication.setMinimumBackgroundFetchInterval()`.
    public var backgroundFetchDelay: TimeInterval = 0

    /// Set to `true` when processing a background task, and then set to `false` when the task is completed.
    public var isProcessing = false {
        didSet {
            if oldValue && !isProcessing {
                completeBackgroundRefresh()
            }
        }
    }

    public private(set) var refreshTask: BGTask?

    /// Create a new background refresh handler.
    /// - Parameters:
    ///   - taskIdentifier: Must match Info.plist value for `BGTaskSchedulerPermittedIdentifiers`. Default: `Bundle.main.bundleIdentifier`
    ///   - autoCompleteDelay: Number of seconds to wait before marking the background task as completed, unless `isProcessing` is set to `true`.
    ///   - backgroundFetchDelay: Seconds to delay background refresh (the OS may decide to delay it even more). Similar to `UIApplication.setMinimumBackgroundFetchInterval()`.
    ///   - action: Code to execute when app refresh occurs. Should set `isProcessing` to `true` to get processing time, and then to `false` when done.
    public init(
        taskIdentifier: String = Bundle.main.bundleIdentifier!,
        autoCompleteDelay: TimeInterval = 1,
        backgroundFetchDelay: TimeInterval = 0,
        action: ((EasyBackgroundRefresh) -> Void)? = nil
    ) {
        self.taskIdentifier = taskIdentifier
        self.autoCompleteDelay = autoCompleteDelay
        self.backgroundFetchDelay = backgroundFetchDelay
        self.action = action
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: taskIdentifier,
            using: nil,
            launchHandler: handleBackgroundRefresh(task:)
        )
        notificationObservation = NotificationCenter.default.addObserver(
            forName: UIApplication.didEnterBackgroundNotification,
            object: nil,
            queue: nil,
            using: { [weak self] _ in self?.scheduleBackgroundRefresh() }
        )
    }

    // MARK: - Private

    private var notificationObservation: NSObjectProtocol?
    private var backgroundTaskIdentifier: UIBackgroundTaskIdentifier?
    private var autoCompleteDispatchWorkItem: DispatchWorkItem?

    private func scheduleBackgroundRefresh() {
        #if targetEnvironment(simulator)
        print("EasyBackgroundRefresh: No background app refresh on simulator :-(")
        #else
        do {
            let request = BGAppRefreshTaskRequest(identifier: taskIdentifier)
            if backgroundFetchDelay > 0 {
                request.earliestBeginDate = Date() + backgroundFetchDelay
            }
            try BGTaskScheduler.shared.submit(request)

            #if DEBUG
            // to simulate background refresh during development, add a breakpoint in the next line
            // and execute this debugger command (replacing TASK_IDENTIFIER):
            //   e -l objc -- (void)[[BGTaskScheduler sharedScheduler] _simulateLaunchForTaskWithIdentifier:@"TASK_IDENTIFIER"]
            print("EasyBackgroundRefresh: Submitted background refresh request")
            #endif
        } catch {
            fatalError("EasyBackgroundRefresh: Failed submitting BGAppRefreshTaskRequest: \(error)")
        }
        #endif
    }

    private func handleBackgroundRefresh(task: BGTask) {
        refreshTask = task

        // ensure any subsequent async dispatches will be performed while app is in background:
        backgroundTaskIdentifier = UIApplication.shared.beginBackgroundTask(expirationHandler: { [weak self] in
            self?.endBackgroundTask()
        })

        // auto-complete background refresh if caller didn't set .isProcessing:
        let dispatchWorkItem = DispatchWorkItem { [weak self] in
            guard let self = self else {
                task.setTaskCompleted(success: true)
                return
            }
            if !self.isProcessing {
                self.completeBackgroundRefresh()
            }
            self.endBackgroundTask()
        }
        autoCompleteDispatchWorkItem = dispatchWorkItem
        DispatchQueue.main.asyncAfter(deadline: .now() + autoCompleteDelay, execute: dispatchWorkItem)

        action?(self)
    }

    private func completeBackgroundRefresh() {
        guard let task = refreshTask else { return }
        refreshTask = nil
        DispatchQueue.main.async { [weak self] in
            if UIApplication.shared.applicationState == .background {
                self?.scheduleBackgroundRefresh()
            }
            task.setTaskCompleted(success: true)
            self?.endBackgroundTask()
        }
    }

    private func endBackgroundTask() {
        autoCompleteDispatchWorkItem?.cancel()
        autoCompleteDispatchWorkItem = nil
        if let backgroundTaskIdentifier = backgroundTaskIdentifier {
            UIApplication.shared.endBackgroundTask(backgroundTaskIdentifier)
            self.backgroundTaskIdentifier = nil
        }
    }
}
