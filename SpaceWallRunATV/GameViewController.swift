//
//  GameViewController.swift
//  SpaceWallRun
//
//  Created by Amos Todman on 12/4/16.
//  Copyright © 2016 Amos Todman. All rights reserved.
//

import UIKit
import QuartzCore
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
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
            DispatchQueue.main.async {
                self.addWall()
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
        movingBarriers = MovingBarrier(parentNode: scnScene.rootNode, baseBarrier: barriers)
        movingBarriers.start()
    }
    
    @objc func addWall() {
        let possibleModes:[GameModeType] = [.thru, .fullMove, .angleMove, .spin]
        
        let randomNum:UInt32 = arc4random_uniform(UInt32(possibleModes.count))
        let randomIndex:Int = Int(randomNum)
        
        let newWall = BrickWall(position: SCNVector3Make(0, 0, 190.0), forGameMode:possibleModes[randomIndex])

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
                if !wasShot {
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

class BrickWall: NSObject {
    
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
        
        node = createBrickWall(width: 4, height: 8, position: position, forGameMode: forGameMode)
        
        node.position = position
        
        node.runAction(SCNAction.moveBy(x: 0, y: 0, z: -240.0, duration: 20.0))
        gameMode = forGameMode
        if forGameMode == .thru {
            GameViewController.removeFourRandomBlocks(fromWall: node!, gridWidth: 4, gridHeight: 8)
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
            _ = CGFloat(max.y - min.y)
            _ =  CGFloat( max.z - min.z)
            
            let rotationValue = 2 * Double.pi
            let pivot = w / 2
            node.pivot = SCNMatrix4MakeTranslation(Float(pivot),0,0)
            node.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: CGFloat(rotationValue), z: 0, duration: 1)))
        }
        
        startBrickCount = node.childNodes.count
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            DispatchQueue.main.async {
                self.checkLocation()
            }
        }
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
            if startBrickCount - endBrickCount == 0 {
                if gameMode == .thru {
                    wallScore += 20
                }
            } else {
                if gameMode == .thru {
                    wallScore = endBrickCount - startBrickCount
                } else {
                    wallScore =  startBrickCount - endBrickCount
                }
            }
            
            GameHelper.sharedInstance.score += wallScore
            GameHelper.sharedInstance.saveState()
            node.removeFromParentNode()
            timer.invalidate()
            
            
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createBrick(position: SCNVector3, forGameMode: GameModeType) -> SCNNode {
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
        
        var brickPosition = SCNVector3Make(1, 0.5, 0)
        for i in 1...numberOfBricks {
            let wallBrick = createBrick(position: brickPosition, forGameMode: forGameMode)
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



