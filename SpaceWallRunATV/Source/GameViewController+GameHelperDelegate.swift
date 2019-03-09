//
//  GameViewController+GameHelperDelegate.swift
//  SpaceWallRunATV
//
//  Created by Amos Todman on 3/9/19.
//  Copyright © 2019 Amos Todman. All rights reserved.
//

import Foundation

extension GameViewController: GameHelperDelegate {
    func gameHelperWillResetGame() {
        handleGameOver()
    }
    
    func handleGameOver() {
        setupMenu()
        stopWalls()
        gameStarted = false
        if !scnScene.isPaused {
            playPauseButtonPressed()
        }
    }
}

