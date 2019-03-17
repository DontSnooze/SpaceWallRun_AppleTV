//
//  GameViewController.swift
//  SpaceWallRun
//
//  Created by Amos Todman on 12/4/16.
//  Copyright © 2016 Amos Todman. All rights reserved.
//

import UIKit
import SceneKit
import SpriteKit
import GameController

enum ColliderType: Int {
    case ship     = 0b0001
    case barrier  = 0b0010
    case brick    = 0b0100
}

enum GameModeType: Int {
    case thru     = 0
    case fullMove  = 1
    case angleMove = 2
    case spin = 3
    case shootThru = 4
}

func randomGameModeType() -> GameModeType {
    let possibles:[GameModeType] = [.thru, .fullMove, .angleMove, .spin, .shootThru]
    
    let randomNum:UInt32 = arc4random_uniform(UInt32(possibles.count))
    let randomIndex:Int = Int(randomNum)
    
    let result = possibles[randomIndex]
    return result
}

enum BrickType: Int {
    case breakable     = 0
    case unbreakable  = 1
}

enum SpinType: Int {
    case left     = 0
    case center  = 1
    case right = 2
    case top = 3
    case bottom = 4
}

func randomSpinType() -> SpinType {
    let possibles:[SpinType] = [.left, .center, .right, .top, .bottom]
    
    let randomNum:UInt32 = arc4random_uniform(UInt32(possibles.count))
    let randomIndex:Int = Int(randomNum)
    
    let result = possibles[randomIndex]
    return result
}

enum SpinDirection: Int {
    case clockwise
    case counterClockwise
}

func randomSpinDirection() -> SpinDirection {
    let possibles:[SpinDirection] = [.clockwise, .counterClockwise]
    
    let randomNum:UInt32 = arc4random_uniform(UInt32(possibles.count))
    let randomIndex:Int = Int(randomNum)
    
    let result = possibles[randomIndex]
    return result
}

enum SpinAxis: Int {
    case x
    case y
}

func randomSpinAxis() -> SpinAxis {
    let possibles:[SpinAxis] = [.x, .y]
    
    let randomNum:UInt32 = arc4random_uniform(UInt32(possibles.count))
    let randomIndex:Int = Int(randomNum)
    
    let result = possibles[randomIndex]
    return result
}

class GameViewController: GCEventViewController {

    @IBOutlet weak var scnView: SCNView!
    @IBOutlet weak var hudLabel: UILabel!
    @IBOutlet weak var playPauseButton: UIButton!
    var scnScene: SCNScene!
    var shipNode: SCNNode!
    var lastContactNode: SCNNode!
    var touchX: CGFloat = 0
    var shipX: Float = 0
    var touchY: CGFloat = 0
    var shipY: Float = 0
    var floorNode: SCNNode!
    var shipCameraNode: SCNNode!
    var game = GameHelper.sharedInstance
    var spriteScene: SKScene!
    var movingBarriers: MovingBarrier!
//    var movingBrickBarriers: BrickBarrier!
    var movingBrickBarriers: MovingBrickBarrier!
    var gameMode:GameModeType = .thru
    var pointTally = 0
    var unbreakableWalls = [SCNNode]()
    var gameLevel = GameLevel.two
    var lastScore: Int = 0
    var joystickSensitivity = 5
    
    let controllerHelper = GameControllerHelper()
    var gameMenuType: GameMenuType = .main
    
    var gameMenuView: GameMenuViewController?
    
    //let moveAnalogStick =  🕹(diameter: 110)
    //let rotateAnalogStick = AnalogJoystick(diameter: 100)
    
    // MARK: - UIViewController -
    
    override func viewDidLoad() {
        super.viewDidLoad()

        game.delegate = self
        setupScene()
        
        spriteScene = SKScene(size: self.view.frame.size)
        scnView.overlaySKScene = self.spriteScene
        setupNodes()
        setupSounds()
        game.playSound(shipNode, name: "bgSong")
        controllerHelper.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.willRemoveUnbreakableWall(_:)), name: NSNotification.Name(rawValue: "WillRemoveUnbreakableWall"), object: nil)
        scnScene.isPaused = true
        
        startWallTimers()
        startHudTimers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        showMenu(true)
    }
    
    // MARK: - Timers -
    
    func startWallTimers() {
        let delay = SCNAction.wait(duration: 3.0)
        let addWallAction = SCNAction.run { _ in
            DispatchQueue.main.async {
                self.addWall()
            }
        }
        let sequence = SCNAction.sequence([delay, addWallAction])
        let repeatForever = SCNAction.repeatForever(sequence)
        scnScene.rootNode.runAction(repeatForever, forKey: wallTimerKey)
    }
    
    func startHudTimers() {
        let delay = SCNAction.wait(duration: 0.5)
        let action = SCNAction.run { _ in
            DispatchQueue.main.async {
                self.updateHud()
            }
        }
        let actionSequence = SCNAction.sequence([delay, action])
        let repeatForeverAction = SCNAction.repeatForever(actionSequence)
        scnScene.rootNode.runAction(repeatForeverAction, forKey: hudTimerKey)
    }
    
    // MARK: - Setup -
    
    func setupSounds() {
        #if !targetEnvironment(simulator)
        game.loadSound("Brick",
                       fileNamed: "ExplodeGood.wav", loops: false)
        game.loadSound("Blaster",
                       fileNamed: "blaster.mp3", loops: false)
        game.loadSound("bgSong",
                       fileNamed: "SuperTrebleTest.mp3", loops: true)
        #endif
    }
    
    func setupHUD() {
        game.hudNode.position = SCNVector3(x: 4, y: 4.0, z: 2.4)
        scnScene.rootNode.addChildNode(game.hudNode)
    }
    
    func setupScene() {
        //scnView = self.view as! SCNView
        scnView.delegate = self
        
        scnScene = SCNScene(named: "art.scnassets/WallScene.scn")
        scnView.scene = scnScene
        scnScene.physicsWorld.contactDelegate = self
        scnView.backgroundColor = UIColor.black
    }

    func setupNodes() {
        shipCameraNode = scnScene.rootNode.childNode(withName:
            "ShipCamera", recursively: true)!
        
        //let shipScene =  SCNScene(named: "ship.scnassets/spaceShipScene.scn")
        //shipNode.removeFromParentNode()
//        shipNode = shipScene?.rootNode.childNode(withName:
//              "Ship", recursively: true)!
//        shipNode.position = SCNVector3Make(4.0, 3.0, 2.408)
        shipNode = scnScene.rootNode.childNode(withName:
            "Ship", recursively: true)!
        shipNode.physicsBody?.contactTestBitMask =
            ColliderType.barrier.rawValue |
            ColliderType.brick.rawValue
        
        scnScene.rootNode.addChildNode(shipNode)
        floorNode =
            scnScene.rootNode.childNode(withName: "Floor",
                                        recursively: true)!
        scnView.pointOfView = shipCameraNode
        
//         setup moving barriers
//        setupMovingBarriers()
        setupMovingBrickBarriers()

        //        let brickBarrier = BrickBarrier(position: SCNVector3Make(-1.5, 0, 190.0), parentNode: scnScene.rootNode, forGameMode: .thru)
        
//        movingBrickBarriers = BrickBarrier(parentNode: scnScene.rootNode, baseBarrier: brickBarrier.barrier1)
//        movingBrickBarriers.start()
    }
    
    func setupMovingBarriers() {
        let barriers = scnScene.rootNode.childNode(withName:
            "Barriers", recursively: true)!
        movingBarriers = MovingBarrier(parentNode: scnScene.rootNode, baseBarrier: barriers)
        movingBarriers.start()
    }
    
    func setupMovingBrickBarriers() {
        movingBrickBarriers = MovingBrickBarrier(position: SCNVector3Make(-1.5, 0, 190.0), parentNode: scnScene.rootNode)
        movingBrickBarriers.start()
    }
    // MARK: - Walls -
    
    func addWall() {
        let possibleModes:[GameModeType] = [.thru, .fullMove, .angleMove, .spin, .shootThru]
        
        let randomNum:UInt32 = arc4random_uniform(UInt32(possibleModes.count))
        let randomIndex:Int = Int(randomNum)
        
        let gameMode = possibleModes[randomIndex]
        let newWall = BrickWall(position: SCNVector3Make(0, 0, 190.0), forGameMode:gameMode)
        if gameMode == .thru {
            unbreakableWalls.append(newWall.node)
        }
        
        scnScene.rootNode.addChildNode(newWall.node)
    }
    
    func addBrickBarrier() {
        let possibleModes:[GameModeType] = [.thru, .fullMove, .angleMove, .spin, .shootThru]
        
        let randomNum:UInt32 = arc4random_uniform(UInt32(possibleModes.count))
        let randomIndex:Int = Int(randomNum)
        
//        let gameMode = possibleModes[randomIndex]
//        let newWall = BrickBarrier(position: SCNVector3Make(-1.5, 0, 190.0), forGameMode:gameMode)
//
//        scnScene.rootNode.addChildNode(newWall.node)
    }
    
    @objc func updateHud() {
        DispatchQueue.main.async {
            self.hudLabel.text = self.game.labelNode.text
        }
    }
    
    func updateShipCamera() {
        let scaledX = ((self.shipNode.position.x - 4) / 1.5) + 4
        self.shipCameraNode.position.x = scaledX
        let scaledY = ((self.shipNode.position.y - 3.75) / 1.5) + 3.75
        self.shipCameraNode.position.y = scaledY
        //self.shipCameraNode.position.x = self.shipNode.position.x / 1.5
    }
    
    func removeRandomBlock(fromWall:SCNNode) {
        let nodeCount = fromWall.childNodes.count
        let randomNum:UInt32 = arc4random_uniform(UInt32(nodeCount))
        let blockIndex:Int = Int(randomNum)
        fromWall.childNodes[blockIndex].removeFromParentNode()
    }
    
    class func removeFourRandomBlocks(fromWall:SCNNode, gridWidth: Int, gridHeight: Int) {
        let nodeCount = fromWall.childNodes.count
        let randomNum:UInt32 = arc4random_uniform(UInt32(nodeCount))
        
        let startBlockIndex:Int = Int(randomNum)
        var secondBlockIndex = startBlockIndex + 1
        var thirdBlockIndex = 0
        var fourthBlockIndex = 0
        
        if (startBlockIndex + 1) % gridWidth == 0 {
            secondBlockIndex = startBlockIndex - 1
        }
        
        thirdBlockIndex = startBlockIndex + gridWidth
        if (startBlockIndex + 1) > nodeCount - gridWidth {
            thirdBlockIndex = startBlockIndex - gridWidth
        }
        
        fourthBlockIndex = thirdBlockIndex + 1
        if (thirdBlockIndex + 1) % gridWidth == 0 {
            fourthBlockIndex = thirdBlockIndex - 1
        }
        
        let boxes = [fromWall.childNodes[startBlockIndex],fromWall.childNodes[secondBlockIndex],fromWall.childNodes[thirdBlockIndex],fromWall.childNodes[fourthBlockIndex]]
        
        for node in boxes {
            node.removeFromParentNode()
        }
    }
    
    class func replaceFourRandomBlocks(fromWall:SCNNode, gridWidth: Int, gridHeight: Int, with: BrickType) {
        let nodeCount = fromWall.childNodes.count
        let randomNum:UInt32 = arc4random_uniform(UInt32(nodeCount))
        
        let startBlockIndex:Int = Int(randomNum)
        var secondBlockIndex = startBlockIndex + 1
        var thirdBlockIndex = 0
        var fourthBlockIndex = 0
        
        if (startBlockIndex + 1) % gridWidth == 0 {
            secondBlockIndex = startBlockIndex - 1
        }
        
        thirdBlockIndex = startBlockIndex + gridWidth
        if (startBlockIndex + 1) > nodeCount - gridWidth {
            thirdBlockIndex = startBlockIndex - gridWidth
        }
        
        fourthBlockIndex = thirdBlockIndex + 1
        if (thirdBlockIndex + 1) % gridWidth == 0 {
            fourthBlockIndex = thirdBlockIndex - 1
        }
        
        let boxes = [fromWall.childNodes[startBlockIndex],fromWall.childNodes[secondBlockIndex],fromWall.childNodes[thirdBlockIndex],fromWall.childNodes[fourthBlockIndex]]
        
        for node in boxes {
            let newBreakableBrick = BrickWall.createBrick(position: node.position, forGameMode: .spin)
            
            //newBreakableBrick.geometry?.firstMaterial?.transparency = 0.75
            //newBreakableBrick.geometry?.firstMaterial?.specular.contents = UIColor.blue
            fromWall.replaceChildNode(node, with: newBreakableBrick)
        }
    }
    
    func createExplosion(geometry: SCNGeometry, position: SCNVector3,
                         rotation: SCNVector4) {
        // 2
        let explosion =
            SCNParticleSystem(named: "Explode.scnp", inDirectory:
                nil)!
        explosion.emitterShape = geometry
        explosion.birthLocation = .surface
        // 3
        let rotationMatrix =
            SCNMatrix4MakeRotation(rotation.w, rotation.x,
                                   rotation.y, rotation.z)
        let translationMatrix =
            SCNMatrix4MakeTranslation(position.x, position.y,
                                      position.z)
        let transformMatrix =
            SCNMatrix4Mult(rotationMatrix, translationMatrix)
        // 4
        DispatchQueue.main.async {
            self.scnScene.addParticleSystem(explosion, transform: transformMatrix)
        }
    }
    
    func shoot() {
        
        if scnScene.isPaused {
            return
        }
        
        var leftPosition = shipNode.position
        leftPosition.x += 0.5
        let leftFireball = Fireball(position: leftPosition)
        
        var rightPosition = shipNode.position
        rightPosition.x -= 0.5
        let rightFireball = Fireball(position: rightPosition)
        
        let fire =
            SCNParticleSystem(named: "FireParticle.scnp", inDirectory:
                nil)!
        fire.emitterShape = leftFireball.node.geometry
        fire.birthLocation = .surface
        fire.colliderNodes = unbreakableWalls
        fire.particleDiesOnCollision = true
        
        leftFireball.node.geometry?.firstMaterial?.diffuse.contents = UIColor.black
        rightFireball.node.geometry?.firstMaterial?.diffuse.contents = UIColor.black
        
        // 3
//        let rotationMatrix =
//            SCNMatrix4MakeRotation(rotation.w, rotation.x,
//                                   rotation.y, rotation.z)
//        let translationMatrix =
//            SCNMatrix4MakeTranslation(position.x, position.y,
//                                      position.z)
//        let transformMatrix =
//            SCNMatrix4Mult(rotationMatrix, translationMatrix)
        // 4
        leftFireball.node.addParticleSystem(fire)
        rightFireball.node.addParticleSystem(fire)
        
        DispatchQueue.main.async {
            self.scnScene.rootNode.addChildNode(leftFireball.node)
            self.scnScene.rootNode.addChildNode(rightFireball.node)
        }
        
        game.playSound(scnScene.rootNode, name: "Blaster")
    }
    
    func shootLazer() {
        
        if scnScene.isPaused {
            return
        }
        
        var position = shipNode.position
        position.z += 25.0
        let lazer = LazerBeam(position: position)
        
        let magic = SCNParticleSystem(named: "LazerParticle.scnp", inDirectory:
                nil)!
        
        magic.emitterShape = lazer.node.geometry
        magic.birthLocation = .surface
        magic.colliderNodes = unbreakableWalls
        //magic.particleDiesOnCollision = true
        
        lazer.node.geometry?.firstMaterial?.diffuse.contents = UIColor.black
        
        lazer.node.addParticleSystem(magic)
        
        
        DispatchQueue.main.async {
            self.scnScene.rootNode.addChildNode(lazer.node)
        }
        
        game.playSound(scnScene.rootNode, name: "Blaster")
    }
    
    func newGamePressed() {
        game.state = .Playing
        restartPressed()
    }
    
    func restartPressed() {
        stopWalls()
        resetBrickBarriers()
        game.reset()
        startWallTimers()
        updateHud()
        unpauseGame()
    }
    
    func continuePressed() {
        unpauseGame()
        updateHud()
    }
    
    func settingsPressed() {
        restartPressed()
    }
    
    func stopWalls() {
        scnScene.rootNode.removeAction(forKey: wallTimerKey)
        for node in scnScene.rootNode.childNodes {
            let removeableNodes = ["Wall", "UnbreakableWall"]
            guard let name = node.name else {
                continue
            }
            if removeableNodes.contains(name) {
                node.removeFromParentNode()
            }
        }
    }
    
    func resetBrickBarriers() {
        movingBrickBarriers.reset()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    @IBAction func playPauseButtonPressed() {
        if !scnScene.isPaused {
            showMenu(true)
        } else {
            
        }
    }
    
    func pauseGame() {
        scnScene.isPaused = true
    }
    
    func unpauseGame() {
        scnScene.isPaused = false
    }
    
    func checkShipPosition() {
        
        if shipNode.position.y > 7.5 {
            shipNode.position.y = 7.5
        }
        if shipNode.position.y < 0.5 {
            shipNode.position.y = 0.5
        }
        if shipNode.position.x < 1 {
            shipNode.position.x = 1
        }
        if shipNode.position.x > 7 {
            shipNode.position.x = 7
        }
        updateShipCamera()
    }
    
    // handle notification
    @objc func willRemoveUnbreakableWall(_ notification: NSNotification) {
        print(notification.userInfo ?? "")
        if let dict = notification.userInfo as NSDictionary?,
            let thisNode = dict["node"] as? SCNNode {
            let walls = unbreakableWalls.filter { $0 != thisNode }
            unbreakableWalls = walls
        }
    }
    
    // MARK: - Navigation -
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
            
        case let gameMenuView as GameMenuViewController:
            self.gameMenuView = gameMenuView
            self.gameMenuView?.delegate = self
        default:
            break
        }
    }
}

extension GameViewController: SCNSceneRendererDelegate {
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        DispatchQueue.main.async {
            self.game.updateHUD()
        }
    }    
}

extension GameViewController: SCNPhysicsContactDelegate {
    // 2
    func physicsWorld(_ world: SCNPhysicsWorld,
                      didBegin contact: SCNPhysicsContact) {
        // 3
        var contactNode: SCNNode!
        var weaponNode: SCNNode!
        var isFireballNode = false
        var isLazerBeamNode = false
        
        if contact.nodeA.name == "Ship" {
            contactNode = contact.nodeB
        } else {
            contactNode = contact.nodeA
        }
        
        var wasShot = false
        if contact.nodeA.name == "fireball" || contact.nodeB.name == "fireball" {
            wasShot = true
            isFireballNode = true
            if contact.nodeA.name == "fireball" {
                weaponNode = contact.nodeA
            } else {
                weaponNode = contact.nodeB
            }
        }
        if contact.nodeA.name == "LazerBeam" || contact.nodeB.name == "LazerBeam" {
            wasShot = true
            isLazerBeamNode = true
            if contact.nodeA.name == "LazerBeam" {
                weaponNode = contact.nodeA
            } else {
                weaponNode = contact.nodeB
            }
        }
        // 4
        if lastContactNode != nil &&
            lastContactNode == contactNode {
            return
        }
        lastContactNode = contactNode
        
        if contactNode.physicsBody?.categoryBitMask ==
            ColliderType.barrier.rawValue {
            if contactNode.name == "Bottom" {
//                game.lives -= 1
//                if game.lives == 0 {
//                    game.saveState()
//                    game.reset()
//                }
            } }
        // 2
        if contactNode.physicsBody?.categoryBitMask ==
            ColliderType.brick.rawValue {
            //game.score += 1
            let isBarrierBrick = contactNode.name == "BarrierBrick"
            if isBarrierBrick {
                return;
            }
            
            let isBreakableBrick = contactNode.name != "UnbreakableBrick"
            let wallNode = contactNode.parent
            if wallNode != nil,
               isBreakableBrick  {
                let position = SCNVector3Make(contactNode.position.x, contactNode.position.y, (wallNode?.position.z)!)
//                print("[AT] contactNode.presentation.position: \(contactNode.presentation.position)")
//                print("[AT] contactNode.position: \(contactNode.position)")
                createExplosion(geometry: contactNode.geometry!,
                                position: position,
                                rotation: contactNode.presentation.rotation)
                game.score += brickPoint(for: gameLevel)
                updateHud()
            }
            
            if !wasShot {
                game.playSound(scnScene.rootNode, name: "Brick")
                game.shakeNode(shipNode)
                game.lives -= 1
                game.score += brickPoint(for: gameLevel)
                updateHud()
            }
            
            if isBreakableBrick {
                // we either shot or crashed into the breakable brick. remove it
                contactNode.removeFromParentNode()
            } else {
                if wasShot {
                    // shot unbreakable brick, just remove the weapon
                    weaponNode.removeFromParentNode()
                } else {
                    // crashed into unbreakable brick, remove the brick so we can go thru
                    contactNode.removeFromParentNode()
                }
            }
        }
//        // 3
//        if contactNode.physicsBody?.categoryBitMask ==
//            ColliderType.paddle.rawValue {
//            if contactNode.name == "Left" {
//                ballNode.physicsBody!.velocity.xzAngle -=
//                    (convertToRadians(angle: 20))
//            }
//            if contactNode.name == "Right" {
//                ballNode.physicsBody!.velocity.xzAngle +=
//                    (convertToRadians(angle: 20))
//            }x
//        }
//        // 4
//        ballNode.physicsBody?.velocity.length = 5.0
    }
}





