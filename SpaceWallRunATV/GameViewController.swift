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

class GameViewController: UIViewController {

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
    var timer = Timer()
    var hudTimer = Timer()
    var game = GameHelper.sharedInstance
    var spriteScene: SKScene!
    var movingBarriers: MovingBarrier!
    var gameMode:GameModeType = .thru
    var pointTally = 0
    var unbreakableWalls = [SCNNode]()
    
    //let moveAnalogStick =  🕹(diameter: 110)
    //let rotateAnalogStick = AnalogJoystick(diameter: 100)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupScene()
        
        spriteScene = SKScene(size: self.view.frame.size)
        scnView.overlaySKScene = self.spriteScene
        setupNodes()
        //setupJoysticks()
        setupSounds()
        game.playSound(shipNode, name: "bgSong")
        setupRemote()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.willRemoveUnbreakableWall(_:)), name: NSNotification.Name(rawValue: "WillRemoveUnbreakableWall"), object: nil)

        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
            DispatchQueue.main.async {
                self.addWall()
                self.addBrickBarrier()
            }
        }
        
        hudTimer = Timer.scheduledTimer(withTimeInterval: 4.0, repeats: true) { _ in
            DispatchQueue.main.async {
                self.updateHud()
            }
        }
    }
    
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
    
    func setupRemote() {
        let playPauseRecognizer = UITapGestureRecognizer(target: self, action: #selector(GameViewController.playPauseButtonPressed(_:)))
        playPauseRecognizer.allowedPressTypes = [NSNumber(value: UIPress.PressType.playPause.rawValue)];
        self.view.addGestureRecognizer(playPauseRecognizer)
        
//        let shootRecognizer = UITapGestureRecognizer(target: self, action: #selector(GameViewController.shootPressed(_:)))
//        shootRecognizer.allowedPressTypes = [NSNumber(value: UIPressType.select.rawValue)];
//        self.view.addGestureRecognizer(shootRecognizer)
        
//        let swipeUpRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(GameViewController.swipedUp(_:)))
//        swipeUpRecognizer.direction = .up
//        self.view.addGestureRecognizer(swipeUpRecognizer)
//        
//        let swipeDownRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(GameViewController.swipedDown(_:)))
//        swipeDownRecognizer.direction = .down
//        self.view.addGestureRecognizer(swipeDownRecognizer)
//        
//        let swipeLeftRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(GameViewController.swipedLeft(_:)))
//        swipeLeftRecognizer.direction = .left
//        self.view.addGestureRecognizer(swipeLeftRecognizer)
//        
//        let swipeRightRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(GameViewController.swipedRight(_:)))
//        swipeRightRecognizer.direction = .right
//        self.view.addGestureRecognizer(swipeRightRecognizer)
//        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(GameViewController.handlePan(_:)))
        self.view.addGestureRecognizer(panGestureRecognizer)

    }
    /*
    func setupJoysticks() {
        
        moveAnalogStick.position = CGPoint(x: moveAnalogStick.radius + 15, y: moveAnalogStick.radius + 15)
        spriteScene.addChild(moveAnalogStick)
        
        rotateAnalogStick.position = CGPoint(x: self.view.frame.maxX - rotateAnalogStick.radius - 15, y:rotateAnalogStick.radius + 15)
        spriteScene.addChild(rotateAnalogStick)
        
        //MARK: Handlers begin
        
        moveAnalogStick.startHandler = { [unowned self] in
            
//            guard let aN = self.shipNode else { return }
//            aN.run(SKAction.sequence([SKAction.scale(to: 0.5, duration: 0.5), SKAction.scale(to: 1, duration: 0.5)]))
        }
        
        moveAnalogStick.trackingHandler = { [unowned self] data in
            
            guard let aN = self.shipNode else { return }
            
            if abs(data.velocity.x) > 3 {
                let multiplier = abs(data.velocity.x) / 540
                if data.velocity.x > 0 {
                    //subtract
                    aN.position.x = aN.position.x - Float(multiplier)
                    
                } else {
                    //add
                    aN.position.x = aN.position.x + Float(multiplier)
                }
            }
            var oldPos = aN.position.y
            var yDifference:Float = 0
            if abs(data.velocity.y) > 3 {
                let multiplier = abs(data.velocity.y) / 540
                
                if data.velocity.y > 0 {
                    //add
                    yDifference = aN.position.y + Float(multiplier)
                    
                } else {
                    //subtract
                    yDifference = aN.position.y - Float(multiplier)
                }
                
                aN.position.y = yDifference
                //self.shipCameraNode.position.y = self.shipCameraNode.position.y + (yDifference)
            }
            
            
            
            if aN.position.x > 7 {
                aN.position.x = 7
            }
            if aN.position.x < 1 {
                aN.position.x = 1
            }
            if aN.position.y > 7.5 {
                aN.position.y = 7.5
            }
            if aN.position.y < 0.5 {
                aN.position.y = 0.5
            }
            
                // update camera view
            
            let scaledX = ((self.shipNode.position.x - 4) / 1.5) + 4
                self.shipCameraNode.position.x = scaledX
            let scaledY = ((self.shipNode.position.y - 3.75) / 1.5) + 3.75
            self.shipCameraNode.position.y = scaledY
                //self.shipCameraNode.position.x = self.shipNode.position.x / 1.5

            
            
        }
        
        moveAnalogStick.stopHandler = { [unowned self] in
            
//            guard let aN = self.shipNode else { return }
//            aN.run(SKAction.sequence([SKAction.scale(to: 1.5, duration: 0.5), SKAction.scale(to: 1, duration: 0.5)]))
        }
        
        
        
        rotateAnalogStick.trackingHandler = { [unowned self] jData in
            guard let aN = self.shipNode else { return }
            if abs(jData.velocity.y) > 0 || abs(jData.velocity.x) > 0 {
                aN.eulerAngles.z = Float(jData.angular) * -1
            } else {
                aN.eulerAngles.z = Float(0).degreesToRadians
            }
        }
        
        rotateAnalogStick.stopHandler =  { [unowned self] in
            
//            guard let aN = self.shipNode else { return }
//            aN.run(SKAction.rotate(byAngle: 3.6, duration: 0.5))
        }
    }
 */
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
        
        // setup moving barriers
        let barriers = scnScene.rootNode.childNode(withName:
            "Barriers", recursively: true)!
        /*movingBarriers = MovingBarrier(parentNode: scnScene.rootNode, baseBarrier: barriers)
        movingBarriers.start()
 */
    }
    
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
        
        let gameMode = possibleModes[randomIndex]
        let newWall = BrickBarrier(position: SCNVector3Make(-3, 0, 190.0), forGameMode:gameMode)
        
        scnScene.rootNode.addChildNode(newWall.node)
    }
    
    @objc func updateHud() {
        self.hudLabel.text = game.labelNode.text
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
        scnScene.addParticleSystem(explosion, transform: transformMatrix)
    }
    
    func shoot() {
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
        scnScene.rootNode.addChildNode(leftFireball.node)
        scnScene.rootNode.addChildNode(rightFireball.node)
        
        game.playSound(scnScene.rootNode, name: "Blaster")
    }
    /*
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .landscape
        } else {
            return .all
        }
    }
 */
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    @IBAction func playPauseButtonPressed(_ gestureRecognizer: UITapGestureRecognizer) {
        scnScene.isPaused = !scnScene.isPaused
    }
    @IBAction func shootPressed(_ gestureRecognizer: UITapGestureRecognizer) {
        //shoot()
    }
    
    @IBAction func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        if gestureRecognizer.state == .began || gestureRecognizer.state == .changed {
            
            let translation = gestureRecognizer.translation(in: self.view)
            shipNode.position.x = shipNode.position.x - Float(translation.x / 1000)
            shipNode.position.y = shipNode.position.y - Float(translation.y / 1000)
            checkShipPosition()
        }
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
}

extension GameViewController: SCNSceneRendererDelegate {
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
        game.updateHUD()
    }
    
}

extension GameViewController: SCNPhysicsContactDelegate {
    // 2
    func physicsWorld(_ world: SCNPhysicsWorld,
                      didBegin contact: SCNPhysicsContact) {
        // 3
        var contactNode: SCNNode!
        var fireball: SCNNode!
        
        if contact.nodeA.name == "Ship" {
            contactNode = contact.nodeB
        } else {
            contactNode = contact.nodeA
        }
        
        var wasShot = false
        if contact.nodeA.name == "fireball" || contact.nodeB.name == "fireball" {
            wasShot = true
            if contact.nodeA.name == "fireball" {
                fireball = contact.nodeA
            } else {
                fireball = contact.nodeB
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
            let isBreakableBrick = contactNode.name != "UnbreakableBrick"
            let wallNode = contactNode.parent
            if wallNode != nil,
               isBreakableBrick  {
                let position = SCNVector3Make(contactNode.presentation.position.x, contactNode.presentation.position.y, (wallNode?.position.z)!)
                createExplosion(geometry: contactNode.geometry!,
                                position: position,
                                rotation: contactNode.presentation.rotation)
            }
            
            if wasShot {
                
                fireball.isHidden = true
                
            } else {
                game.playSound(scnScene.rootNode, name: "Brick")
                game.shakeNode(shipNode)
                game.lives -= 1
                
            }
            
            if isBreakableBrick {
                contactNode.removeFromParentNode()
            } else {
                if wasShot {
                    // trying to stop the particles from going thru the unbreakable walls (none of this works)
                    fireball.removeAllActions()
                    fireball.removeAllParticleSystems()
                    fireball.removeFromParentNode()
                } else {
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
    
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        for item in presses {
            if item.type == .select {
                shoot()
            }
        }
    }
}





