//
//  BrickBarrier.swift
//  SpaceWallRunATV
//
//  Created by Amos Todman on 3/1/19.
//  Copyright © 2019 Amos Todman. All rights reserved.
//

import UIKit
import SceneKit

class BrickBarrier: NSObject {
    var barrier1:SCNNode!
    var barrier2: SCNNode!
    var startingPosition: SCNVector3!
    var currentBarrier: SCNNode!
    var gameMode: GameModeType = .thru
    
    init(position: SCNVector3, parentNode: SCNNode, forGameMode: GameModeType) {
        
        super.init()
        //        let wallScene = SCNScene(named: "art.scnassets/WallScene.scn")
        //        node = wallScene?.rootNode.childNode(withName:
        //            "Wall", recursively: true)!.clone()
        
        barrier1 = createBrickBarrier(width: 40, height: 4, position: position, forGameMode: forGameMode)
        barrier2 = createBrickBarrier(width: 40, height: 4, position: position, forGameMode: forGameMode)
        
        startingPosition = position
        barrier1.position = position
        barrier2.position = position
        barrier2.position.z = barrier2.position.z + 300
        currentBarrier = barrier1
        
        //node.runAction(SCNAction.moveBy(x: 0, y: 0, z: -240.0, duration: 20.0))
        gameMode = forGameMode
        
        parentNode.addChildNode(barrier1)
        parentNode.addChildNode(barrier2)
        
        startLocationTimers(for: currentBarrier)
    }
    
    init(parentNode: SCNNode, baseBarrier: SCNNode) {
        
        super.init()
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
        
        startLocationTimers(for: currentBarrier)
    }
    
    func startLocationTimers(for node: SCNNode) {
        let delay = SCNAction.wait(duration: 0.1)
        let action = SCNAction.run { _ in
            DispatchQueue.main.async {
                self.checkLocation()
            }
        }
        let actionSequence = SCNAction.sequence([delay, action])
        let repeatForeverAction = SCNAction.repeatForever(actionSequence)
        node.runAction(repeatForeverAction, forKey: brickBarrierLocationTimerKey)
    }
    
    func checkLocation() {
        if currentBarrier.position.z < -20 {
            currentBarrier.removeAction(forKey: brickBarrierLocationTimerKey)
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
    
    class func createBarrierBrick(position: SCNVector3, forGameMode: GameModeType) -> SCNNode {
        let g = SCNBox(width: 1.0, height: 2.0, length: 4.0, chamferRadius: 0.05)
        let brick = SCNNode(geometry: g)
        
        
        brick.name = "BarrierBrick"
        brick.position = position
        
        #if !targetEnvironment(simulator)
        brick.physicsBody = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(node: brick, options: nil))
        brick.physicsBody?.categoryBitMask = ColliderType.brick.rawValue
        brick.physicsBody?.mass = 1.0
        brick.physicsBody?.friction = 0
        brick.physicsBody?.restitution = 0
        brick.physicsBody?.rollingFriction = 0
        brick.physicsBody?.damping = 0
        brick.physicsBody?.angularDamping = 0
        brick.physicsBody?.charge = 0
        brick.physicsBody?.isAffectedByGravity = false
        
        #endif
        
        let brickColor = UIColor.black
        brick.geometry?.firstMaterial?.transparency = 0.9
        brick.geometry?.firstMaterial?.specular.contents = UIColor.gray
        brick.geometry?.firstMaterial?.diffuse.contents = brickColor
        
        return brick
    }
    
    func createBrickBarrier(width: Int, height: Int, position: SCNVector3, forGameMode: GameModeType) -> SCNNode {
        
        let numberOfBricks = width * height
        
        let wall = SCNNode()
        wall.name = "BarrierWall"
        
        var brickPosition = SCNVector3Make(1, 0.5, 0)
        for i in 1...numberOfBricks {
            let wallBrick = BrickBarrier.createBarrierBrick(position: brickPosition, forGameMode: forGameMode)
            wall.addChildNode(wallBrick)
            if i % width == 0 {
                brickPosition.z = 0
                brickPosition.y += 2
            } else {
                brickPosition.z += 4
            }
        }
        wall.position = position
        return wall
    }
}
