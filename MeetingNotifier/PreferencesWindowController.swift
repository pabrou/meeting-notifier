//
//  PreferencesWindowController.swift
//  MeetingNotifier
//
//  Created by Pablo Roulet on 18/06/2019.
//  Copyright © 2019 Pablo Roulet. All rights reserved.
//

import Cocoa

class PreferencesWindowController: NSWindowController {
    
    @IBOutlet weak var connectedPeersTextField: NSTextField!
    
    convenience init() {
        self.init(windowNibName: "PreferencesWindowController")
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
    }
}

