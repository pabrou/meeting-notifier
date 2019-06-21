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
    
    var statusBarItem: NSStatusItem!
    
    let preferencesWindow = PreferencesWindowController()
    let meetingService = MeetingService()
    
    var meetingInProgress = false
    
    override func awakeFromNib() {
        statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        statusBarItem.menu = statusBarMenu
        
        meetingService.delegate = self
        setMeetingInProgress(inProgress: meetingInProgress)
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
    
    @IBAction func alertMeetingClicked(_ sender: Any) {
        setMeetingInProgress(inProgress: !meetingInProgress)
        
        meetingService.send(inProgress: meetingInProgress)
    }
    
    @IBAction func openPreferences(_ sender: Any) {
        preferencesWindow.showWindow(self)
    }
    
    @IBAction func quitApp(_ sender: Any) {
        print("Quiting the app :(")
        NSApplication.shared.terminate(self)
    }
    
    func setMeetingInProgress(inProgress: Bool) {
        if inProgress {
            statusBarItem.button?.title = "🔴"
        } else {
            statusBarItem.button?.title = "🙂"
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
            self.setMeetingInProgress(inProgress: inProgress)
        }
    }
    
}
