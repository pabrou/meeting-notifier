//
//  MeetingManager.swift
//  MeetingNotifier
//
//  Created by Pablo Roulet on 21/06/2019.
//  Copyright © 2019 Pablo Roulet. All rights reserved.
//

import Foundation

class MeetingManager {
    
    let meetingService = MeetingService()
    
    var meetingInProgress = false
    var delegate : MeetingManagerDelegate?
    
    init() {
        meetingService.delegate = self
        meetingService.requestStatusCheck()
    }
}

extension MeetingManager : MeetingServiceDelegate {
    func connectedDevicesChanged(manager: MeetingService, connectedDevices: [String]) {
        
    }
    
    func meetingStatusChanged(manager: MeetingService, inProgress: Bool) {
        
    }
    
}

protocol MeetingManagerDelegate {
    
    func meetingStatusChanged(manager : MeetingManager, inProgress: Bool)
    
}
