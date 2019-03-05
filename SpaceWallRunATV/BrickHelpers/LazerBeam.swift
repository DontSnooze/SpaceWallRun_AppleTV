//
//  LazerBeam.swift
//  SpaceWallRunATV
//
//  Created by Amos Todman on 3/4/19.
//  Copyright © 2019 Amos Todman. All rights reserved.
//

import UIKit
import SceneKit

class LazerBeam: NSObject {
    var node:SCNNode!
    var locationTimerKey = "LocationTimerKey"
    var radialTimerKey = "RadialTimerKey"
    var cylinder = SCNCylinder(radius: 0.20, height: 50)
    var vurrentRadial: Int = 7
    
    init(position: SCNVector3) {
        
        super.init()
        cylinder.radialSegmentCount = 7
        node = SCNNode(geometry: cylinder)
        node.position = position
        node.eulerAngles.x = Float(-90.0).degreesToRadians
        node.name = "LazerBeam"

        node.physicsBody = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(node: node, options: nil))
        
        node.physicsBody?.contactTestBitMask =
            ColliderType.barrier.rawValue |
            ColliderType.brick.rawValue
        
        node.physicsBody?.mass = 1.0
        node.physicsBody?.friction = 0
        node.physicsBody?.restitution = 0
        node.physicsBody?.rollingFriction = 0
        node.physicsBody?.damping = 0
        node.physicsBody?.angularDamping = 0
        node.physicsBody?.charge = 0
        node.physicsBody?.isAffectedByGravity = false
        
        
        node.geometry?.firstMaterial?.transparency = 0.95
        node.geometry?.firstMaterial?.specular.contents = UIColor.cyan
        
//        let purpleColor = UIColor(red: 226/255, green: 0/255, blue: 132/255, alpha: 1.0) /* #e20084 */
        node.geometry?.firstMaterial?.diffuse.contents = UIColor.white
        
        node.runAction(SCNAction.repeatForever(SCNAction.moveBy(x: 0, y: 0, z: 20.0, duration: 1.0)))
        
        startLocationTimers(for: node)
        startRadialTimers(for: node)
    }
    
    func startRadialTimers(for node: SCNNode) {
        let delay = SCNAction.wait(duration: 0.5)
        let action = SCNAction.run { _ in
            DispatchQueue.main.async {
                self.switchRadial()
            }
        }
        let actionSequence = SCNAction.sequence([delay, action])
        let repeatForeverAction = SCNAction.repeatForever(actionSequence)
        node.runAction(repeatForeverAction, forKey: radialTimerKey)
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
        
        if node.position.z > 60 {
            node.removeFromParentNode()
        }
    }
    
    func switchRadial() {
        cylinder.radialSegmentCount = Int(arc4random_uniform(7))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
