//
//  StatusMenuController.swift
//  MeetingNotifier
//
//  Created by Pablo Roulet on 18/06/2019.
//  Copyright © 2019 Pablo Roulet. All rights reserved.
//

import Cocoa

class StatusMenuController: NSObject {
    
    @IBOutlet weak var statusBarMenu: NSMenu!
    @IBOutlet weak var meetingBarItem: NSMenuItem!
    @IBOutlet weak var preferencesBarItem: NSMenuItem!
    
    var statusBarItem: NSStatusItem!
    
    let preferencesWindow = PreferencesWindowController()
    let meetingService = MeetingService()
    
    var meetingInProgress = false
    
    override func awakeFromNib() {
        statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        statusBarItem.menu = statusBarMenu
        
        meetingService.delegate = self
        setMeetingInProgress(inProgress: meetingInProgress, showAlert: false)
        meetingService.requestStatusCheck()
        
//        statusBarMenu.addItem(
//            withTitle: "Preferences...",
//            action: #selector(AppDelegate.showPreferences),
//            keyEquivalent: "")
//
//        statusBarMenu.addItem(
//            withTitle: "Quit",
//            action: #selector(AppDelegate.quitApp),
//            keyEquivalent: "")
    }
    
    @IBAction func toggleMeetingClicked(_ sender: Any) {
        setMeetingInProgress(inProgress: !meetingInProgress, showAlert: false)
        
        meetingService.send(inProgress: meetingInProgress)
    }
    
    @IBAction func openPreferences(_ sender: Any) {
        preferencesWindow.showWindow(self)
    }
    
    @IBAction func quitApp(_ sender: Any) {
        print("Quiting the app :(")
        NSApplication.shared.terminate(self)
    }
    
    func setMeetingInProgress(inProgress: Bool, showAlert: Bool) {
        
        let notification = NSUserNotification()
        notification.soundName = NSUserNotificationDefaultSoundName
        
        if inProgress {
            statusBarItem.button?.title = "🔥"
            meetingBarItem.title = "Toggle meeting OFF"
            notification.title = "Meeting has started"
            notification.informativeText = "Shhhh... hay una meeting cerca, no griten!!"
        } else {
            statusBarItem.button?.title = "🗣️"
            meetingBarItem.title = "Toggle meeting ON"
            notification.title = "Meeting has ended"
            notification.informativeText = "Ya pueden hablar a los gritos sin problema"
        }
        
        if showAlert {
            NSUserNotificationCenter.default.deliver(notification)
        }

        self.meetingInProgress = inProgress
    }
}

extension StatusMenuController : MeetingServiceDelegate {
    
    func connectedDevicesChanged(manager: MeetingService, connectedDevices: [String]) {
        NSLog("Connections: \(connectedDevices)")
        if !meetingInProgress {
            meetingService.requestStatusCheck()
        }
    }
    
    func meetingStatusChanged(manager: MeetingService, inProgress: Bool) {
        OperationQueue.main.addOperation {
            self.setMeetingInProgress(inProgress: inProgress, showAlert: true)
        }
    }
    
}
