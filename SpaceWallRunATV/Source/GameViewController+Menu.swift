//
//  GameViewController+Menu.swift
//  SpaceWallRunATV
//
//  Created by Amos Todman on 3/9/19.
//  Copyright © 2019 Amos Todman. All rights reserved.
//

import Foundation
import UIKit

enum GameMenuType {
    case main
    case settings
    case joystickSensitivity
    case none
}

extension GameViewController: GameMenuViewControllerDelegate {
    func newGamePressedInGameMenu() {
        controllerUserInteractionEnabled = false
    }
    
    func continuePressedInGameMenu() {
        controllerUserInteractionEnabled = false
    }
    
    func restartPressedInGameMenu() {
        controllerUserInteractionEnabled = false
    }
    
    func settingsPressedInGameMenu() {
        controllerUserInteractionEnabled = false
    }
    
    func joystickSensitivityPressedInGameMenu() {
        controllerUserInteractionEnabled = false
    }
    
    func joystickSensitivitySelectedInGameMenu() {
        controllerUserInteractionEnabled = false
    }
}

extension GameViewController {
    
    func showMenu(_ show: Bool) {
        if show {
            showMenu()
        } else {
            hideMenu()
        }
    }
    
    func showMenu() {
        controllerUserInteractionEnabled = true
        gameMenuType = .main
        gameMenuView?.setupTable(for: .main)
        gameMenuView?.view.isHidden = false
        
        pauseGame()
    }
    
    func hideMenu() {
        gameMenuView?.view.isHidden = true
        gameMenuType = .none
    }

    func registerForNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.gotAppWillBackGroundNotification), name: backGroundNotificationKey, object: nil)
    }
    
    @objc func gotAppWillBackGroundNotification(notification: Notification) {
        // pauses automatically, show the menu if needed
        if gameMenuType == .none {
            pauseGame()
            showMenu(true)
        }
    }
    
    
}
