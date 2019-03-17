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

extension GameViewController {
    func showMenuAlert() {
        gameMenuType = .main
        controllerUserInteractionEnabled = true
        
        pauseGame()
        let title = game.state == .GameOver ? "Game Over" : "Space Wall Run"
        let message = game.state == .GameOver ? "Score: 💥\(lastScore)\nHigh Score: 😎\(game.highScore)" : nil
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let continueTitle = game.state == .Playing ? "Continue" : "New Game"
        
        
        alert.addAction(UIAlertAction(title: continueTitle, style: .default) { _ in
            if self.game.state == .Playing {
                self.continuePressed()
            } else {
                self.newGamePressed()
            }
            self.gameMenuType = .none
            self.controllerUserInteractionEnabled = false
        })
        
        if game.state == .Playing {
            alert.addAction(UIAlertAction(title: "Restart", style: .default) { _ in
                self.restartPressed()
                self.gameMenuType = .none
                self.controllerUserInteractionEnabled = false
            })
        }
        
        alert.addAction(UIAlertAction(title: "Settings", style: .default) { _ in
            self.showSettingsAlert()
        })
        
        self.present(alert, animated: true) {
            self.controllerUserInteractionEnabled = true
            print("after present controllerUserInteractionEnabled: \(self.controllerUserInteractionEnabled)")
        }
        
        print("\(#function) controllerUserInteractionEnabled: \(self.controllerUserInteractionEnabled)")
    }
    
    func showSettingsAlert() {
        self.controllerUserInteractionEnabled = false
        gameMenuType = .settings
        let alert = UIAlertController(title: "Settings", message: nil, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Joystick Sensitivity", style: .default) { _ in
                self.showJoystickSensitivityAlert()
        })
        
        self.present(alert, animated: false, completion: nil)
    }
    
    func showJoystickSensitivityAlert() {
        self.controllerUserInteractionEnabled = false
        gameMenuType = .joystickSensitivity
        let alert = UIAlertController(title: "Joystick Sensitivity", message: nil, preferredStyle: .alert)
        
        let action1 = UIAlertAction(title: "1", style: .default) { _ in
            self.joystickSensitivity = 10
            self.showMenuAlert()
        }
        alert.addAction(action1)
        if joystickSensitivity == 10 {
            alert.preferredAction = action1
        }
        
        let action2 = UIAlertAction(title: "2", style: .default) { _ in
            self.joystickSensitivity = 9
            self.showMenuAlert()
        }
        alert.addAction(action2)
        if joystickSensitivity == 9 {
            alert.preferredAction = action2
        }
        
        let action3 = UIAlertAction(title: "3", style: .default) { _ in
            self.joystickSensitivity = 8
            self.showMenuAlert()
        }
        alert.addAction(action3)
        if joystickSensitivity == 8 {
            alert.preferredAction = action3
        }
        
        let action4 = UIAlertAction(title: "4", style: .default) { _ in
            self.joystickSensitivity = 7
            self.showMenuAlert()
        }
        alert.addAction(action4)
        if joystickSensitivity == 7 {
            alert.preferredAction = action4
        }
        
        let action5 = UIAlertAction(title: "5", style: .default) { _ in
            self.joystickSensitivity = 6
            self.showMenuAlert()
        }
        alert.addAction(action5)
        if joystickSensitivity == 6 {
            alert.preferredAction = action5
        }
        
        let action6 = UIAlertAction(title: "6", style: .default) { _ in
            self.joystickSensitivity = 5
            self.showMenuAlert()
        }
        alert.addAction(action6)
        if joystickSensitivity == 5 {
            alert.preferredAction = action6
        }
        
        let action7 = UIAlertAction(title: "7", style: .default) { _ in
            self.joystickSensitivity = 4
            self.showMenuAlert()
        }
        alert.addAction(action7)
        if joystickSensitivity == 4 {
            alert.preferredAction = action7
        }
        
        let action8 = UIAlertAction(title: "8", style: .default) { _ in
            self.joystickSensitivity = 3
            self.showMenuAlert()
        }
        alert.addAction(action8)
        if joystickSensitivity == 3 {
            alert.preferredAction = action8
        }
        
        let action9 = UIAlertAction(title: "9", style: .default) { _ in
            self.joystickSensitivity = 2
            self.showMenuAlert()
        }
        alert.addAction(action9)
        if joystickSensitivity == 2 {
            alert.preferredAction = action9
        }
        
        let action10 = UIAlertAction(title: "10", style: .default) { _ in
            self.joystickSensitivity = 1
            self.showMenuAlert()
        }
        alert.addAction(action10)
        if joystickSensitivity == 1 {
            alert.preferredAction = action10
        }
        
        let resetAction = UIAlertAction(title: "Reset", style: .default) { _ in
            self.joystickSensitivity = defaultJoystickSensitivity
            self.showMenuAlert()
        }
        alert.addAction(resetAction)
        
        self.present(alert, animated: false, completion: nil)
    }
}
