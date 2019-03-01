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
    var timer = Timer()
    var node:SCNNode!
    
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
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            DispatchQueue.main.async {
                self.checkLocation()
            }
        }
    }
    
    func checkLocation() {
        
        if node.position.z > 30 {
            node.removeFromParentNode()
            timer.invalidate()
            
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
