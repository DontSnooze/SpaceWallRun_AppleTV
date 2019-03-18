//
//  GameViewController+GameControllerHelperDelegate.swift
//  SpaceWallRunATV
//
//  Created by Amos Todman on 3/4/19.
//  Copyright © 2019 Amos Todman. All rights reserved.
//

import Foundation
import SceneKit

extension GameViewController: GameControllerHelperDelegate {

    func controllerMenuPressed() {
//        print("\(#function) controllerUserInteractionEnabled: \(self.controllerUserInteractionEnabled)")
        
        if scnScene.isPaused {
            switch gameMenuType {
            case .main:
                break
            case .settings:
                gameMenuView?.setupTable(for: .main)
            case .difficulty:
                gameMenuView?.setupTable(for: .settings)
            case .joystickSensitivity:
                gameMenuView?.setupTable(for: .settings)
            case .none:
                break
            }
        } else {
            showMenu(true)
        }
    }
    
    func controllerMenuReleased() {
        //
    }
    
    func controllerRightTriggerPressed() {
//        print("\(#function)")
        if !scnScene.isPaused {
            shoot()
        }
    }
    
    func controllerRightTriggerReleased() {
        //
    }
    
    func controllerMoved(with displacement: float2) {
        if !scnScene.isPaused {
            shipNode.position.x = shipNode.position.x - (displacement.x / Float(joystickSensitivity))
            shipNode.position.y = shipNode.position.y + (displacement.y / Float(joystickSensitivity))
            checkShipPosition()
        }
    }
    
    func controllerXPressed() {
//        print("\(#function)")
        // play/pause button on siri remote
        if !scnScene.isPaused {
            // special weapon
            shootLazer()
        }
        
    }
    
    func controllerAPressed() {
//        print("\(#function)")
        if !scnScene.isPaused {
            shoot()
        }
    }
    
    func controllerAReleased() {
    }
    
    func controllerXReleased() {
//        print("\(#function)")
        // remove lazer
    }
    
    func shipNodeForControl() -> SCNNode {
        return shipNode
    }
}
