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
        print("\(#function)")
        
        playPauseButtonPressed()
    }
    
    func controllerMenuReleased() {
        //
    }
    
    func controllerRightTriggerPressed() {
        print("\(#function)")
        if !scnScene.isPaused {
            shoot()
        }
    }
    
    func controllerRightTriggerReleased() {
        //
    }
    
    func controllerMoved(with displacement: float2) {
//        print("[at] \(#function)")
        if scnScene.isPaused {
            if displacement.x == 0 && displacement.y == 0 {
                return
            }
            if displacement.y < 0 {
                handleMenuSwipe(direction: .up)
            } else {
                handleMenuSwipe(direction: .down)
            }
        } else {
            shipNode.position.x = shipNode.position.x - (displacement.x / 5)
            shipNode.position.y = shipNode.position.y + (displacement.y / 5)
            checkShipPosition()
        }
    }
    
    func controllerXPressed() {
        print("\(#function)")
        // play/pause button on siri remote
        if !scnScene.isPaused {
            // special weapon
            shootLazer()
        }
        
    }
    
    func controllerAPressed() {
        print("\(#function)")
        if !scnScene.isPaused {
            shoot()
        }
    }
    
    func controllerAReleased() {
        //
        print("\(#function)")
        if scnScene.isPaused {
            if !gameStarted {
                newGamePressed()
            } else {
                menuItemSelected()
            }
        }
    }
    
    func controllerXReleased() {
//        print("\(#function)")
        // remove lazer
    }
    
    func shipNodeForControl() -> SCNNode {
        return shipNode
    }
}
