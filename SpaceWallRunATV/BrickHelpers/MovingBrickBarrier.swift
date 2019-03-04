//
//  MovingBrickBarrier.swift
//  SpaceWallRun
//
//  Created by Amos Todman on 12/5/16.
//  Copyright © 2016 Amos Todman. All rights reserved.
//

import UIKit
import SceneKit

class MovingBrickBarrier: NSObject {
    
    var barrier1:SCNNode!
    var barrier2: SCNNode!
    var startingPosition: SCNVector3!
    var currentBarrier: SCNNode!
    var locationTimerKey = "LocationTimerKey"
    
    init(position: SCNVector3, parentNode: SCNNode) {
        
        super.init()
        let wallScene = SCNScene(named: "art.scnassets/BrickBarrierScene.scn")
        barrier1 = wallScene?.rootNode.childNode(withName:
            "BrickBarriers", recursively: true)!.clone()
        barrier2 = wallScene?.rootNode.childNode(withName:
            "BrickBarriers", recursively: true)!.clone()
        
        startingPosition = position
        barrier1.position = position
        barrier2.position = position
        barrier2.position.z = barrier2.position.z + 300
        currentBarrier = barrier1
        
        
        parentNode.addChildNode(barrier1)
        parentNode.addChildNode(barrier2)
        
        barrier1.runAction(SCNAction.repeatForever(SCNAction.moveBy(x: 0, y: 0, z: -20, duration: 1)))
        barrier2.runAction(SCNAction.repeatForever(SCNAction.moveBy(x: 0, y: 0, z: -20, duration: 1)))
    }
    
    init(parentNode: SCNNode, baseBarrier: SCNNode) {
        
        super.init()
        _ = SCNScene(named: "art.scnassets/BrickBarrierScene.scn")
        barrier1 = baseBarrier
        barrier2 = barrier1.clone()
        
        startingPosition = baseBarrier.position
        barrier1.position = startingPosition
        barrier2.position = startingPosition
        barrier2.position.z = barrier2.position.z + 300
        
        
        
        currentBarrier = barrier1
        //        parentNode.addChildNode(barrier1)
        
        parentNode.addChildNode(barrier2)
        barrier1.runAction(SCNAction.repeatForever(SCNAction.moveBy(x: 0, y: 0, z: -20, duration: 1)))
        barrier2.runAction(SCNAction.repeatForever(SCNAction.moveBy(x: 0, y: 0, z: -20, duration: 1)))
        
        //        barrier1.isHidden = true
        //        barrier2.isHidden = true
        
    }
    
    func startLocationTimers(for node: SCNNode) {
        let delay = SCNAction.wait(duration: 0.1)
        let action = SCNAction.run { _ in
            self.checkLocation()
        }
        let actionSequence = SCNAction.sequence([delay, action])
        let repeatForeverAction = SCNAction.repeatForever(actionSequence)
        node.runAction(repeatForeverAction, forKey: locationTimerKey)
    }
    
    func checkLocation() {
        if currentBarrier.position.z < -20 {
            currentBarrier.removeAction(forKey: locationTimerKey)
            // add the other barrier to the end
            currentBarrier = barrier1 == currentBarrier ? barrier2 : barrier1
            
            // 300 is the width of the barrier
            // 122 is the original z position of the barrier
            currentBarrier?.position.z = 275
            start()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func start() {
        startLocationTimers(for: currentBarrier)
    }
    
    
    
}
