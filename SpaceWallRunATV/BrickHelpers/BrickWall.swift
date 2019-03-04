//
//  BrickWall.swift
//  SpaceWallRunATV
//
//  Created by Amos Todman on 3/1/19.
//  Copyright © 2019 Amos Todman. All rights reserved.
//

import UIKit
import SceneKit

class BrickWall: NSObject {
    var startBrickCount:Int = 0
    var endBrickCount:Int = 0
    var wallScore:Int = 0
    var node:SCNNode!
    var gotWallScore = false
    var pointsPerWall = 4
    var gameMode: GameModeType = .thru
    var hasStartedFullMove = false;
    var locationTimerKey = "LocationTimerKey"
    
    init(position: SCNVector3, forGameMode: GameModeType) {
        
        super.init()
        //        let wallScene = SCNScene(named: "art.scnassets/WallScene.scn")
        //        node = wallScene?.rootNode.childNode(withName:
        //            "Wall", recursively: true)!.clone()
        
        node = createBrickWall(width: 4, height: 8, position: position, forGameMode: forGameMode)
        
        node.position = position
        
        node.runAction(SCNAction.moveBy(x: 0, y: 0, z: -240.0, duration: 20.0))
        gameMode = forGameMode
        if forGameMode == .thru {
            GameViewController.removeFourRandomBlocks(fromWall: node!, gridWidth: 4, gridHeight: 8)
        }
        if forGameMode == .shootThru {
            GameViewController.replaceFourRandomBlocks(fromWall: node, gridWidth: 4, gridHeight: 8, with: .unbreakable)
        }
        if forGameMode == .angleMove {
            let spins = [-2, -1, 1, 2]
            let randomNum1:UInt32 = arc4random_uniform(UInt32(spins.count))
            let randomNum2:UInt32 = arc4random_uniform(UInt32(spins.count))
            let randomNum3:UInt32 = arc4random_uniform(UInt32(spins.count))
            let randomNum4:UInt32 = arc4random_uniform(UInt32(2))
            let randomIndex1:Int = Int(randomNum1)
            let randomIndex2:Int = Int(randomNum2)
            let randomIndex3:Int = Int(randomNum3)
            let randomIndex4:Int = Int(randomNum4)
            
            
            
            node.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: CGFloat(spins[randomIndex1]), y: CGFloat(spins[randomIndex2]), z: CGFloat(spins[randomIndex3]), duration: 0.5)))
            
            if  randomIndex4 > 0 {
                // flip wall so it spin the other way
                node.eulerAngles.y = Float(180).degreesToRadians
                node.position.x = 8.0
            }
            
            // move around sometimes so you cant stay in the same place - particularly top left
            let left = SCNVector3Make(6, 0, 0)
            let right = SCNVector3Make(-2, 0, 0)
            let up = SCNVector3Make(0, 6, 0)
            let down = SCNVector3Make(0, -4, 0)
            
            let possibleDirections = [left, up,]
            
            let randomNum:UInt32 = arc4random_uniform(UInt32(possibleDirections.count))
            let randomIndex:Int = Int(randomNum)
            
            let selectedDirection = possibleDirections[randomIndex]
            
            node.runAction(SCNAction.moveBy(x: CGFloat(selectedDirection.x), y: CGFloat(selectedDirection.y), z: CGFloat(selectedDirection.z), duration: 3.0))
            
        }
        
        if forGameMode == .spin {
            let min = node.boundingBox.min
            let max = node.boundingBox.max
            
            let w = CGFloat(max.x - min.x)
            let h = CGFloat(max.y - min.y)
            let l =  CGFloat( max.z - min.z)
            
            let spinType = randomSpinType()
            let spinDirection = randomSpinDirection()
            var spinAxis = randomSpinAxis()
            var rotationValue = 2 * Double.pi
            var pivot = w / 2
            var moveXByAmount:CGFloat = 0;
            var moveYByAmount:CGFloat = 0;
            var rotationAction = SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: CGFloat(-rotationValue), z: 0, duration: 1))
            if spinDirection == .clockwise {
                rotationValue = -rotationValue
            }
            
            switch (spinType) {
            case .left:
                moveXByAmount = w
                spinAxis = .y
                break;
            case .center:
                if spinAxis == .x {
                    moveYByAmount = h / 2
                } else {
                    moveXByAmount = w / 2
                }
                break;
            case .right:
                moveXByAmount = 0
                spinAxis = .y
                break;
            case .top:
                moveYByAmount = h
                spinAxis = .x
                break;
            case .bottom:
                spinAxis = .x
                break;
            }
            
            node.pivot = SCNMatrix4MakeTranslation(Float(pivot), 0, 0)
            if spinAxis == .x {
                pivot = h / 2
                node.pivot = SCNMatrix4MakeTranslation(0, Float(pivot), 0)
                rotationAction = SCNAction.repeatForever(SCNAction.rotateBy(x: CGFloat(rotationValue), y: 0, z: 0, duration: 1))
            }
            
            if spinAxis == .y {
                pivot = w / 2
                node.pivot = SCNMatrix4MakeTranslation(Float(pivot), 0, 0)
                rotationAction = SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: CGFloat(rotationValue), z: 0, duration: 1))
            }
            
            node.runAction(SCNAction.moveBy(x: moveXByAmount, y: moveYByAmount, z: 0, duration: 1))
            
            node.runAction(rotationAction)
        }
        
        startBrickCount = node.childNodes.count
        startLocationTimers(for: node)
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
        node.runAction(repeatForeverAction, forKey: locationTimerKey)
    }
    
    @objc func checkLocation() {
        if gameMode == .fullMove {
            if node.position .z < 25 {
                
                if !hasStartedFullMove {
                    hasStartedFullMove = true
                    
                    let left = SCNVector3Make(4, 0, 0)
                    let right = SCNVector3Make(-4, 0, 0)
                    let up = SCNVector3Make(0, 4, 0)
                    let down = SCNVector3Make(0, -4, 0)
                    
                    let possibleDirections = [left, right, up, down]
                    
                    let randomNum:UInt32 = arc4random_uniform(UInt32(possibleDirections.count))
                    let randomIndex:Int = Int(randomNum)
                    
                    let selectedDirection = possibleDirections[randomIndex]
                    
                    node.runAction(SCNAction.moveBy(x: CGFloat(selectedDirection.x), y: CGFloat(selectedDirection.y), z: CGFloat(selectedDirection.z), duration: 1.0))
                }
            }
        }
        
        if node.position.z < 1 && !gotWallScore {
            gotWallScore = true
            endBrickCount = node.childNodes.count
            
            if node.name == "UnbreakableWall" {
                let nodeDict:[String: SCNNode] = ["node": node]
                
                if startBrickCount - endBrickCount == 0 {
                    if gameMode == .thru {
                        wallScore += UnbreakableWallPoint.level2.rawValue
                    }
                }
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "WillRemoveUnbreakableWall"), object: nodeDict)
            }
            GameHelper.sharedInstance.score += wallScore
            GameHelper.sharedInstance.saveState()
            node.removeFromParentNode()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    class func createBrick(position: SCNVector3, forGameMode: GameModeType) -> SCNNode {
        let g = SCNBox(width: 2.0, height: 1.0, length: 1.0, chamferRadius: 0.05)
        let brick = SCNNode(geometry: g)
        
        
        brick.name = "brick"
        brick.position = position
        
        #if !targetEnvironment(simulator)
        brick.physicsBody = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(node: brick, options: nil))
        brick.physicsBody?.contactTestBitMask = ColliderType.ship.rawValue
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
        
        brick.geometry?.firstMaterial?.transparency = 0.75
        
        
        brick.geometry?.firstMaterial?.specular.contents = UIColor.white
        //        brick.geometry?.firstMaterial?.reflective.contents = UIColor.black
        
        var brickColor:UIColor!
        switch forGameMode {
        case .thru:
            brickColor = UIColor.black
            brick.geometry?.firstMaterial?.transparency = 0.9
            brick.geometry?.firstMaterial?.specular.contents = UIColor.gray
            brick.name = "UnbreakableBrick"
        case .shootThru:
            brickColor = UIColor.black
            brick.geometry?.firstMaterial?.transparency = 0.9
            brick.geometry?.firstMaterial?.specular.contents = UIColor.gray
            brick.name = "UnbreakableBrick"
            
        default:
            brickColor = UIColor.cyan
        }
        brick.geometry?.firstMaterial?.diffuse.contents = brickColor
        
        return brick
    }
    
    func createBrickWall(width: Int, height: Int, position: SCNVector3, forGameMode: GameModeType) -> SCNNode {
        
        let numberOfBricks = width * height
        
        let wall = SCNNode()
        wall.name = "Wall"
        if forGameMode == .thru {
            wall.name = "UnbreakableWall"
        }
        
        var brickPosition = SCNVector3Make(1, 0.5, 0)
        for i in 1...numberOfBricks {
            let wallBrick = BrickWall.createBrick(position: brickPosition, forGameMode: forGameMode)
            wall.addChildNode(wallBrick)
            if i % 4 == 0 {
                brickPosition.x = 1
                brickPosition.y += 1
            } else {
                brickPosition.x += 2
            }
        }
        wall.position = position
        return wall
    }
}
