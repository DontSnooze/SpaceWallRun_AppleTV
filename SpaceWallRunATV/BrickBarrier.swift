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
    var startBrickCount:Int = 0
    var endBrickCount:Int = 0
    var wallScore:Int = 0
    var timer = Timer()
    var node:SCNNode!
    var gotWallScore = false
    var pointsPerWall = 4
    var gameMode: GameModeType = .thru
    var hasStartedFullMove = false;
    
    init(position: SCNVector3, forGameMode: GameModeType) {
        
        super.init()
        //        let wallScene = SCNScene(named: "art.scnassets/WallScene.scn")
        //        node = wallScene?.rootNode.childNode(withName:
        //            "Wall", recursively: true)!.clone()
        
        node = createBrickBarrier(width: 4, height: 4, position: position, forGameMode: forGameMode)
        
        node.position = position
        
        node.runAction(SCNAction.moveBy(x: 0, y: 0, z: -240.0, duration: 20.0))
        gameMode = forGameMode
        
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            DispatchQueue.main.async {
                self.checkLocation()
            }
        }
    }
    
    @objc func checkLocation() {
        
        if node.position.z < -8 {
            
            node.removeFromParentNode()
            timer.invalidate()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        brick.name = "UnbreakableBrick"
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
            if i % 4 == 0 {
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
