//
//  Fireball.swift
//  SpaceWallRunATV
//
//  Created by Amos Todman on 3/1/19.
//  Copyright © 2019 Amos Todman. All rights reserved.
//

import UIKit
import SceneKit

class Fireball: NSObject {
    var node:SCNNode!
    var locationTimerKey = "LocationTimerKey"
    
    init(position: SCNVector3) {
        
        super.init()
        //        let wallScene = SCNScene(named: "art.scnassets/WallScene.scn")
        //        node = wallScene?.rootNode.childNode(withName:
        //            "fireball", recursively: true)!.clone()
        
        let g = SCNSphere(radius: 0.25)
        node = SCNNode(geometry: g)
        node.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: node, options: nil))
        node.physicsBody?.contactTestBitMask =
            ColliderType.barrier.rawValue |
            ColliderType.brick.rawValue
        node.name = "fireball"
        
        node.position = position
        
        node.runAction(SCNAction.repeatForever(SCNAction.moveBy(x: 0, y: 0, z: 20.0, duration: 1.0)))
        
        startLocationTimers(for: node)
    }
    
    func startLocationTimers(for node: SCNNode) {
        let delay = SCNAction.wait(duration: 0.5)
        let action = SCNAction.run { _ in
            DispatchQueue.main.async {
                self.checkLocation()
            }
        }
        let actionSequence = SCNAction.sequence([delay, action])
        let repeatForeverAction = SCNAction.repeatForever(actionSequence)
        node.runAction(repeatForeverAction, forKey: locationTimerKey)
    }
    
    func checkLocation() {
        
        if node.position.z > 30 {
            node.removeFromParentNode()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
