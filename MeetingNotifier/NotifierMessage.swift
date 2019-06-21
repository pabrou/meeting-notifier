//
//  NotifierAction.swift
//  MeetingNotifier
//
//  Created by Pablo Roulet on 21/06/2019.
//  Copyright © 2019 Pablo Roulet. All rights reserved.
//

import Foundation

struct NotifierMessage : Codable {
    
    public enum Action : String, Codable {
        case meetingOn, meetingOff, statusRequest
    }
    
    let action : Action
    let meeting : Meeting?
    
    init(action: Action, meeting: Meeting?) {
        self.action = action
        self.meeting = meeting
    }
    
    func data() -> Data {
        return try! JSONEncoder().encode(self)
    }
}

struct Meeting : Codable {
    let id : String
    let duration : TimeInterval
    
    init(id: String) {
        self.id = id
        self.duration = 15
    }
    
    init(id: String, duration: TimeInterval) {
        self.id = id
        self.duration = duration
    }
}
