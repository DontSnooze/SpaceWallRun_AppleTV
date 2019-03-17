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
        print("\(#function) controllerUserInteractionEnabled: \(self.controllerUserInteractionEnabled)")
        
        if scnScene.isPaused {
            switch gameMenuType {
            case .main:
                UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
                break
            case .settings:
                self.dismiss(animated: false) {
                    self.showMenuAlert()
                }
            case .joystickSensitivity:
                self.dismiss(animated: false) {
                    self.showSettingsAlert()
                }
            case .none:
                break
            }
        } else {
            showMenuAlert()
        }
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
        if !scnScene.isPaused {
            shipNode.position.x = shipNode.position.x - (displacement.x / Float(joystickSensitivity))
            shipNode.position.y = shipNode.position.y + (displacement.y / Float(joystickSensitivity))
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
    }
    
    func controllerXReleased() {
//        print("\(#function)")
        // remove lazer
    }
    
    func shipNodeForControl() -> SCNNode {
        return shipNode
    }
}
