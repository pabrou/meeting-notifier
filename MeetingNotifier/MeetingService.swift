//
//  MeetingClass.swift
//  MeetingAlert
//
//  Created by Pablo Roulet on 14/06/2019.
//  Copyright © 2019 Pablo Roulet. All rights reserved.
//

import Foundation
import MultipeerConnectivity
import SystemConfiguration

class MeetingService : NSObject {
    
    // Service type must be a unique string, at most 15 characters long
    // and can contain only ASCII lowercase letters, numbers and hyphens.
    private let MeetingNotifierServiceType = "meeting-notifr"
    
    private var myPeerId : MCPeerID!
    private var serviceAdvertiser : MCNearbyServiceAdvertiser!
    private var serviceBrowser : MCNearbyServiceBrowser!
    
    var meetingInProgress = false
    
    var delegate : MeetingServiceDelegate?
    
    lazy var session : MCSession = {
        let session = MCSession(peer: self.myPeerId, securityIdentity: nil, encryptionPreference: .required)
        session.delegate = self
        return session
    }()
    
    override init() {
        super.init()
        
        myPeerId = MCPeerID(displayName: computerIdentifier())
        serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: nil, serviceType: MeetingNotifierServiceType)
        serviceBrowser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: MeetingNotifierServiceType)
        
        serviceAdvertiser.delegate = self
        serviceAdvertiser.startAdvertisingPeer()
        
        serviceBrowser.delegate = self
        serviceBrowser.startBrowsingForPeers()
    }
    
    deinit {
        self.serviceAdvertiser.stopAdvertisingPeer()
        self.serviceBrowser.stopBrowsingForPeers()
    }
    
    func send(inProgress : Bool) {
        meetingInProgress = inProgress
        NSLog("%@", "inProgress: \(inProgress) to \(session.connectedPeers.count) peers")
        
        if session.connectedPeers.count > 0 {
            let data = inProgress ? "meetingOn".data(using: .utf8) : "meetingOff".data(using: .utf8)
            do {
                try self.session.send(data!, toPeers: session.connectedPeers, with: .reliable)
            }
            catch let error {
                NSLog("%@", "Error for sending: \(error)")
            }
        }
    }
    
    func requestStatusCheck() {
        if session.connectedPeers.count > 0 {
            let data = "statusRequest".data(using: .utf8)
            do {
                try self.session.send(data!, toPeers: session.connectedPeers, with: .reliable)
            }
            catch let error {
                NSLog("%@", "Error for sending: \(error)")
            }
        }
    }
    
    private func computerIdentifier() -> String {
        return SCDynamicStoreCopyComputerName(nil, nil) as String? ?? "";
    }
    
}

extension MeetingService : MCNearbyServiceAdvertiserDelegate {
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        NSLog("%@", "didNotStartAdvertisingPeer: \(error)")
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        NSLog("%@", "didReceiveInvitationFromPeer \(peerID)")
        invitationHandler(true, self.session)
    }
}

extension MeetingService : MCNearbyServiceBrowserDelegate {
    
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        NSLog("%@", "didNotStartBrowsingForPeers: \(error)")
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        NSLog("%@", "foundPeer: \(peerID)")
        NSLog("%@", "invitePeer: \(peerID)")
        browser.invitePeer(peerID, to: self.session, withContext: nil, timeout: 10)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        NSLog("%@", "lostPeer: \(peerID)")
    }
}

extension MeetingService : MCSessionDelegate {
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        NSLog("%@", "peer \(peerID) didChangeState: \(state.rawValue)")
        self.delegate?.connectedDevicesChanged(manager: self, connectedDevices:
            session.connectedPeers.map{$0.displayName})
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        NSLog("%@", "didReceiveData: \(data)")
        let strData = String(data: data, encoding: .utf8)!
        
        if strData == "statusRequest" {
            self.send(inProgress: meetingInProgress)
        } else {
            self.delegate?.meetingStatusChanged(manager: self, inProgress: strData == "meetingOn")
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        NSLog("%@", "didReceiveStream")
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        NSLog("%@", "didStartReceivingResourceWithName")
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        NSLog("%@", "didFinishReceivingResourceWithName")
    }
}

protocol MeetingServiceDelegate {
    
    func connectedDevicesChanged(manager : MeetingService, connectedDevices: [String])
    func meetingStatusChanged(manager : MeetingService, inProgress: Bool)
    
}
