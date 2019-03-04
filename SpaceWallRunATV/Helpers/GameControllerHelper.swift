//
//  GameControllerHelper.swift
//  SpaceWallRunATV
//
//  Created by Amos Todman on 3/4/19.
//  Copyright © 2019 Amos Todman. All rights reserved.
//

import UIKit
import SceneKit
import GameController

@objc protocol GameControllerHelperDelegate: AnyObject {
    func controllerMoved(with displacement:float2)
    func controllerAPressed()
    func controllerAReleased()
    func controllerXPressed()
    func controllerXReleased()
    func controllerMenuPressed()
    func controllerMenuReleased()
    func controllerRightTriggerPressed()
    func controllerRightTriggerReleased()
    func shipNodeForControl() -> SCNNode
}

@objc class GameControllerHelper: NSObject {
    weak var delegate:GameControllerHelperDelegate?
    var controllers = [GCController]()
    
    override init() {
        super.init()
        getControllers()
        addControllerConnectionObservers()
        
    }
    
    func addControllerConnectionObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(GameControllerHelper.gcControllerDidConnect(_:)), name: NSNotification.Name.GCControllerDidConnect, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.gcControllerDidDisconnect(_:)), name: NSNotification.Name.GCControllerDidDisconnect, object: nil)
    }
    
    func getControllers() {
        controllers = GCController.controllers()
        if controllers.count < 1 {
            print("[at] no controller try and attach to them")
            attachControllers()
        }
    }
    
    func attachControllers() {
        GCController.startWirelessControllerDiscovery {
            //
        }
    }
    // MARK: - GCController Observers -
    @objc func gcControllerDidConnect(_ notification: NSNotification) {
        print("\(#function)")
        // assign the gameController which is found - will break if more than 1
        guard let connectedController = notification.object as? GCController else {
           print("[at] Could not find a controller")
            return
        }
        controllers = GCController.controllers()
        // we have a controller so go and setup handlers
        setupGCEvents()
    }
    
    @objc func gcControllerDidDisconnect(_ notification: NSNotification) {
        // if a controller disconnects we should see it
        print("\(#function)")
        controllers = GCController.controllers()
    }
    
    // MARK: - microGamepad event callbacks -
    func setupGCEvents(){
        for controller in controllers {
            //if it is a gamepad
            if let gamepad = controller.extendedGamepad {
                print("[at] Gamepad found")
                registerGamepadEvents(gamepad: gamepad)
            }
            
            //if it is a siri remote
            if let microGamepad = controller.microGamepad {
                print("[at] microGamepad found")
                registermicroGamepadEvents(microGamepad: microGamepad)
            }
        }
    }
    
    func registerGamepadEvents(gamepad: GCExtendedGamepad){
        print("\(#function)")
        //setup the handlers
        let buttonAHandler: GCControllerButtonValueChangedHandler = {  button, _, pressed in
            print("[at] buttonAHandler")
            if button.isPressed {
                self.delegate?.controllerAPressed()
            } else {
                self.delegate?.controllerAReleased()
            }
        }
        
        let buttonXHandler: GCControllerButtonValueChangedHandler = {  button, _, pressed in
            print("[at] buttonXHandler")
            if button.isPressed {
                self.delegate?.controllerXPressed()
            } else {
                self.delegate?.controllerXReleased()
            }
        }
        
        let buttonMenuHandler: GCControllerButtonValueChangedHandler = {  button, _, pressed in
            print("[at] buttonMenuHandler")
            if button.isPressed {
                self.delegate?.controllerMenuPressed()
            } else {
                self.delegate?.controllerMenuReleased()
            }
        }
        
        let rightTriggerHandler: GCControllerButtonValueChangedHandler = {  button, _, pressed in
            print("[at] rightTriggerHandler")
            if button.isPressed {
                self.delegate?.controllerRightTriggerPressed()
            } else {
                self.delegate?.controllerRightTriggerReleased()
            }
        }
        
        let movementHandler: GCControllerDirectionPadValueChangedHandler = {  _, xValue, yValue in
            let displacement = float2(x: xValue, y: yValue)
            print("[at] displacement:\(displacement)")
            
            self.delegate?.controllerMoved(with: displacement)
        }
        
        gamepad.buttonA.pressedChangedHandler = buttonAHandler
        gamepad.buttonX.pressedChangedHandler = buttonXHandler
        gamepad.dpad.valueChangedHandler = movementHandler
        gamepad.rightTrigger.pressedChangedHandler = rightTriggerHandler
        gamepad.leftThumbstick.valueChangedHandler = movementHandler
        
        gamepad.controller?.controllerPausedHandler = { [unowned self] _ in
            self.delegate?.controllerMenuPressed()
        }
    }
    
    func registermicroGamepadEvents(microGamepad :GCMicroGamepad){
        print("\(#function)")
        //setup the handlers
        let buttonAHandler: GCControllerButtonValueChangedHandler = {  button, _, pressed in
            print("[at] buttonAHandler")
            if button.isPressed {
                self.delegate?.controllerAPressed()
            } else {
                self.delegate?.controllerAReleased()
            }
        }
        
        let buttonXHandler: GCControllerButtonValueChangedHandler = {  button, _, pressed in
            print("[at] buttonXHandler")
            if button.isPressed {
                self.delegate?.controllerXPressed()
            } else {
                self.delegate?.controllerXReleased()
            }
        }
        
        let movementHandler: GCControllerDirectionPadValueChangedHandler = {  _, xValue, yValue in
            let displacement = float2(x: xValue, y: yValue)
            print("[at] displacement:\(displacement)")
            
            self.delegate?.controllerMoved(with: displacement)
        }
        
        microGamepad.buttonA.pressedChangedHandler = buttonAHandler
        microGamepad.buttonX.pressedChangedHandler = buttonXHandler
        microGamepad.dpad.valueChangedHandler = movementHandler
        
        microGamepad.controller?.controllerPausedHandler = { [unowned self] _ in
            self.delegate?.controllerMenuPressed()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
