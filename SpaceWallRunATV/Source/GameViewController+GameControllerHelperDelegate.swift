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
        
        playPauseButtonPressed(UITapGestureRecognizer())
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
        print("[at] \(#function)")
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
            shipNode.position.x = shipNode.position.x - (displacement.x / 8)
            shipNode.position.y = shipNode.position.y + (displacement.y / 8)
            checkShipPosition()
        }
    }
    
    func controllerXPressed() {
        print("\(#function)")
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
        print("\(#function)")
        if scnScene.isPaused {
            
            if !gameStarted {
                newGamePressed()
            } else {
                continuePressed()
            }
            
        } else {
            playPauseButtonPressed(UITapGestureRecognizer())
        }
    }
    
    func shipNodeForControl() -> SCNNode {
        return shipNode
    }
}
